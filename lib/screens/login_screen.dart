import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  String? _emailError;
  String? _passwordError;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = null;
      } else if (!_isValidEmail(email)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordError = null;
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  PasswordStrength _getPasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 10) {
      if (password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[0-9]'))) {
        return PasswordStrength.good;
      }
      return PasswordStrength.weak;
    }
    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      return PasswordStrength.strong;
    }
    return PasswordStrength.good;
  }

  void _handleLogin() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    _attemptLogin(email, password);
  }

  Future<void> _attemptLogin(String email, String password) async {
    try {
      final authService = AuthService();
      final result = await authService.signIn(email: email, password: password);

      if (result['success'] == true) {
        if (mounted) {
          final role = result['role'] ?? 'student';
          Navigator.of(context).pushReplacementNamed('/loading', arguments: role);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = result['error'] ?? 'Email or password is incorrect';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred. Please try again later.';
        });
      }
      print('Login error: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Logo Section
                  Center(
                    child: Column(
                      children: [
                        Hero(
                          tag: 'logo',
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'VIDYASARATHI',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Academic Management System',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMid,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Welcome Section
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Sign in to access your dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Error Alert
                  if (_errorMessage != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_rounded,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_errorMessage != null) const SizedBox(height: 20),

                  // Email Input Field
                  _buildInputField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    label: 'Email Address',
                    hint: 'student@vidya.com',
                    icon: Icons.email_outlined,
                    isLoading: _isLoading,
                    error: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Password Input Field
                  _buildPasswordField(),

                  if (_passwordController.text.isNotEmpty && !_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _buildPasswordStrengthIndicator(
                        _getPasswordStrength(_passwordController.text),
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _isLoading ? null : () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _rememberMe
                                      ? AppColors.primary
                                      : AppColors.textLight.withOpacity(0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                color: _rememberMe ? AppColors.primary : Colors.transparent,
                              ),
                              child: _rememberMe
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMid,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset link sent to your email'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: _isLoading ? 0 : 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Signing In...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),



                  // Footer
                  const Center(
                    child: Text(
                      'Secure login powered by Supabase',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isLoading,
    String? error,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) => setState(() {}),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isLoading,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textLight.withOpacity(0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: error != null ? Colors.red.withOpacity(0.05) : Colors.white,
              prefixIcon: Icon(
                icon,
                color: error != null ? Colors.red : AppColors.primary,
                size: 20,
              ),
              suffixIcon: error != null
                  ? Icon(
                      Icons.error_rounded,
                      color: Colors.red.withOpacity(0.7),
                      size: 18,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null ? Colors.red.withOpacity(0.3) : Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null ? Colors.red.withOpacity(0.3) : Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null ? Colors.red.withOpacity(0.5) : AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              errorText: null,
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) => setState(() {}),
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            enabled: !_isLoading,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(
                color: AppColors.textLight.withOpacity(0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: _passwordError != null ? Colors.red.withOpacity(0.05) : Colors.white,
              prefixIcon: Icon(
                Icons.lock_outlined,
                color: _passwordError != null ? Colors.red : AppColors.primary,
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _passwordError != null ? Colors.red.withOpacity(0.3) : Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _passwordError != null ? Colors.red.withOpacity(0.3) : Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _passwordError != null ? Colors.red.withOpacity(0.5) : AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              errorText: null,
            ),
          ),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _passwordError!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(PasswordStrength strength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength.index / 2,
                  minHeight: 4,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    strength == PasswordStrength.weak
                        ? Colors.red
                        : strength == PasswordStrength.good
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              strength == PasswordStrength.weak
                  ? 'Weak'
                  : strength == PasswordStrength.good
                      ? 'Good'
                      : 'Strong',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strength == PasswordStrength.weak
                    ? Colors.red
                    : strength == PasswordStrength.good
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum PasswordStrength { weak, good, strong }
