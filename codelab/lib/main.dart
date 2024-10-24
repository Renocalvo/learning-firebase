import 'package:codelab/app/modules/home/views/Home_view.dart';
import 'package:codelab/app/modules/login/views/login_view.dart';
import 'package:codelab/app/modules/register/views/register_view.dart';
import 'package:codelab/app/service/auth_controller.dart';
import 'package:codelab/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import your routes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Get.putAsync(() async => await SharedPreferences.getInstance());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthController _authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: _authController.isLoggedIn.value ? '/login' : '/home',
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/home', page: () => HomeView()),
        GetPage(name: '/register', page: () => RegisterView())
      ],
    );
  }
}
