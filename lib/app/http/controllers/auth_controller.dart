import 'package:tugas_api/app/models/user.dart';
import 'package:vania/vania.dart';

class AuthController extends Controller {
  Future<Response> register(Request request) async {
    try {
      var name = request.input('name');
      var email = request.input('email');
      var password = request.input('password');

      if (name == null || email == null || password == null) {
        return Response.json({
          'success': false,
          'message': 'Harus masukkan nama, email dan password!',
        });
      }

      var isEmailExist =
          await User().query().where('email', '=', email).first();
      if (isEmailExist != null) {
        return Response.json({
          'succes': false,
          'message': 'Email sudah ada',
        });
      }

      final passwordHashed = Hash().make(password);
      var user = await User().query().create({
        'name': name,
        'email': email,
        'password': passwordHashed,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return Response.json(
          {'success': true, 'message': 'User berhasil register', 'data': user});
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'User gagal register',
        'error': e.toString()
      });
    }
  }

  Future<Response> login(Request request) async {
    try {
      final email = request.input('email');
      final password = request.input('password');

      if (email == null || password == null) {
        return Response.json({
          'success': false,
          'message': 'Harus masukkan email dan password!',
        });
      }

      final user = await User().query().where('email', '=', email).first();
      if (user == null) {
        return Response.json({
          'success': false,
          'message': 'User atau password tidak tepat!',
        });
      }

      // cek password menggunakan hash
      final isPasswordMatch = Hash().verify(password, user['password']);
      if (!isPasswordMatch) {
        return Response.json({
          'success': false,
          'message': 'User or password is incorrect',
        });
      }

      final token = await Auth()
          .login(user)
          .createToken(expiresIn: Duration(hours: 24), withRefreshToken: true);

      return Response.json({
        'success': true,
        'message': 'Berhasil Login',
        'data': {
          'user': user,
          'token': token,
        }
      });
    } catch (e) {
      return Response.json(
          {'success': false, 'message': 'Login gagal', 'error': e.toString()});
    }
  }

  Future<Response> logout(Request request) async {
    try {
      final token = request.header('Authorization');
      if (token == null) {
        return Response.json({
          'success': false,
          'message': 'Dibutuhkan token',
        });
      }

      final isValidToken = await Auth().check(token);
      if (!isValidToken) {
        return Response.json(
            {'success': false, 'message': 'Token tidak cocok'});
      }

      await Auth().deleteTokens();

      return Response.json({'success': true, 'message': 'Berhasil logout'});
    } catch (e) {
      return Response.json(
          {'success': false, 'message': 'Gagal logout', 'error': e.toString()});
    }
  }
}

final AuthController authController = AuthController();
