import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_widgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (success) {
          // Navegar a la pantalla principal
          Navigator.of(context).pushReplacementNamed('/tasks');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: Email o contraseña incorrectos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el inicio de sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.build_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Título
                  Text(
                    'Reparapp',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gestión de tareas para operarios',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 48),
                  // Email field
                  CustomTextField(
                    label: 'Correo Electrónico',
                    hint: 'operario@ejemplo.com',
                    controller: _emailController,
                    inputType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un correo';
                      }
                      if (!value.contains('@')) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Password field
                  CustomTextField(
                    label: 'Contraseña',
                    hint: 'Ingresa tu contraseña',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  // Login button
                  CustomButton(
                    label: 'Iniciar Sesión',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                    backgroundColor: Colors.blue[600],
                  ),
                  SizedBox(height: 16),
                  // Forgot password link
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar pantalla de recuperación de contraseña
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
