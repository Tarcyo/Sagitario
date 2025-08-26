// Flutter sidebar with responsive tabbar text size
import 'package:flutter/material.dart';
import 'package:sagitario/layers/presentation/screens/GeoScreen.dart';
import 'package:sagitario/layers/presentation/screens/dashboardScreen.dart';
import 'package:sagitario/layers/presentation/screens/registerScreen.dart';
import 'package:flutter_svg/svg.dart';

class AlunoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Tela de Geolocalização', style: _screenTextStyle));
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Configurações Screen', style: _screenTextStyle));
}

// Estilo comum para o texto das telas
const _screenTextStyle = TextStyle(fontSize: 32, color: Colors.white);

class TelaDoSideBar extends StatefulWidget {
  @override
  _TelaDoSideBarState createState() => _TelaDoSideBarState();
}

class _TelaDoSideBarState extends State<TelaDoSideBar> {
  int _selectedIndex = 0;

  final List<IconData> _icons = [
    Icons.app_registration_rounded,
    Icons.room_rounded,
    Icons.dashboard_rounded,
  ];
  final List<String> _labels = ['Registro', 'Local', 'Painel'];
  final IconData _logoutIcon = Icons.logout_rounded;
  final String _logoutLabel = 'Sair';

  final List<Widget> _screens = [
    TelaDeRegistro(),
    GeolocalizacaoScreen(),
    DashboardScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Fundo compartilhado
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isMobile
                    ? AssetImage('assets/fundo.png')
                    : AssetImage('assets/fundo2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Conteúdo principal
          Positioned.fill(
            child: isMobile ? _buildMobileContent() : _buildDesktopContent(),
          ),
          // TabBar customizada para mobile
          if (isMobile)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...List.generate(
                          _icons.length,
                          (i) => _buildTabItem(context, i),
                        ),
                        _buildTabItem(context, _icons.length, isLogout: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: _buildGlassContainer(
            width: 240,
            child: Column(
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: 300,
                    height: 300,
                  ),
                ),
                SizedBox(height: 24),
                Column(
                  children: List.generate(
                    _icons.length,
                    (i) => _buildSidebarItem(i),
                  ),
                ),
                Spacer(),
                _buildSidebarItem(_icons.length, isLogout: true),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _screens[_selectedIndex],
              layoutBuilder: (current, previous) =>
                  Stack(children: [...previous, if (current != null) current]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 96.0),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 350),
        transitionBuilder: (c, anim) => FadeTransition(opacity: anim, child: c),
        child: _screens[_selectedIndex],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    int index, {
    bool isLogout = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final bool selected = _selectedIndex == index;
    final IconData icon = isLogout ? _logoutIcon : _icons[index];
    final String label = isLogout ? _logoutLabel : _labels[index];
    final double fontSize = isMobile ? 10 : 12;

    return InkWell(
      onTap: () => isLogout ? _onLogout(context) : _onItemTapped(index),
      child: Container(
        width: 48,
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? Colors.lightBlue.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isMobile ? 20 : 24,
              color: Colors.white.withOpacity(selected ? 1 : 0.8),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(selected ? 1 : 0.8),
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, {bool isLogout = false}) {
    final IconData icon = isLogout ? _logoutIcon : _icons[index];
    final String label = isLogout ? _logoutLabel : _labels[index];
    final bool selected = _selectedIndex == index;

    return InkWell(
      onTap: () => isLogout ? _onLogout(context) : _onItemTapped(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8)),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
  void _onLogout(BuildContext context) => Navigator.of(context).pop();

  Widget _buildGlassContainer({required double width, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.lightBlue.withOpacity(0.06),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1.5),
        ),
        child: child,
      ),
    );
  }
}
