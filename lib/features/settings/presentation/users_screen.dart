import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/profile.dart';
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
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'manager';
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
                      children: ['admin', 'accountant', 'manager'].map((role) {
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

                        if (name.isEmpty || email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Name and Email are required')),
                          );
                          return;
                        }

                        setSheetState(() => isSaving = true);
                        try {
                          final supabase = Supabase.instance.client;
                          // Insert profile record
                          await supabase.from('profiles').insert({
                            'full_name': name,
                            'login_id': email,
                            'phone': phone.isNotEmpty ? phone : null,
                            'role': selectedRole,
                            'active': true,
                          });

                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ref.invalidate(usersListProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User "$name" created successfully!'), backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => isSaving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
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

