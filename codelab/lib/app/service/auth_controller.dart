import 'package:codelab/app/modules/login/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs = Get.find<SharedPreferences>();
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    isLoggedIn.value = _prefs.containsKey('user_token');
  }

  Future<void> registerUser(String email, String password, String name) async {
    try {
      isLoading.value = true;
      // Buat akun baru dengan email dan password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Dapatkan pengguna yang terautentikasi
      User? user = userCredential.user;

      // Perbarui nama pengguna jika registrasi berhasil
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        user = _auth.currentUser;
      }

      // Tampilkan snackbar sukses
      Get.snackbar(
        'Success',
        'Registration Successful',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      // Pindah ke halaman login
      Get.off(LoginView());
    } catch (error) {
      Get.snackbar(
        'Error',
        'Registration Failed: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      // Set loading menjadi true saat proses login dimulai
      isLoading.value = true;

      // Melakukan proses login dengan email dan password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _prefs.setString('user_token', _auth.currentUser!.uid);
      // Tampilkan snackbar jika login berhasil
      Get.snackbar(
        'Success',
        'Login successful',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
    } catch (error) {
      // Tampilkan snackbar jika terjadi error saat login
      Get.snackbar(
        'Error',
        'Login failed Email and Password Incorrect',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      // Set loading menjadi false saat proses login selesai
      isLoading.value = false;
    }
  }

// ...
  void logout() async {
    _prefs.remove('user_token');
    isLoggedIn.value = false;
    _auth.signOut();
    Get.offAllNamed('/login'); // Menghapus semua halaman dari stack dan
  }
}
