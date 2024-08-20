import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting and picker

// Enum definitions
// ignore: constant_identifier_names
enum ReportSeverityEnum { LOW, MEDIUM, HIGH, CRITICAL }

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  String doctorEmail = '';
  List<dynamic> appointments = [];
  bool isLoading = false;
  int _currentIndex = 0; // For bottom navigation
  dynamic selectedAppointment;

  // Form-related variables for updating appointment
  DateTime? selectedDate;
  final _prescriptionController = TextEditingController();
  final _diagnosisController = TextEditingController();
  ReportSeverityEnum? selectedSeverity;

  @override
  void initState() {
    super.initState();
    _loadDoctorEmail();
  }

  Future<void> _loadDoctorEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        doctorEmail = decodedToken['email']; // Extract email from token
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found')),
      );
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      var dio = Dio();
      dio.options.headers['Authorization'] =
          'Bearer $token'; // Add Authorization header

      var response =
          await dio.get('http://192.168.18.71:3000/doctors/appointments/list');

      if (response.statusCode == 200) {
        setState(() {
          appointments = response.data;
        });
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
    if (selectedAppointment == null ||
        selectedDate == null ||
        selectedSeverity == null ||
        _prescriptionController.text.isEmpty ||
        _diagnosisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form')),
      );
      return;
    }

    final appointmentData = {
      'appointmentId': selectedAppointment['id'],
      'appointmentDate': DateFormat('yyyy/MM/dd').format(selectedDate!),
      'prescription': _prescriptionController.text,
      'diagnosis': _diagnosisController.text,
      'sevearity': selectedSeverity.toString().split('.').last,
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      var dio = Dio();
      dio.options.headers['Authorization'] =
          'Bearer $token'; // Add Authorization header

      var response = await dio.post(
        'http://192.168.18.71:3000/doctors/create-appointment',
        queryParameters: {
          'email': doctorEmail
        }, // Send email as query parameter
        data: appointmentData, // Send DTO contents as body
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created successfully')),
        );
        _fetchAppointments(); // Refresh appointments
        setState(() {
          _clearUpdateForm(); // Clear the form after submission
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

  void _clearUpdateForm() {
    setState(() {
      selectedAppointment = null;
      selectedDate = null;
      selectedSeverity = null;
      _prescriptionController.clear();
      _diagnosisController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent bottom overflow
      appBar: AppBar(
        title: const Text('Welcome Doctor'),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentIndex == 0
                ? _buildAppointmentList()
                : _currentIndex == 1
                    ? _buildCreateAppointmentForm()
                    : _buildLogoutScreen(),
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _fetchAppointments,
          child: const Text('Get Appointments'),
        ),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : appointments.isEmpty
                ? const Center(child: Text('No appointments found'))
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

  Widget _buildCreateAppointmentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create Appointment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DropdownButton<dynamic>(
          hint: const Text("Select Appointment"),
          value: selectedAppointment,
          items: appointments.map((dynamic appointment) {
            return DropdownMenuItem<dynamic>(
              value: appointment,
              child: Text('Part: ${appointment['part']}'), // Only show 'part'
            );
          }).toList(),
          onChanged: (dynamic newValue) {
            setState(() {
              selectedAppointment = newValue!;
            });
          },
        ),
        const SizedBox(height: 16),
        if (selectedAppointment != null) ...[
          // Show additional details below the dropdown when an appointment is selected
          Text('Description: ${selectedAppointment['description']}'),
          const SizedBox(height: 16),
          TextField(
            controller: _prescriptionController,
            decoration: const InputDecoration(labelText: 'Prescription'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _diagnosisController,
            decoration: const InputDecoration(labelText: 'Diagnosis'),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text(selectedDate == null
                ? 'Select Appointment Date'
                : DateFormat('yyyy/MM/dd').format(selectedDate!)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createAppointment,
            child: const Text('Create Appointment'),
          ),
        ],
      ],
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
    // Directly use the severity string from the API response
    final severity = appointment['sevearity'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
            'Appointment ID: ${appointment['id']} (Part: ${appointment['part']})'),
        children: [
          ListTile(
            title: Text('Part: ${appointment['part']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${appointment['description']}'),
                Text('Severity: $severity'),
                Text('Diagnosis: ${appointment['diagnosis'] ?? 'N/A'}'),
                Text('Prescription: ${appointment['prescription'] ?? 'N/A'}'),
                _buildUserExpansionTile(appointment['user']),
                if (appointment['doctor'] != null)
                  _buildDoctorExpansionTile(appointment['doctor']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserExpansionTile(dynamic user) {
    return ExpansionTile(
      title: Text('User: ${user['name']}'),
      children: [
        ListTile(
          title: Text('Email: ${user['email']}'),
          subtitle: Text('Gender: ${user['gender']}'),
        ),
      ],
    );
  }

  Widget _buildDoctorExpansionTile(dynamic doctor) {
    return ExpansionTile(
      title: Text('Doctor: ${doctor['name']}'),
      children: [
        ListTile(
          title: Text('Email: ${doctor['email']}'),
          subtitle: Text(
              'ID: ${doctor['id']}'), // Additional doctor details if needed
        ),
      ],
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('doctorName');

    // Navigate back to the login screen
    Navigator.pushReplacementNamed(context, '/loginDoctor');
  }
}
