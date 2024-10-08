import 'package:dio/dio.dart';
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
    _fetchAllAppointments();
    _fetchCompletedAppointments();
    _fetchCanceledAppointments();
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

  Future<void> _fetchAllAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments = await getRequests.fetchAppointments();
      if (fetchedAppointments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No appointments found')),
        );
      } else {
        setState(() {
          allAppointments = fetchedAppointments;
        });
      }
    } on DioException catch (e) {
      String errorMessage = 'Error occurred: ${e.message}';
      if (e.response != null && e.response?.statusCode == 404) {
        errorMessage = 'No appointments found for this doctor.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCompletedAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments = await getRequests.fetchCompletedAppointments();
      if (fetchedAppointments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No completed appointments found')),
        );
      } else {
        setState(() {
          completedAppointments = fetchedAppointments;
        });
      }
    } on DioException catch (e) {
      String errorMessage = 'Error occurred: ${e.message}';
      if (e.response != null && e.response?.statusCode == 404) {
        errorMessage = 'No completed appointments found.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCanceledAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments = await getRequests.fetchCanceledAppointments();
      if (fetchedAppointments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No canceled appointments found')),
        );
      } else {
        setState(() {
          canceledAppointments = fetchedAppointments;
        });
      }
    } on DioException catch (e) {
      String errorMessage = 'Error occurred: ${e.message}';
      if (e.response != null && e.response?.statusCode == 404) {
        errorMessage = 'No canceled appointments found.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
        ),
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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('doctorName');

    Navigator.pushReplacementNamed(context, '/loginDoctor');
  }

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
        centerTitle: true, // Center the title in the AppBar
        backgroundColor: const Color(0xFF4FC3F7), // Matching with theme
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF4FC3F7), // Matching drawer header color
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
              leading: const Icon(Icons.list),
              title: const Text('View Appointments'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create Appointment'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      // Apply gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2), // Light Cyan
              Color(0xFF80DEEA), // Light Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildSelectedTab(),
      ),
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildAppointmentList();
      case 1:
        return _buildCreateAppointmentForm();
      case 2:
        _logout(); // Call the logout function
        return const Center(child: CircularProgressIndicator());
      default:
        return _buildAppointmentList();
    }
  }

  Widget _buildAppointmentList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('All Appointments', _fetchAllAppointments),
            const SizedBox(height: 16),
            _buildAppointmentsSection('All Appointments', allAppointments),
            const SizedBox(height: 16),
            _buildSectionTitle(
                'Completed Appointments', _fetchCompletedAppointments),
            const SizedBox(height: 16),
            _buildAppointmentsSection(
                'Completed Appointments', completedAppointments),
            const SizedBox(height: 16),
            _buildSectionTitle(
                'Canceled Appointments', _fetchCanceledAppointments),
            const SizedBox(height: 16),
            _buildAppointmentsSection(
                'Canceled Appointments', canceledAppointments),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback refreshCallback) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF4FC3F7)),
          onPressed: refreshCallback,
        ),
      ],
    );
  }

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
          DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  Colors.white.withOpacity(0.8), // Adding background color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
              decoration: InputDecoration(
                labelText: 'Prescription',
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _diagnosisController,
              decoration: InputDecoration(
                labelText: 'Diagnosis',
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportSeverityEnum>(
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Colors.white.withOpacity(0.8), // Adding background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4FC3F7), // Matching button color
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createAppointment,
              child: const Text('Create Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4FC3F7), // Matching button color
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection(String title, List<dynamic> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildAppointmentItem(dynamic appointment) {
    final severity = appointment['sevearity'];
    final appointmentId = appointment['id'].toString();
    final status = appointment['status'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ExpansionTile(
            leading: Icon(
              Icons.event_available,
              color: status == 'CREATED' ? Colors.blue : Colors.green,
            ),
            title: Text(
              'Appointment ID: $appointmentId',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            subtitle: Text(
              'Part: ${appointment['part']}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            backgroundColor: Colors.white.withOpacity(0.9),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.description, 'Description:',
                        appointment['description']),
                    _buildDetailRow(Icons.warning, 'Severity:', severity),
                    _buildDetailRow(Icons.check_circle, 'Status:', status),
                    _buildDetailRow(Icons.medical_services, 'Diagnosis:',
                        appointment['diagnosis'] ?? 'N/A'),
                    _buildDetailRow(Icons.note, 'Prescription:',
                        appointment['prescription'] ?? 'N/A'),
                    const SizedBox(height: 16),
                    _buildUserExpansionTile(appointment['user']),
                    if (appointment['doctor'] != null)
                      _buildDoctorExpansionTile(appointment['doctor']),
                    const SizedBox(height: 16),
                    if (status == 'CREATED') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _completeAppointment(appointmentId),
                            icon: const Icon(Icons.done),
                            label: const Text('Complete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _cancelAppointment(appointmentId),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
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
