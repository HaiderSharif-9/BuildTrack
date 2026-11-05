import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed" });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !anonKey || !serviceRoleKey) {
      return jsonResponse(500, { error: "Supabase function environment is not configured" });
    }

    const authorization = request.headers.get("Authorization");
    if (!authorization) {
      return jsonResponse(401, { error: "Authentication required" });
    }

    const callerClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: callerData, error: callerError } = await callerClient.auth.getUser();
    if (callerError || !callerData.user) {
      return jsonResponse(401, { error: "Invalid or expired session" });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: callerProfile, error: profileError } = await adminClient
      .from("profiles")
      .select("role, active")
      .eq("id", callerData.user.id)
      .maybeSingle();

    if (profileError || callerProfile?.role !== "admin" || callerProfile.active !== true) {
      return jsonResponse(403, { error: "Only an active administrator can create team accounts" });
    }

    const body = await request.json();
    const fullName = String(body.fullName ?? "").trim();
    const email = String(body.email ?? "").trim().toLowerCase();
    const phone = String(body.phone ?? "").trim();
    const role = String(body.role ?? "manager");
    const projectId = String(body.projectId ?? "").trim();

    if (fullName.length < 2 || fullName.length > 100) {
      return jsonResponse(400, { error: "Enter a valid full name" });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) {
      return jsonResponse(400, { error: "Enter a valid email address" });
    }
    if (!["admin", "accountant", "manager"].includes(role)) {
      return jsonResponse(400, { error: "Invalid user role" });
    }
    if (role === "manager" && !projectId) {
      return jsonResponse(400, { error: "Select a site for this manager" });
    }
    if (projectId) {
      const { data: project, error: projectError } = await adminClient
        .from("projects")
        .select("id")
        .eq("id", projectId)
        .is("deleted_at", null)
        .maybeSingle();
      if (projectError || !project) {
        return jsonResponse(400, { error: "The selected site does not exist or is archived" });
      }
    }

    const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
    const randomBytes = new Uint8Array(24);
    crypto.getRandomValues(randomBytes);
    const temporaryPassword =
      Array.from(randomBytes, (value) => alphabet[value % alphabet.length]).join("") + "A7!";

    const { data: created, error: createError } = await adminClient.auth.admin.createUser({
      email,
      password: temporaryPassword,
      email_confirm: true,
      user_metadata: { full_name: fullName },
      app_metadata: { provisioned_by_admin: true },
    });
    if (createError || !created.user) {
      return jsonResponse(400, { error: createError?.message ?? "Unable to create account" });
    }

    const { error: updateError } = await adminClient
      .from("profiles")
      .update({
        full_name: fullName,
        login_id: email,
        phone: phone || null,
        role,
        active: true,
        must_change_password: true,
        created_by: callerData.user.id,
      })
      .eq("id", created.user.id);

    if (updateError) {
      await adminClient.auth.admin.deleteUser(created.user.id);
      return jsonResponse(500, { error: "Account was rolled back because its profile could not be saved" });
    }

    if (role === "manager") {
      const { error: assignmentError } = await adminClient
        .from("project_members")
        .insert({ project_id: projectId, user_id: created.user.id });
      if (assignmentError) {
        await adminClient.auth.admin.deleteUser(created.user.id);
        return jsonResponse(500, { error: "Account was rolled back because the site assignment failed" });
      }
    }

    return jsonResponse(200, {
      userId: created.user.id,
      email,
      role,
      projectId: projectId || null,
      temporaryPassword,
    });
  } catch (error) {
    return jsonResponse(500, {
      error: error instanceof Error ? error.message : "Unexpected server error",
    });
  }
});
