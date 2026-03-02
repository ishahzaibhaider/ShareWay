import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/gradient_scaffold.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _easypaisaController;
  late TextEditingController _jazzcashController;
  String _userType = 'passenger';
  bool _acceptsCash = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _easypaisaController = TextEditingController(
        text: user?.paymentPreferences.easypaisa ?? '');
    _jazzcashController = TextEditingController(
        text: user?.paymentPreferences.jazzcash ?? '');
    _userType = user?.userType ?? 'passenger';
    _acceptsCash = user?.paymentPreferences.acceptsCash ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _easypaisaController.dispose();
    _jazzcashController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final currentUser = ref.read(currentUserProvider).valueOrNull;
      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: _userType,
        paymentPreferences: PaymentPreferences(
          easypaisa: _easypaisaController.text.trim().isEmpty
              ? null
              : _easypaisaController.text.trim(),
          jazzcash: _jazzcashController.text.trim().isEmpty
              ? null
              : _jazzcashController.text.trim(),
          acceptsCash: _acceptsCash,
        ),
      );

      await ref.read(currentUserProvider.notifier).updateProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // User Type
              Text('I want to',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'passenger', label: Text('Find Rides')),
                  ButtonSegment(
                      value: 'driver', label: Text('Offer Rides')),
                  ButtonSegment(value: 'both', label: Text('Both')),
                ],
                selected: {_userType},
                onSelectionChanged: (v) =>
                    setState(() => _userType = v.first),
              ),
              const SizedBox(height: 20),

              // Payment Preferences
              Text('Payment Preferences',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text('Accept Cash'),
                value: _acceptsCash,
                onChanged: (v) => setState(() => _acceptsCash = v),
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _easypaisaController,
                label: 'Easypaisa Number (optional)',
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _jazzcashController,
                label: 'JazzCash Number (optional)',
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
