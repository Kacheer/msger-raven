import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/remote/api_client.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data is Map) {
        final userId = response.data['userId'];
        final token = response.data['token'];

        if (userId != null && token != null) {
          apiClient.setCurrentUserId(userId.toString());
          apiClient.setToken(token.toString());

          if (mounted) {
            widget.onLoginSuccess();
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkButtonBg : AppTheme.lightButtonBg;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Логотип - используем иконку вместо изображения
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_rounded,
                        size: 80,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Raven',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Заголовок
                Text(
                  'Вход',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Платформа Безопасного Общения',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? AppTheme.darkAccent : AppTheme.lightAccent,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                // Email поле
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Введите ваш email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Пароль поле
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    hintText: 'Введите свой пароль',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Кнопка входа
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Вход'),
                ),
                const SizedBox(height: 16),

                // Ссылка на регистрацию
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Нет аккаунта? '),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                      child: const Text('Зарегистрируйтесь'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
