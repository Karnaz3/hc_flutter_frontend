import 'package:flutter/material.dart';
import 'package:flutter_test_api_call/doctor/requests/get_requests.dart';
import 'package:flutter_test_api_call/doctor/requests/post_requests.dart';
import 'package:flutter_test_api_call/network.dart';
import 'package:flutter_test_api_call/user/userAppointments.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  String doctorEmail = '';
  List<dynamic> allAppointments = [];
  List<dynamic> completedAppointments = [];
  List<dynamic> canceledAppointments = [];
  bool isLoading = false;

  int _selectedIndex = 0; // Selected tab index

  late GetRequests getRequests;
  late PostRequests postRequests;

  // Form-related variables for creating appointments
  dynamic selectedAppointment;
  DateTime? selectedDate;
  final _prescriptionController = TextEditingController();
  final _diagnosisController = TextEditingController();
  ReportSeverityEnum? selectedSeverity;

  @override
  void initState() {
    super.initState();
    _loadDoctorEmail();
    var apiService = ApiService();
    getRequests = GetRequests(apiService);
    postRequests = PostRequests(apiService);
  }

  Future<void> _loadDoctorEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        doctorEmail = decodedToken['email'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found')),
      );
    }
  }

  // Fetch all appointments
  Future<void> _fetchAllAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments = await getRequests.fetchAppointments();
      setState(() {
        allAppointments = fetchedAppointments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch all appointments')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch completed appointments
  Future<void> _fetchCompletedAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments = await getRequests.fetchCompletedAppointments();
      setState(() {
        completedAppointments = fetchedAppointments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch completed appointments')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch canceled appointments
  Future<void> _fetchCanceledAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments = await getRequests.fetchCanceledAppointments();
      setState(() {
        canceledAppointments = fetchedAppointments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch canceled appointments')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Create appointment
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

    try {
      await postRequests.createAppointment(
        doctorEmail,
        selectedAppointment,
        selectedDate,
        _prescriptionController.text,
        _diagnosisController.text,
        selectedSeverity.toString().split('.').last,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment created successfully')),
      );
      _fetchAllAppointments(); // Refresh appointments
      _clearUpdateForm(); // Clear the form after submission
    } catch (e) {
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

  // Complete appointment
  Future<void> _completeAppointment(String appointmentId) async {
    try {
      await postRequests.completeAppointment(appointmentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment marked as complete')),
      );
      _fetchAllAppointments(); // Refresh appointments after completion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete appointment')),
      );
    }
  }

  // Cancel appointment
  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await postRequests.cancelAppointment(appointmentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment canceled')),
      );
      _fetchAllAppointments(); // Refresh appointments after cancellation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel appointment')),
      );
    }
  }

  // Logout function
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('doctorName');

    Navigator.pushReplacementNamed(context, '/loginDoctor');
  }

  // Sidebar navigation items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Doctor'),
        automaticallyImplyLeading: true, // Ensure the drawer icon appears
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Doctor Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('View Appointments'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create Appointment'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: _buildSelectedTab(),
    );
  }

  // Function to switch between different tabs based on selected index
  Widget _buildSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildAppointmentList();
      case 1:
        return _buildCreateAppointmentForm();
      case 2:
        _logout(); // Call the logout function
        return Center(child: Text("Logging out..."));
      default:
        return _buildAppointmentList();
    }
  }

  // Build appointment list tab
  Widget _buildAppointmentList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _fetchAllAppointments,
              child: const Text('Get All Appointments'),
            ),
            ElevatedButton(
              onPressed: _fetchCompletedAppointments,
              child: const Text('Get Completed Appointments'),
            ),
            ElevatedButton(
              onPressed: _fetchCanceledAppointments,
              child: const Text('Get Canceled Appointments'),
            ),
            const SizedBox(height: 16),
            _buildAppointmentsSection('All Appointments', allAppointments),
            const SizedBox(height: 16),
            _buildAppointmentsSection(
                'Completed Appointments', completedAppointments),
            const SizedBox(height: 16),
            _buildAppointmentsSection(
                'Canceled Appointments', canceledAppointments),
          ],
        ),
      ),
    );
  }

  // Build create appointment tab
  Widget _buildCreateAppointmentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
            items: allAppointments.map((dynamic appointment) {
              return DropdownMenuItem<dynamic>(
                value: appointment,
                child: Text('Part: ${appointment['part']}'),
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
              items:
                  ReportSeverityEnum.values.map((ReportSeverityEnum severity) {
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
      ),
    );
  }

  // Build appointment section
  Widget _buildAppointmentsSection(String title, List<dynamic> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        appointments.isEmpty
            ? const Text('No appointments found')
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

  // Build appointment item
  Widget _buildAppointmentItem(dynamic appointment) {
    final severity = appointment['sevearity'];
    final appointmentId =
        appointment['id'].toString(); // Ensure appointmentId is a string
    final status = appointment[
        'status']; // Assuming there's a status field in the appointment

    // Log the entire appointment object for debugging
    print('Appointment Data: $appointment');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
            'Appointment ID: $appointmentId (Part: ${appointment['part']})'),
        children: [
          ListTile(
            title: Text('Part: ${appointment['part']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${appointment['description']}'),
                Text('Severity: $severity'),
                Text(
                    'Status: $status'), // Display the current status of the appointment
                Text('Diagnosis: ${appointment['diagnosis'] ?? 'N/A'}'),
                Text('Prescription: ${appointment['prescription'] ?? 'N/A'}'),
                _buildUserExpansionTile(appointment['user']),
                if (appointment['doctor'] != null)
                  _buildDoctorExpansionTile(appointment['doctor']),
                const SizedBox(height: 16),
                // Show buttons only if the appointment is in the "Created" state
                if (status == 'CREATED') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _completeAppointment(appointmentId),
                        child: const Text('Mark as Complete'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _cancelAppointment(appointmentId),
                        child: const Text('Cancel Appointment'),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                      'No actions available for this status: $status'), // Debugging message
                ],
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
          subtitle: Text('ID: ${doctor['id']}'),
        ),
      ],
    );
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
}
