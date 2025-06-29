import 'package:flutter/material.dart';
import 'package:sagitario/tabbar.dart';

void main() => runApp(SagitarioApp());

class SagitarioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
      ),
      fontFamily: "Quicksand",
    ),
      title: 'Sagitário',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isMobile = width < 600;

    return Scaffold(
      // Estende o corpo por trás das barras do sistema
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Imagem de fundo ocupando toda a tela, até barra superior e inferior
          Positioned.fill(
            child: Image.asset(
              isMobile ? 'assets/fundo.png' : 'assets/fundo2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Conteúdo principal com padding considerando barras do sistema
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Aqui ficará a logo!",style: TextStyle(color: Colors.white),),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 48,
                      vertical: isMobile ? 24 : 32,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? width * 0.9 : 400,
                      ),
                      child: _buildLoginCard(context, isMobile),
                    ),
                  ),
                ),
                Text("   "),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 24 : 32,
          horizontal: isMobile ? 24 : 32,
        ),
        decoration: BoxDecoration(
          color: Colors.lightBlue.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login_rounded,
              size: isMobile ? 40 : 48,
              color: Colors.white.withOpacity(0.9),
            ),
            SizedBox(height: 8),
            Text(
              'Login',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isMobile ? 28 : 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            _buildGlassTextField(
              hint: 'E-mail',
              icon: Icons.email,
              isMobile: isMobile,
            ),
            SizedBox(height: 16),
            _buildGlassTextField(
              hint: 'Senha',
              icon: Icons.lock,
              obscure: true,
              isMobile: isMobile,
            ),
            SizedBox(height: isMobile ? 24 : 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 48 : 60,
                  vertical: isMobile ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.lightBlue.withOpacity(0.18),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 350),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        TelaDoSideBar(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                  ),
                );
              },
              child: Text(
                'Entrar',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String hint,
    required IconData icon,
    bool obscure = false,
    required bool isMobile,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.lightBlue.withOpacity(0.05),
        child: TextField(
          obscureText: obscure,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
          ),
        ),
      ),
    );
  }
}
