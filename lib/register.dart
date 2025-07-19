import 'package:flutter/material.dart';
import 'package:sagitario/servi%C3%A7os/criarUsu%C3%A1rio.dart';
import 'package:flutter_svg/svg.dart';
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _selectedRole = 'student';

  // Controllers para capturar os valores dos campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isMobile = width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isMobile ? 'assets/fundo.png' : 'assets/fundo2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                   Center(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: 200,
                    height: 200,
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
              Icons.person_add_rounded,
              size: isMobile ? 40 : 48,
              color: Colors.white.withOpacity(0.9),
            ),
            SizedBox(height: 8),
            Text(
              'Criar Conta',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isMobile ? 28 : 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            _buildGlassTextField(
              controller: _emailController,
              hint: 'E-mail',
              icon: Icons.email,
              isMobile: isMobile,
            ),
            SizedBox(height: 16),
            _buildGlassTextField(
              controller: _nomeController,
              hint: 'Nome',
              icon: Icons.person_3_rounded,
              isMobile: isMobile,
            ),
            SizedBox(height: 16),
            _buildGlassTextField(
              controller: _passwordController,
              hint: 'Senha',
              icon: Icons.lock,
              obscure: true,
              isMobile: isMobile,
            ),
            SizedBox(height: 16),
            _buildGlassTextField(
              controller: _phoneController,
              hint: 'Fone',
              icon: Icons.phone,
              isMobile: isMobile,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'student',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      activeColor: Colors.white,
                    ),
                    Text('student', style: TextStyle(color: Colors.white)),
                  ],
                ),
                SizedBox(width: 24),
                Row(
                  children: [
                    Radio<String>(
                      value: 'teacher',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      activeColor: Colors.white,
                    ),
                    Text('teacher', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
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
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                );

                try {
                  final authService = AuthService();
                  final user = await authService.createUser(
                    email: _emailController.text,
                    name: _nomeController.text,
                    password: _passwordController.text,
                    type: _selectedRole, // ex: 'student' ou 'teacher'
                    phone: _phoneController.text,
                  );

                  Navigator.of(context).pop(); // fecha loader

                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Sucesso'),
                      content: Text(
                        'Conta criada com sucesso!\nID: ${user.id}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // aqui você pode navegar para a tela principal do app
                          },
                          child: Text('Ir para App'),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // fecha loader

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Erro'),
                      content: Text(
                        'Não foi possível criar a conta.\nErro: $e',
                      ),
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
              child: Text(
                'Criar Conta',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop("mkmkfdlmas");
              },
              child: Text(
                'Já possui conta?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isMobile ? 14 : 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
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
          controller: controller,
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
