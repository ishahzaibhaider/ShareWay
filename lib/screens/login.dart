import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthService>();
    final result = await auth.signInWithEmail(_emailCtrl.text, _passwordCtrl.text);
    
    setState(() => _isLoading = false);

    if (result == AuthResult.success) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in failed. Please check your credentials.')),
        );
      }
    }
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthService>();
    final result = await auth.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      password: _passwordCtrl.text,
    );
    
    setState(() => _isLoading = false);

    if (result == AuthResult.success) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SwBackButton(),
              const SizedBox(height: 28),

              // Logo + Title
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: AppTheme.gradient3D([AppTheme.brandGreen, AppTheme.brandGreenLt]),
                    child: Center(
                      child: Text(
                        'SW',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome Back', style: AppTheme.displayM),
                      Text(
                        'Premium Ride-Sharing Experience',
                        style: AppTheme.caption.copyWith(color: AppTheme.brandGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Tab Bar
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.sand,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppTheme.border),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.textMain,
                  unselectedLabelColor: AppTheme.textSub,
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // ── Sign In Tab ──────────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwFormField(
                          label: 'Email Address',
                          hint: 'you@example.com',
                          icon: Icons.alternate_email_rounded,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        SwFormField(
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          controller: _passwordCtrl,
                          obscureText: _obscurePass,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppTheme.textSub,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.brandGreen,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.outfit(
                                fontSize: 13, fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Sign In'),
                        ),
                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 16),
                        _buildSocialRow(),
                      ],
                    ),

                    // ── Register Tab ─────────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwFormField(
                          label: 'Full Name',
                          hint: 'Aymen Ali',
                          icon: Icons.person_outline_rounded,
                          controller: _nameCtrl,
                        ),
                        const SizedBox(height: 14),
                        SwFormField(
                          label: 'Phone Number',
                          hint: '+92 300 1234567',
                          icon: Icons.phone_outlined,
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        SwFormField(
                          label: 'Email Address',
                          hint: 'you@comsats.edu.pk',
                          icon: Icons.alternate_email_rounded,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        SwFormField(
                          label: 'Password',
                          hint: 'Create a strong password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Create Account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or continue with', style: AppTheme.caption),
        ),
        Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(label: '🍎', onTap: _signIn),
        const SizedBox(width: 14),
        _SocialButton(label: 'G', onTap: _signIn),
        const SizedBox(width: 14),
        _SocialButton(label: '📘', onTap: _signIn),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SocialButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
