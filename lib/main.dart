import 'package:flutter/material.dart';
import 'package:sagitario/layers/core/inject/inject.dart';
import 'package:sagitario/layers/presentation/providers/authProvider.dart';
import 'package:sagitario/layers/presentation/providers/locationProvider.dart';
import 'package:sagitario/layers/presentation/screens/loginScreen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async{


    WidgetsFlutterBinding.ensureInitialized();

  await initInjection();




  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: SagitarioApp(),
    ),
  );
}

class SagitarioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sagitário',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Goldman",
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "Goldman",
            fontWeight: FontWeight.w600,
          ),
          toolbarTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: "Goldman",
          ),
          color: Colors.blueAccent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      home: LoginScreen(),
    );
  }
}
