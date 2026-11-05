import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/profile.dart';
import '../../../core/repositories/project_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_widgets.dart';

final usersListProvider = FutureProvider<List<Profile>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('profiles').select().order('full_name');
  return (response as List<dynamic>)
      .map((e) => Profile.fromJson(e as Map<String, dynamic>))
      .toList();
});

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final usersAsync = ref.watch(usersListProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Team & Users'),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(usersListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnGold,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add User', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddUserDialog(context, ref),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const EmptyState(
              title: 'No Team Members',
              subtitle: 'Tap the Add User button to invite managers and accountants',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textOnGold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.loginId,
                              style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                            ),
                            if (user.phone != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                user.phone!,
                                style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleBgColor(user.role, colors),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getRoleTextColor(user.role, colors),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          title: 'Error loading team',
          message: err.toString(),
          onRetry: () => ref.refresh(usersListProvider),
        ),
      ),
    );
  }

  Color _getRoleBgColor(String role, AppColorsValue colors) {
    switch (role) {
      case 'admin':
        return AppColors.primary.withValues(alpha: 0.15);
      case 'accountant':
        return colors.success.withValues(alpha: 0.15);
      case 'manager':
        return colors.info.withValues(alpha: 0.15);
      default:
        return colors.border;
    }
  }

  Color _getRoleTextColor(String role, AppColorsValue colors) {
    switch (role) {
      case 'admin':
        return AppColors.goldTextLight;
      case 'accountant':
        return colors.success;
      case 'manager':
        return colors.info;
      default:
        return colors.textPrimary;
    }
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final pageContext = context;
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final projectsFuture = ProjectRepository(Supabase.instance.client).listProjects();
    String selectedRole = 'manager';
    String? selectedProjectId;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Team Member (Admin Only)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    AppTextField(controller: nameController, label: 'Full Name', hint: 'e.g. Usman Tariq'),
                    const SizedBox(height: 12),
                    AppTextField(controller: emailController, label: 'Email (Login ID)', hint: 'e.g. usman@careconst.pk'),
                    const SizedBox(height: 12),
                    AppTextField(controller: phoneController, label: 'Phone Number', hint: 'e.g. 0300-1234567'),
                    const SizedBox(height: 16),
                    const Text('Role:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['accountant', 'manager'].map((role) {
                        final isSel = selectedRole == role;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(role.toUpperCase()),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            onSelected: (_) => setSheetState(() => selectedRole = role),
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedRole == 'manager') ...[
                      const SizedBox(height: 12),
                      FutureBuilder(
                        future: projectsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Unable to load sites: ${snapshot.error}');
                          }
                          final projects = snapshot.data ?? [];
                          if (projects.isEmpty) {
                            return const Text('Create a site before adding a manager.');
                          }
                          if (selectedProjectId == null ||
                              !projects.any((project) => project.id == selectedProjectId)) {
                            selectedProjectId = projects.first.id;
                          }
                          return DropdownButtonFormField<String>(
                            initialValue: selectedProjectId,
                            decoration: InputDecoration(
                              labelText: 'Assign Manager to Site',
                              filled: true,
                              fillColor: context.appColors.surfaceAlt,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: projects
                                .map(
                                  (project) => DropdownMenuItem<String>(
                                    value: project.id,
                                    child: Text(project.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setSheetState(() => selectedProjectId = value);
                              }
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'A temporary password will be assigned. The user can log in with their email and change their password.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Create Account',
                      isLoading: isSaving,
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final phone = phoneController.text.trim();

                        if (name.isEmpty || email.isEmpty || (selectedRole == 'manager' && selectedProjectId == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter name and email, and assign a site to manager accounts.')),
                          );
                          return;
                        }

                        setSheetState(() => isSaving = true);
                        try {
                          final supabase = Supabase.instance.client;
                          final response = await supabase.functions.invoke(
                            'admin-create-user',
                            body: {
                              'fullName': name,
                              'email': email,
                              'phone': phone,
                              'role': selectedRole,
                              'projectId': selectedRole == 'manager' ? selectedProjectId : null,
                            },
                          );
                          final result = Map<String, dynamic>.from(response.data as Map);
                          final temporaryPassword = result['temporaryPassword'] as String;

                          if (!pageContext.mounted) return;
                          Navigator.pop(ctx);
                          ref.invalidate(usersListProvider);

                          await showDialog<void>(
                            context: pageContext,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Team account created'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Login email: $email'),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Temporary password (share securely):',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  SelectableText(
                                    temporaryPassword,
                                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'The user must change this password after signing in.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: temporaryPassword));
                                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                                    if (pageContext.mounted) {
                                      ScaffoldMessenger.of(pageContext).showSnackBar(
                                        const SnackBar(content: Text('Temporary password copied')),
                                      );
                                    }
                                  },
                                  child: const Text('Copy password'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Done'),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          if (context.mounted) setSheetState(() => isSaving = false);
                          if (pageContext.mounted) {
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

