// Flutter sidebar with responsive tabbar text size
import 'package:flutter/material.dart';

// Telas que serão exibidas
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sagitario/providers/authProvider.dart';

class TelaDeRegistro extends StatefulWidget {
  @override
  _TelaDeRegistroState createState() => _TelaDeRegistroState();
}

class _TelaDeRegistroState extends State<TelaDeRegistro> {
  @override
  void initState() {
    super.initState();
    _fetchClassrooms();

    _fetchDisciplinas();
  }

  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _totalClassesController = TextEditingController();

  // i Diciplina
  final _idDiscipline1 = TextEditingController();
  final _idDiscipline2 = TextEditingController();

  final _idDiscipline3 = TextEditingController();

  // Adicionados para horário
  final _dayController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  // Adicionado para inscrição de aluno
  final _studentIdController = TextEditingController();

  // **Adicionados para inscrição de professor**
  final _teacherIdController = TextEditingController();

  // Estado
  List<Map<String, dynamic>> _disciplinas = [];
  bool _loading = false;

  String get _baseUrl => 'http://localhost:3001/discipline';

  // Buscar todas as disciplinas
  Future<void> _fetchDisciplinas() async {
    setState(() => _loading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final resp = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        setState(() {
          _disciplinas = List<Map<String, dynamic>>.from(data);
        });
      } else {
        _showError('Erro ao buscar disciplinas (${resp.statusCode})');
      }
    } catch (e) {
      _showError('Erro de conexão');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createDisciplina() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final totalText = _totalClassesController.text.trim();
    if (name.isEmpty || desc.isEmpty || totalText.isEmpty) return;

    final totalClasses = int.tryParse(totalText);
    if (totalClasses == null || totalClasses <= 0) {
      _showError('Total de aulas inválido');
      return;
    }

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': desc,
          'total_classes': totalClasses,
        }),
      );
      if (resp.statusCode == 201) {
        _nameController.clear();
        _descController.clear();
        _totalClassesController.clear();
        _fetchDisciplinas();
      } else {
        _showError('Erro ao criar disciplina (${resp.body.toString()})');
      }
    } catch (e) {
      _showError('Erro de conexão');
    }
  }

  // Deletar disciplina
  Future<void> _deleteDisciplina() async {
    final id = _idDiscipline1.text.trim();
    if (id.isEmpty) return;

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final resp = await http.delete(
        Uri.parse("$_baseUrl/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        _idDiscipline1.clear();
        _fetchDisciplinas();
      } else {
        _showError('Erro ao deletar disciplina (${resp.statusCode})');
      }
    } catch (e) {
      _showError('Erro de conexão');
    }
  }

  // Criar horário de disciplina
  Future<void> _createScheduleDisciplina() async {
    final id = _idDiscipline1.text.trim();
    final day = int.tryParse(_dayController.text.trim());
    final start = _startController.text.trim();
    final end = _endController.text.trim();
    if (id.isEmpty || day == null || start.isEmpty || end.isEmpty) return;

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final resp = await http.post(
        Uri.parse("$_baseUrl/schedule/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'day_of_week': day,
          'start_time': start,
          'end_time': end,
        }),
      );

      // Aceitar qualquer 2xx (documentação costuma retornar 201 para criação)
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        _dayController.clear();
        _startController.clear();
        _endController.clear();
        _fetchDisciplinas();
      } else {
        _showError(
          'Erro ao criar horário (status ${resp.statusCode}: ${resp.body})',
        );
      }
    } catch (e) {
      _showError('Erro de conexão: ${e.toString()}');
    }
  }

  // Inscrever aluno na disciplina
  Future<void> _enrollStudent() async {
    final disciplineId = _idDiscipline2.text.trim();
    final studentId = _studentIdController.text.trim();
    if (disciplineId.isEmpty || studentId.isEmpty) return;

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final resp = await http.post(
        Uri.parse("$_baseUrl/$disciplineId/students/$studentId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        _studentIdController.clear();
        _fetchDisciplinas();
      } else {
        _showError('Erro ao inscrever aluno (${resp.body.toString()})');
      }
    } catch (e) {
      _showError('Erro de conexão');
    }
  }

  // **Inscrever professor na disciplina**
  Future<void> _enrollTeacher() async {
    final disciplineId = _idDiscipline3.text.trim();
    final teacherId = _teacherIdController.text.trim();
    if (disciplineId.isEmpty || teacherId.isEmpty) return;

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final resp = await http.post(
        Uri.parse("$_baseUrl/$disciplineId/teachers/$teacherId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        _teacherIdController.clear();
        _fetchDisciplinas();
      } else {
        _showError('Erro ao inscrever professor (${resp.body.toString()})');
      }
    } catch (e) {
      _showError('Erro de conexão');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Construção da UI de Disciplinas
  Widget _buildDisciplinasTab(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Registrar Disciplina
          _sectionCard(
            title: 'Registrar Disciplina',
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Nome'),
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  decoration: _inputDecoration('Descrição'),
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _totalClassesController,
                  decoration: _inputDecoration('Total de aulas'),
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _createDisciplina,
                  child: Text('Registrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(
                      0.1,
                    ), // fundo azul com opacidade 0.1
                    foregroundColor: Colors.white, // texto branco
                    elevation: 0, // opcional: sem sombra
                  ),
                ),
              ],
            ),
          ),

          // Registrar Horário
          _sectionCard(
            title: 'Registrar Horário de Disciplina',
            child: Column(
              children: [
                TextField(
                  controller: _idDiscipline1,
                  decoration: _inputDecoration('ID da Disciplina'),
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dayController,
                        decoration: _inputDecoration('Dia da semana (0-6)'),
                        style: TextStyle(
                          color: Colors.white,
                        ), // <- Aqui você define a cor do texto digitado

                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _startController,
                        decoration: _inputDecoration('Início (HH:mm)'),
                        style: TextStyle(
                          color: Colors.white,
                        ), // <- Aqui você define a cor do texto digitado
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _endController,
                        decoration: _inputDecoration('Término (HH:mm)'),
                        style: TextStyle(
                          color: Colors.white,
                        ), // <- Aqui você define a cor do texto digitado
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(
                      0.1,
                    ), // fundo azul com opacidade 0.1
                    foregroundColor: Colors.white, // texto branco
                    elevation: 0, // opcional: sem sombra
                  ),
                  onPressed: _createScheduleDisciplina,

                  child: Text('Registrar Horário'),
                ),
              ],
            ),
          ),

          // Inscrever Aluno
          _sectionCard(
            title: 'Inscrever Aluno na Disciplina',
            child: Column(
              children: [
                TextField(
                  controller: _idDiscipline2,
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado

                  decoration: _inputDecoration('ID da Disciplina'),
                ),
                SizedBox(height: 8),
                TextField(
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado

                  controller: _studentIdController,
                  decoration: _inputDecoration('ID do Aluno'),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(
                      0.1,
                    ), // fundo azul com opacidade 0.1
                    foregroundColor: Colors.white, // texto branco
                    elevation: 0, // opcional: sem sombra
                  ),
                  onPressed: _enrollStudent,
                  child: Text('Inscrever Aluno'),
                ),
              ],
            ),
          ),

          // **Inscrever Professor**
          _sectionCard(
            title: 'Inscrever Professor na Disciplina',
            child: Column(
              children: [
                TextField(
                  controller: _idDiscipline3,
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado

                  decoration: _inputDecoration('ID da Disciplina'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _teacherIdController,
                  style: TextStyle(
                    color: Colors.white,
                  ), // <- Aqui você define a cor do texto digitado

                  decoration: _inputDecoration('ID do Professor'),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(
                      0.1,
                    ), // fundo azul com opacidade 0.1
                    foregroundColor: Colors.white, // texto branco
                    elevation: 0, // opcional: sem sombra
                  ),
                  onPressed: _enrollTeacher,

                  child: Text('Inscrever Professor'),
                ),
              ],
            ),
          ),

          // Listar Disciplinas
          _sectionCard(
            title: 'Listar Disciplinas',
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: _disciplinas.map((d) {
                      return ListTile(
                        title: Text(
                          d['name'] ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          d['description'] ?? '',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: SelectableText(
                          d['id'] ?? '',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        onTap: () {
                          print("o valor é " + d.toString());
                          final sched = List<Map<String, dynamic>>.from(
                            d['schedule'] ?? [],
                          );
                          final students = List<Map<String, dynamic>>.from(
                            d['students'] ?? [],
                          );
                          final teacher =
                              d['teacher']; // Supondo que o back retorne um objeto teacher
                          final sala = d['classroom'];

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Detalhes da Disciplina'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (sched.isNotEmpty) ...[
                                      Text('Horários:'),
                                      SizedBox(height: 8),
                                      ...sched
                                          .map<Widget>(
                                            (s) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Dia da semana: ${s['day_of_week']?.toString() ?? ''}',
                                                ),
                                                Text(
                                                  'Início: ${s['start_time']?.toString() ?? ''}',
                                                ),
                                                Text(
                                                  'Término: ${s['end_time']?.toString() ?? ''}',
                                                ),
                                                SizedBox(height: 12),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ] else ...[
                                      Text('Nenhum horário cadastrado.'),
                                      SizedBox(height: 12),
                                    ],
                                    Text(
                                      'Professor: ${teacher != null ? (teacher['name'] ?? '') : 'Nenhum inscrito'}',
                                    ),
                                    SizedBox(height: 12),
                                    Text('Alunos Inscritos:'),
                                    if (students.isNotEmpty)
                                      ...students
                                          .map<Widget>(
                                            (s) => Text('- ${s['name'] ?? ''}'),
                                          )
                                          .toList()
                                    else
                                      Text('Nenhum aluno inscrito.'),
                                    SizedBox(height: 12),
                                    Text(
                                      'Sala de aula: ${sala != null ? (sala['name'] ?? '') : ''}',
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Fechar'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),

          // Deletar Disciplina
          _sectionCard(
            title: 'Deletar Disciplina',
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _idDiscipline1,
                    decoration: _inputDecoration('ID da Disciplina'),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(
                      1,
                    ), // fundo azul com opacidade 0.1
                    foregroundColor: Colors.white, // texto branco
                    elevation: 0, // opcional: sem sombra
                  ),
                  onPressed: _deleteDisciplina,
                  child: Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função auxiliar para estilo de InputDecoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,

      labelStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,

      fillColor: Colors.blue.withOpacity(0.1),
    );
  }

  // Controllers
  final _filterController = TextEditingController();

  // Estado
  List<Map<String, dynamic>> _users = [];
  bool _loadingUsers = false;

  String get _usersUrl => 'http://localhost:3001/user';

  // Buscar alunos e/ou professores
  Future<void> _fetchUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      // monta query params somente se o filtro não estiver vazio
      final filter = _filterController.text.trim();
      final uri = Uri.parse(_usersUrl).replace(
        queryParameters: filter.isNotEmpty ? {'filterBy': filter} : null,
      );
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['users']);
        });
      } else {
        _showError('Erro ao buscar usuários (${resp.statusCode})');
      }
    } catch (e) {
      _showError('Erro de conexão');
    } finally {
      setState(() => _loadingUsers = false);
    }
  }

  // Bloco de UI para buscar e listar usuários
  Widget _buildUsersTab(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _sectionCard(
            title: 'Buscar Usuários',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _filterController.text.isNotEmpty
                      ? _filterController.text
                      : null,
                  decoration: _inputDecoration('Filtrar por (student|teacher)'),
                  dropdownColor: Colors.grey[850],
                  style: TextStyle(color: Colors.white),
                  items: ['student', 'teacher']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _filterController.text = val;
                    } else {
                      _filterController.clear();
                    }
                  },
                  hint: Text(
                    'Selecione o tipo',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetchUsers,
                  child: Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          _sectionCard(
            title: 'Resultado da Busca',
            child: _loadingUsers
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: _users.map((u) {
                      return ListTile(
                        title: Text(
                          u['name'] ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${u['email']} • ${u['type']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: SelectableText(
                          u['id'] ?? '',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Detalhes do Usuário'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: ${u['id']}'),
                                  Text('Nome: ${u['name']}'),
                                  Text('Email: ${u['email']}'),
                                  Text('Telefone: ${u['phone']}'),
                                  Text('Tipo: ${u['type']}'),
                                  Text('Criado em: ${u['created_at']}'),
                                  Text('Atualizado em: ${u['updated_at']}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Fechar'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // Função auxiliar para criar cartões de seção (igual ao seu exemplo)
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      color: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.blueGrey.withOpacity(0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Text('Tela de registros', style: _screenTextStyle)),
              SizedBox(height: 24),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.withOpacity(0.18),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelStyle: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelColor: Colors.white70,
                              labelColor: Colors.white,
                              tabs: [
                                Tab(text: 'Disciplinas'),
                                Tab(text: 'Salas'),
                                Tab(text: 'Listar usuários'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildDisciplinasTab(isMobile),
                                _buildClassroomsTab(isMobile),
                                _buildUsersTab(isMobile),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // controllers and state variables (to be declared in your State class)
  final TextEditingController _classroomNameController =
      TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _minDistanceController = TextEditingController();
  final TextEditingController _deleteClassroomIdController =
      TextEditingController();
  // Adicionados para vincular sala a disciplina
  final TextEditingController _linkDisciplineIdController =
      TextEditingController();
  final TextEditingController _linkClassroomIdController =
      TextEditingController();

  bool _loadingClassrooms = false;
  List<Map<String, dynamic>> _classrooms = [];

  Future<void> _fetchClassrooms() async {
    setState(() => _loadingClassrooms = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final url = Uri.parse('http://localhost:3001/classroom');
    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _classrooms = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      debugPrint('Exceção: $e');
    } finally {
      setState(() => _loadingClassrooms = false);
    }
  }

  Future<void> _createClassroom() async {
    final name = _classroomNameController.text;
    final latitude = _latitudeController.text;
    final longitude = _longitudeController.text;
    final minDistance = int.tryParse(_minDistanceController.text) ?? 0;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final url = Uri.parse('http://localhost:3001/classroom');
    final body = jsonEncode({
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'min_distance': minDistance,
    });

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (res.statusCode == 201) {
        _classroomNameController.clear();
        _latitudeController.clear();
        _longitudeController.clear();
        _minDistanceController.clear();
        _fetchClassrooms();
      }
    } catch (e) {
      debugPrint('Exceção: $e');
    }
  }

  Future<void> _deleteClassroom() async {
    final id = _deleteClassroomIdController.text;
    if (id.isEmpty) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final url = Uri.parse('http://localhost:3001/classroom/$id');

    try {
      final res = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        _deleteClassroomIdController.clear();
        _fetchClassrooms();
      }
    } catch (e) {
      debugPrint('Exceção: $e');
    }
  }

  // nova função para vincular sala a disciplina (com mensagem de sucesso/erro)
  Future<void> _linkClassroomToDiscipline() async {
    final disciplineId = _linkDisciplineIdController.text.trim();
    final classroomId = _linkClassroomIdController.text.trim();
    if (disciplineId.isEmpty || classroomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha ambos os IDs'),
          backgroundColor: Colors.redAccent,
        ),
      );

      return;
    }

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final url = Uri.parse(
        'http://localhost:3001/discipline/$disciplineId/classroom/$classroomId',
      );
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        _linkDisciplineIdController.clear();
        _linkClassroomIdController.clear();
        _fetchClassrooms();
        _fetchDisciplinas();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sala vinculada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao vincular sala (${res.statusCode})'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildClassroomsTab(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Registrar Sala de Aula
          _sectionCard(
            title: 'Registrar Sala de Aula',
            child: Column(
              children: [
                TextField(
                  controller: _classroomNameController,
                  decoration: _inputDecoration('Nome'),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _latitudeController,
                  decoration: _inputDecoration('Latitude'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _longitudeController,
                  decoration: _inputDecoration('Longitude'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _minDistanceController,
                  decoration: _inputDecoration('Distância permitida'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12 : 14,
                      horizontal: isMobile ? 24 : 32,
                    ),
                  ),
                  onPressed: _createClassroom,
                  child: Text(
                    'Registrar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Listar Salas de Aula
          _sectionCard(
            title: 'Listar Salas de Aula',
            child: _loadingClassrooms
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: _classrooms.map((c) {
                      return ListTile(
                        title: Text(
                          c['name'] ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Lat: ${c['latitude']}  Lon: ${c['longitude']}\nDistância Mínima: ${c['min_distance']} m',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: SelectableText(
                          c['id'] ?? '',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // Vincular Sala à Disciplina
          _sectionCard(
            title: 'Vincular Sala à Disciplina',
            child: Column(
              children: [
                TextField(
                  controller: _linkDisciplineIdController,
                  decoration: _inputDecoration('ID da Disciplina'),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _linkClassroomIdController,
                  decoration: _inputDecoration('ID da Sala de aula'),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12 : 14,
                      horizontal: isMobile ? 24 : 32,
                    ),
                  ),
                  onPressed: _linkClassroomToDiscipline,
                  child: Text(
                    'Vincular',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Deletar Sala de Aula
          _sectionCard(
            title: 'Deletar Sala de Aula',
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deleteClassroomIdController,
                    decoration: _inputDecoration('ID da sala de aula'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12 : 14,
                      horizontal: isMobile ? 16 : 24,
                    ),
                  ),
                  onPressed: _deleteClassroom,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _screenTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
