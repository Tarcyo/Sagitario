// lib/screens/dashboard_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:sagitario/layers/presentation/providers/authProvider.dart'; // Ajuste este import para o caminho real do seu AuthProvider

const String baseUrl = 'https://final-ifg-backend.onrender.com';

/// MODELS
class Discipline {
  final String id;
  final String name;
  Discipline({required this.id, required this.name});
  factory Discipline.fromJson(Map<String, dynamic> j) {
    return Discipline(id: j['id'] as String, name: j['name'] as String);
  }
}

class StudentReport {
  final String name;
  final int quantidadeFaltas;
  final String porcentagemPresenca;
  final String statusAluno;
  StudentReport({
    required this.name,
    required this.quantidadeFaltas,
    required this.porcentagemPresenca,
    required this.statusAluno,
  });
  factory StudentReport.fromJson(Map<String, dynamic> j) {
    return StudentReport(
      name: j['name'] ?? '',
      quantidadeFaltas: (j['quantidade_faltas'] ?? 0) as int,
      porcentagemPresenca: j['porcentagem_presenca']?.toString() ?? '0.00',
      statusAluno: j['status_aluno'] ?? '',
    );
  }
}

class GeneralCharts {
  final int totalAulasMinistradasNum;
  final String totalAulasMinistradasPct;
  final String presencaMedia;
  final Map<String, dynamic> alunosPorStatus;
  final Map<String, dynamic> aulasStatus;
  GeneralCharts({
    required this.totalAulasMinistradasNum,
    required this.totalAulasMinistradasPct,
    required this.presencaMedia,
    required this.alunosPorStatus,
    required this.aulasStatus,
  });
  factory GeneralCharts.fromJson(Map<String, dynamic> j) {
    return GeneralCharts(
      totalAulasMinistradasNum: (j['total_aulas_ministradas_num'] ?? 0) as int,
      totalAulasMinistradasPct: j['total_aulas_ministradas_pct']?.toString() ?? '0.00',
      presencaMedia: j['presenca_media']?.toString() ?? '0.00',
      alunosPorStatus: Map<String, dynamic>.from(j['alunos_por_status'] ?? {}),
      aulasStatus: Map<String, dynamic>.from(j['aulas_status'] ?? {}),
    );
  }
}

class DisciplineReport {
  final String disciplinaNome;
  final int totalAlunos;
  final List<StudentReport> tabelaAlunos;
  final GeneralCharts graficosGerais;
  DisciplineReport({
    required this.disciplinaNome,
    required this.totalAlunos,
    required this.tabelaAlunos,
    required this.graficosGerais,
  });
  factory DisciplineReport.fromJson(Map<String, dynamic> j) {
    final tabela = (j['tabela_alunos'] as List<dynamic>?)
            ?.map((e) => StudentReport.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return DisciplineReport(
      disciplinaNome: j['disciplina_nome'] ?? '',
      totalAlunos: (j['total_alunos'] ?? 0) as int,
      tabelaAlunos: tabela,
      graficosGerais: GeneralCharts.fromJson(
        Map<String, dynamic>.from(j['graficos_gerais'] ?? {}),
      ),
    );
  }
}

/// DASHBOARD SCREEN
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  // estado
  bool _loadingDisciplines = true;
  bool _loadingReport = false;
  List<Discipline> _disciplines = [];
  Discipline? _selected;
  DisciplineReport? _report;
  String? _error;

  // animação sutil para header/cards
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDisciplines(context);
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadDisciplines(BuildContext c) async {
    setState(() {
      _loadingDisciplines = true;
      _error = null;
    });
    try {
      final token = Provider.of<AuthProvider>(c, listen: false).token!;
      final url = Uri.parse('$baseUrl/discipline');
      final resp = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final List<dynamic> list = json.decode(resp.body) as List<dynamic>;
        final discs = list
            .map((e) => Discipline.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        setState(() {
          _disciplines = discs;
          _selected = discs.isNotEmpty ? discs.first : null;
        });
        if (_selected != null) await _loadReportForDiscipline(c, _selected!.id);
      } else {
        setState(
          () => _error = 'Erro ao buscar disciplinas: ${resp.statusCode}',
        );
      }
    } catch (e) {
      setState(() => _error = 'Erro ao buscar disciplinas: $e');
    } finally {
      setState(() => _loadingDisciplines = false);
    }
  }

  Future<void> _loadReportForDiscipline(
    BuildContext c,
    String disciplineId,
  ) async {
    setState(() {
      _loadingReport = true;
      _error = null;
      _report = null;
    });
    try {
      final token = Provider.of<AuthProvider>(c, listen: false).token!;
      final url = Uri.parse('$baseUrl/report/discipline/$disciplineId');
      final resp = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final Map<String, dynamic> j = json.decode(resp.body) as Map<String, dynamic>;
        final report = DisciplineReport.fromJson(j);
        setState(() => _report = report);
      } else if (resp.statusCode == 404) {
        setState(
          () => _error = 'Relatório não encontrado para essa disciplina.',
        );
      } else {
        setState(() => _error = 'Erro ao buscar relatório: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Erro ao buscar relatório: $e');
    } finally {
      setState(() => _loadingReport = false);
    }
  }

  // modal de seleção pesquisável (melhor UX do dropdown)
  Future<void> _showDisciplinePicker(BuildContext c) async {
    await showModalBottomSheet(
      context: c,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return _DisciplinePickerSheet(
              disciplines: _disciplines,
              controller: controller,
              onSelected: (d) {
                Navigator.of(context).pop();
                setState(() => _selected = d);
                _loadReportForDiscipline(c, d.id);
              },
            );
          },
        );
      },
    );
  }

  // WIDGETS DE UI
  Widget _buildCurvedHeader() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_animController.value);
        return ClipPath(
          clipper: _HeaderClipper(),
          child: Container(
            height: 188 * (0.9 + 0.1 * t),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Painel de Relatórios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selected?.name ?? 'Selecione uma disciplina',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _loadDisciplines(context),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Recarregar dados',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // cartão de seleção
          Expanded(
            child: GestureDetector(
              onTap: () => _showDisciplinePicker(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book_outlined, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _loadingDisciplines
                          ? const SizedBox(
                              height: 18,
                              child: LinearProgressIndicator(),
                            )
                          : Text(
                              _selected?.name ?? 'Selecionar disciplina',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _selected == null ? null : () => _loadReportForDiscipline(context, _selected!.id),
            icon: const Icon(Icons.insights_outlined),
            label: const Text('Gerar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1), // Cor de fundo
              foregroundColor: Colors.white, // Cor do texto e ícone
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCards(GeneralCharts g) {
    final normal = (g.alunosPorStatus['normal'] ?? 0).toString();
    final risco = (g.alunosPorStatus['risco'] ?? 0).toString();
    final presenca = g.presencaMedia;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Alunos normais',
            normal,
            Icons.people_alt,
            Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Em risco',
            risco,
            Icons.warning_amber_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Presença média',
            presenca + '%',
            Icons.schedule,
            Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPie(GeneralCharts g) {
    final normalPct = double.tryParse(g.alunosPorStatus['normal_pct']?.toString() ?? '0') ?? 0.0;
    final riscoPct = double.tryParse(g.alunosPorStatus['risco_pct']?.toString() ?? '0') ?? 0.0;
    final sections = <PieChartSectionData>[];
    if (normalPct > 0) {
      sections.add(
        PieChartSectionData(
          value: normalPct,
          title: '${normalPct.toStringAsFixed(0)}%',
          radius: 46,
          showTitle: true,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          color: const Color(0xFF4CAF50),
        ),
      );
    }
    if (riscoPct > 0) {
      sections.add(
        PieChartSectionData(
          value: riscoPct,
          title: '${riscoPct.toStringAsFixed(0)}%',
          radius: 46,
          showTitle: true,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          color: const Color(0xFFFF7043),
        ),
      );
    }
    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          value: 1,
          title: '0%',
          radius: 46,
          color: Colors.grey,
        ),
      );
    }
    return Card(
      color: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Distribuição dos alunos',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 26,
                  sectionsSpace: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LegendDot(label: 'Normal', color: Color(0xFF4CAF50)),
                SizedBox(width: 14),
                _LegendDot(label: 'Risco', color: Color(0xFFFF7043)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(GeneralCharts g) {
    final ministradas = (g.aulasStatus['ministradas_num'] ?? 0).toDouble();
    final canceladas = (g.aulasStatus['canceladas_num'] ?? 0).toDouble();
    final restantes = (g.aulasStatus['restantes_num'] ?? 0).toDouble();
    final maxVal = [
      ministradas,
      canceladas,
      restantes,
    ].reduce((a, b) => a > b ? a : b);
    final top = (maxVal < 1) ? 1.0 : maxVal * 1.2;
    return Card(
      color: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Status das aulas',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: top,
                  // linhas de grade (grid)
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  // borda do gráfico (linhas externas)
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          // formata os valores do eixo Y em inteiro quando possível
                          final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              text,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final map = {
                            0: 'Ministradas',
                            1: 'Canceladas',
                            2: 'Restantes',
                          };
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              map[value.toInt()] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: ministradas,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: canceladas,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: restantes,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTable(List<StudentReport> students) {
    if (students.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Nenhum aluno encontrado.', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return Card(
      color: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.05)),
          columns: const [
            DataColumn(label: Text('Aluno', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Faltas', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('% Presença', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
          ],
          rows: students.map((s) {
            return DataRow(
              cells: [
                DataCell(Text(s.name, style: const TextStyle(color: Colors.white))),
                DataCell(Text(s.quantidadeFaltas.toString(), style: const TextStyle(color: Colors.white))),
                DataCell(Text(s.porcentagemPresenca, style: const TextStyle(color: Colors.white))),
                DataCell(_statusChip(s.statusAluno)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final lower = status.toLowerCase();
    Color color = Colors.grey;
    String label = status;
    if (lower.contains('risk') || lower.contains('ris')) {
      color = Colors.orange;
      label = 'Em risco';
    } else if (lower.contains('normal')) {
      color = Colors.green;
      label = 'Normal';
    } else if (lower.contains('at_risk') || lower.contains('at risk')) {
      color = Colors.orange;
      label = 'Em risco';
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  // BUILD PRINCIPAL
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildCurvedHeader(),
            _buildTopControls(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error ?? 'Erro',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _loadDisciplines(context),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _loadingReport ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
                onRefresh: () async {
                  if (_selected != null) await _loadReportForDiscipline(
                    context,
                    _selected!.id,
                  );
                },
                child: _report == null
                    ? ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        children: [
                          const SizedBox(height: 32),
                          // placeholders bonitinhos enquanto sem seleção
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Selecione uma disciplina para gerar o relatório',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Card(
                                  color: Colors.blue.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _report!.disciplinaNome,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Alunos: ${_report!.totalAlunos}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Aulas ministradas: ${_report!.graficosGerais.totalAulasMinistradasNum} (${_report!.graficosGerais.totalAulasMinistradasPct}%)',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: _buildMiniCards(
                                  _report!.graficosGerais,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: _buildPie(_report!.graficosGerais),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: _buildBar(_report!.graficosGerais),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tabela de alunos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStudentsTable(_report!.tabelaAlunos),
                          const SizedBox(height: 18),
                          Card(
                            color: Colors.blue.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Dados gerados pelo servidor para ${_report!.disciplinaNome}. Última atualização ao carregar o relatório.',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _loadReportForDiscipline(
                                      context,
                                      _selected!.id,
                                    ),
                                    child: const Text('Atualizar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PICKER SHEET (lista pesquisável)
class _DisciplinePickerSheet extends StatefulWidget {
  final List<Discipline> disciplines;
  final ScrollController controller;
  final ValueChanged<Discipline> onSelected;
  const _DisciplinePickerSheet({
    Key? key,
    required this.disciplines,
    required this.controller,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<_DisciplinePickerSheet> createState() => _DisciplinePickerSheetState();
}

class _DisciplinePickerSheetState extends State<_DisciplinePickerSheet> {
  late List<Discipline> filtered;
  final TextEditingController _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    filtered = widget.disciplines;
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() {
        filtered = widget.disciplines
            .where((d) => d.name.toLowerCase().contains(q))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                hintText: 'Pesquisar disciplinas...',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.blue.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: widget.disciplines.isEmpty
                ? const Center(child: Text('Nenhuma disciplina disponível.', style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    controller: widget.controller,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final d = filtered[i];
                      return ListTile(
                        title: Text(d.name, style: const TextStyle(color: Colors.white)),
                        leading: const Icon(Icons.book, color: Colors.white),
                        onTap: () => widget.onSelected(d),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// small legend widget
class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({Key? key, required this.label, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }
}

/// clipper para header curvo elegante
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final h = size.height;
    final w = size.width;
    final path = Path();
    path.lineTo(0, h - 40);
    path.quadraticBezierTo(w * 0.25, h, w * 0.5, h - 40);
    path.quadraticBezierTo(w * 0.75, h - 80, w, h - 40);
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
