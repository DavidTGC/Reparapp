import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'logged_user';

  // Simular login - en versión real conectaría a backend
  Future<bool> login(String email, String password) async {
    try {
      // Simulación de autenticación
      if (email.isNotEmpty && password.isNotEmpty) {
        final user = User(
          id: '1',
          name: 'Operario Prueba',
          email: email,
          phone: '600123456',
          profession: 'General',
        );

        await saveUser(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  // Guardar usuario localmente
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = user.toJson();
    await prefs.setString(_userKey, userJson.toString());
  }

  // Obtener usuario guardado
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      // En una versión real, deserializaría el JSON
      return User(
        id: '1',
        name: 'Operario Prueba',
        email: 'operario@reparapp.com',
        phone: '600123456',
        profession: 'General',
      );
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Verificar si hay usuario logueado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }
}
