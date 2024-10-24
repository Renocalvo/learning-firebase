import 'package:codelab/app/service/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../routes/app_pages.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isRemembered = false;
  bool _isSecurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routes.LOGIN);
            },
            icon: Icon(Ionicons.arrow_back),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(25, 0, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        'Selamat datang',
                        style: GoogleFonts.redressed(
                            fontSize: 35,
                            color: Color.fromARGB(255, 0, 0, 255)),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      25, 0, 0, 0), // Set your desired margin here
                  child: Row(
                    children: [
                      Text('Belum Punya Akun?'),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(Routes
                              .REGISTER); // Add your onPressed functionality here
                        },
                        child: Text('Daftar'),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _isSecurePassword,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        suffixIcon: togglePassword()),
                  ),
                ),
                CheckboxListTile(
                  title: Text("Remember Me"),
                  value: _isRemembered,
                  onChanged: (bool? value) {
                    setState(() {
                      _isRemembered = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                      gradient:
                          LinearGradient(colors: [Colors.blue, Colors.black]),
                      borderRadius: BorderRadius.circular(25)),
                  child: ElevatedButton(
                    onPressed: _authController.isLoading.value
                        ? null
                        : () {
                            _authController.loginUser(_emailController.text,
                                _passwordController.text);
                          },
                    child: _authController.isLoading.value
                        ? CircularProgressIndicator()
                        : Text(
                            'Masuk',
                            style: TextStyle(color: Colors.white),
                          ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent),
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget togglePassword() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isSecurePassword = !_isSecurePassword;
        });
      },
      icon: _isSecurePassword
          ? Icon(Icons.visibility)
          : Icon(Icons.visibility_off),
      color: Colors.grey,
    );
  }
}
