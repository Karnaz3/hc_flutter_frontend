import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test_api_call/user/userAppointments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String userName = '';
  String userEmail = '';
  List<dynamic> appointments = [];
  bool isLoading = false;

  int _currentIndex = 0; // For bottom navigation

  // Form related variables
  PartsEnum? selectedPart;
  ReportSeverityEnum? selectedSeverity;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        userEmail = decodedToken['email'];
        userName = prefs.getString('userName') ?? 'User';
      });
      print("Extracted email: $userEmail");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found')),
      );
    }
  }

  Future<void> _fetchAppointments() async {
    if (!_isValidEmail(userEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var dio = Dio();
      var response = await dio.get(
        'http://192.168.18.71:3000/users/own/appointments',
        queryParameters: {'email': userEmail},
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments = response.data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch appointments')),
        );
      }
    } catch (e) {
      print("Error fetching appointments: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch appointments')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createAppointment() async {
    if (selectedPart == null ||
        selectedSeverity == null ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form')),
      );
      return;
    }

    final appointment = UserAppointment(
      email: userEmail,
      part: selectedPart!,
      description: _descriptionController.text,
      severity: selectedSeverity!,
    );

    try {
      var dio = Dio();
      var response = await dio.post(
        'http://192.168.18.71:3000/users/create-appointment',
        data: appointment.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created successfully')),
        );
        _fetchAppointments(); // Refresh appointments
        setState(() {
          _descriptionController.clear(); // Clear the form
          selectedPart = null;
          selectedSeverity = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create appointment')),
        );
      }
    } catch (e) {
      print("Error creating appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create appointment')),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');

    // Navigate back to the login screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $userName!'),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentIndex == 0
            ? _buildAppointmentList()
            : _currentIndex == 1
                ? _buildAppointmentForm()
                : _buildLogoutScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    List<dynamic> createdAppointments = appointments
        .where((appointment) => appointment['status'] == 'CREATED')
        .toList();
    List<dynamic> inProgressAppointments = appointments
        .where((appointment) => appointment['status'] == 'IN_PROGRESS')
        .toList();
    List<dynamic> completedAppointments = appointments
        .where((appointment) => appointment['status'] == 'DONE')
        .toList();

    return Column(
      children: [
        ElevatedButton(
          onPressed: _fetchAppointments,
          child: const Text('Get Appointments'),
        ),
        const SizedBox(height: 16),
        isLoading
            ? const CircularProgressIndicator()
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppointmentCategory(
                          'Created Appointments', createdAppointments),
                      _buildAppointmentCategory(
                          'In Progress Appointments', inProgressAppointments),
                      _buildAppointmentCategory(
                          'Completed Appointments', completedAppointments),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildAppointmentCategory(
      String categoryTitle, List<dynamic> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            categoryTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        appointments.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('No appointments found'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  return _buildAppointmentItem(appointment);
                },
              ),
      ],
    );
  }

  Widget _buildAppointmentForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DropdownButton<PartsEnum>(
            hint: const Text("Select Part"),
            value: selectedPart,
            items: PartsEnum.values.map((PartsEnum part) {
              return DropdownMenuItem<PartsEnum>(
                value: part,
                child: Text(part.toString().split('.').last),
              );
            }).toList(),
            onChanged: (PartsEnum? newValue) {
              setState(() {
                selectedPart = newValue!;
              });
            },
          ),
          DropdownButton<ReportSeverityEnum>(
            hint: const Text("Select Severity"),
            value: selectedSeverity,
            items: ReportSeverityEnum.values.map((ReportSeverityEnum severity) {
              return DropdownMenuItem<ReportSeverityEnum>(
                value: severity,
                child: Text(severity.toString().split('.').last),
              );
            }).toList(),
            onChanged: (ReportSeverityEnum? newValue) {
              setState(() {
                selectedSeverity = newValue!;
              });
            },
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          ElevatedButton(
            onPressed: _createAppointment,
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutScreen() {
    return Center(
      child: ElevatedButton(
        onPressed: _logout,
        child: const Text('Logout'),
      ),
    );
  }

  Widget _buildAppointmentItem(dynamic appointment) {
    return Card(
      child: ExpansionTile(
        title:
            Text('${appointment['part']} (Status: ${appointment['status']})'),
        subtitle: Text('Appointment ID: ${appointment['id']}'),
        children: [
          ListTile(
            title: Text('Description: ${appointment['description']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Severity: ${appointment['sevearity']}'),
                Text('Diagnosis: ${appointment['diagnosis'] ?? 'N/A'}'),
                Text('Prescription: ${appointment['prescription'] ?? 'N/A'}'),
                Text(
                    'User: ${appointment['user']['name']} (${appointment['user']['email']})'),
                Text('Gender: ${appointment['user']['gender']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
