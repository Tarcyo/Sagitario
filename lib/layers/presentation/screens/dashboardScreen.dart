import 'package:fl_chart/fl_chart.dart';


import 'package:flutter/material.dart';

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
