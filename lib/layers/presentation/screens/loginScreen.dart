
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:sagitario/layers/presentation/providers/authProvider.dart';
import 'package:sagitario/layers/presentation/screens/createAccount.dart';
import 'package:sagitario/tabbar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final emailCOntroller = TextEditingController();
  final sennhaCOntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isMobile = width < 600;

    return Scaffold(
      // Estende o corpo por trás das barras do sistema
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
                Center(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: 300,
                    height: 300,
                  ),
                ),
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
              controller: emailCOntroller,
              hint: 'E-mail',
              icon: Icons.email,
              isMobile: isMobile,
            ),
            SizedBox(height: 16),
            _buildGlassTextField(
              controller: sennhaCOntroller,
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
              onPressed: () async {
                final uri = Uri.parse('https://sistema-de-login-final.onrender.com/auth/login');
                final headers = {'Content-Type': 'application/json'};
                final body = jsonEncode({
                  'email': emailCOntroller.text,
                  'password': sennhaCOntroller.text,
                });

                final response = await http.post(
                  uri,
                  headers: headers,
                  body: body,
                );

                                  print("A resposta é: "+response.body.toString());


                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);


                  // 1) Obtém o AuthProvider (listen: false pois não precisa rebuildar aqui)
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  // 2) Seta o token dentro do provider
                  auth.token = data['token'];

                  // 3) Navega para a próxima tela
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 350),
                      pageBuilder: (ctx, anim, secAnim) => TelaDoSideBar(),
                      transitionsBuilder: (ctx, anim, secAnim, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                } else {
                  final errorMsg = response.statusCode == 401
                      ? 'Email ou senha incorretos.'
                      : 'Erro ${response.statusCode}: ${response.body}';
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Falha no Login'),
                      content: Text(errorMsg),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Login',style: TextStyle(color: Colors.white),),
            ),
            // Aqui adicionamos o texto "Não possui conta?"
            SizedBox(height: isMobile ? 16 : 24),
            GestureDetector(
              onTap: () {
                // lógica para ir à tela de cadastro, se houver
              },
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 350),
                      pageBuilder: (ctx, anim, secAnim) => RegisterScreen(),
                      transitionsBuilder: (ctx, anim, secAnim, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                child: Text(
                  'Não possui conta?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : 16,
                    decoration: TextDecoration.underline,
                  ),
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
    required controller,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.lightBlue.withOpacity(0.05),
        child: TextField(
          obscureText: obscure,
          controller: controller,
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
