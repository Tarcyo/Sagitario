// Flutter sidebar with responsive tabbar text size
import 'package:flutter/material.dart';
import 'package:sagitario/telaDeRegistro.dart';
import 'package:fl_chart/fl_chart.dart';
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

class GeolocalizacaoScreen extends StatefulWidget {
  @override
  _GeolocalizacaoScreenState createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen>
    with SingleTickerProviderStateMixin {
  bool _activated = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
          lowerBound: 0.95,
          upperBound: 1.05,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _pulseController.forward();
          }
        });
    _pulseController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleActivation() {
    setState(() => _activated = !_activated);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _activated
              ? [Colors.transparent, Colors.transparent]
              : [Colors.transparent, Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Geolocalização',
                style: TextStyle(fontSize: 60, color: Colors.white),
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _pulseController,
                child: GestureDetector(
                  onTap: _toggleActivation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: _activated
                          ? Colors.redAccent.shade200
                          : Colors.greenAccent.shade400,

                      boxShadow: [
                        BoxShadow(
                          color: _activated
                              ? Colors.redAccent.withOpacity(0.7)
                              : Colors.greenAccent.withOpacity(0.7),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              RotationTransition(
                                turns: animation,
                                child: child,
                              ),
                          child: Icon(
                            _activated ? Icons.location_off : Icons.location_on,
                            key: ValueKey<bool>(_activated),
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _activated ? 'Desativar' : 'Ativar',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  String _selectedStudent = 'Todos';
  final List<String> _students = ['Todos', 'Aluno A', 'Aluno B', 'Aluno C'];

  late AnimationController _bgController;
  late Animation<List<Color>> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _bgAnimation = TweenSequence<List<Color>>([
      TweenSequenceItem(
        tween: ConstantTween([Colors.transparent, Colors.transparent]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween([Colors.transparent, Colors.transparent]),
        weight: 1,
      ),
    ]).animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _bgAnimation.value,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                // Apply white as default text color and Goldman font for all descendants
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Goldman',
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Goldman', // explicit for clarity
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildOverviewCards(),
                      const SizedBox(height: 24),
                      _buildStudentSelector(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _selectedStudent == 'Todos'
                            ? _buildGeneralInsights()
                            : _buildStudentDetail(_selectedStudent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _infoCardWithChart(
            title: 'Média de Presença Mensal',
            chart: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(1, 82),
                      FlSpot(2, 85),
                      FlSpot(3, 88),
                      FlSpot(4, 90),
                      FlSpot(5, 87),
                      FlSpot(6, 92),
                    ],
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    barWidth: 3,
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Fev',
                          'Mar',
                          'Abr',
                          'Mai',
                          'Jun',
                        ];
                        final i = value.toInt() - 1;
                        if (i < 0 || i >= months.length)
                          return SizedBox.shrink();
                        return Text(
                          months[i],
                          style: TextStyle(
                            color: Colors.blue.withOpacity(0.7),
                            fontSize: 10,
                            fontFamily: 'Goldman',
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 10),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _infoCardWithChart(
            title: 'Taxa de Atrasos (%)',
            chart: BarChart(
              BarChartData(
                barGroups: List.generate(
                  6,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: [5, 8, 3, 6, 4, 7][i].toDouble(),
                        width: 12,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const mths = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
                        return Text(
                          mths[v.toInt()],
                          style: TextStyle(
                            color: Colors.blue.withOpacity(0.7),
                            fontSize: 10,
                            fontFamily: 'Goldman',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _infoCardWithChart(
            title: 'Disciplinas Ativas',
            chart: PieChart(
              PieChartData(
                centerSpaceRadius: 20,
                sections: [
                  PieChartSectionData(value: 3, title: 'Math'),
                  PieChartSectionData(value: 4, title: 'Sci'),
                  PieChartSectionData(value: 2, title: 'Eng'),
                ],
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _infoMetricCard('Total de Aulas', '180'),
          const SizedBox(width: 16),
          _infoMetricCard('Participação Média', '72%'),
        ],
      ),
    );
  }

  Widget _infoCardWithChart({required String title, required Widget chart}) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.withOpacity(0.7),
              fontFamily: 'Goldman',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 140, child: chart),
        ],
      ),
    );
  }

  Widget _infoMetricCard(String title, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.withOpacity(0.7),
              fontFamily: 'Goldman',
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Goldman',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(32),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.white, fontFamily: 'Goldman'),
          dropdownColor: Colors.blue.withOpacity(0.9),
          value: _selectedStudent,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          items: _students
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s, style: const TextStyle(fontFamily: 'Goldman')),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedStudent = v!),
        ),
      ),
    );
  }

  Widget _buildGeneralInsights() {
    return Center(
      child: Text(
        'Visão geral do professor: média mensal, atrasos e disciplinas ativas.',
        style: const TextStyle(fontSize: 18, fontFamily: 'Goldman'),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStudentDetail(String aluno) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relatório de \$aluno',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Goldman',
            ),
          ),
          const SizedBox(height: 16),
          _infoCardWithChart(
            title: 'Presença por Mês',
            chart: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      6,
                      (i) => FlSpot(i.toDouble(), (60 + i * 5).toDouble()),
                    ),
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _infoCardWithChart(
            title: 'Atrasos Mensais',
            chart: BarChart(
              BarChartData(
                barGroups: List.generate(
                  6,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: [2, 4, 3, 5, 1, 3][i].toDouble(),
                        width: 12,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _infoCardWithChart(
            title: 'Tempo de Aula (min)',
            chart: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 30, title: '≤30m'),
                  PieChartSectionData(value: 50, title: '30-60m'),
                  PieChartSectionData(value: 20, title: '>60m'),
                ],
                centerSpaceRadius: 20,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
