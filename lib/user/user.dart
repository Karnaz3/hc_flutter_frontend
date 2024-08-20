import 'package:flutter/material.dart';
import 'package:flutter_test_api_call/network.dart';
import 'package:flutter_test_api_call/user/requests/get_requests.dart';
import 'package:flutter_test_api_call/user/requests/post_requests.dart';
import 'package:flutter_test_api_call/user/userAppointments.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String userName = '';
  String userEmail = '';
  List<dynamic> allAppointments = [];
  List<dynamic> completedAppointments = [];
  List<dynamic> canceledAppointments = [];
  bool isLoading = false;

  int _selectedIndex = 0; // Selected tab index

  // Form-related variables
  PartsEnum? selectedPart;
  ReportSeverityEnum? selectedSeverity;
  final _descriptionController = TextEditingController();

  late UserGetRequests userGetRequests;
  late UserPostRequests userPostRequests;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _loadUserData();

    // Initialize API services only after loading user data
    var apiService = ApiService();
    userGetRequests = UserGetRequests(apiService);
    userPostRequests = UserPostRequests(apiService);

    if (userEmail.isNotEmpty) {
      _fetchAllAppointments();
      _fetchCompletedAppointments();
      _fetchCanceledAppointments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user email')),
      );
    }
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

  Future<void> _fetchAllAppointments() async {
    if (userEmail.isEmpty) return; // Ensure userEmail is loaded

    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments =
          await userGetRequests.fetchUserAppointments(userEmail);
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

  Future<void> _fetchCompletedAppointments() async {
    if (userEmail.isEmpty) return; // Ensure userEmail is loaded

    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments =
          await userGetRequests.fetchCompletedAppointments(userEmail);
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

  Future<void> _fetchCanceledAppointments() async {
    if (userEmail.isEmpty) return; // Ensure userEmail is loaded

    setState(() {
      isLoading = true;
    });

    try {
      var fetchedAppointments =
          await userGetRequests.fetchCanceledAppointments(userEmail);
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
      await userPostRequests.createUserAppointment(appointment);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment created successfully')),
      );
      _fetchAllAppointments(); // Refresh appointments
      setState(() {
        _descriptionController.clear(); // Clear the form
        selectedPart = null;
        selectedSeverity = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create appointment')),
      );
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await userPostRequests.cancelUserAppointment(appointmentId, userEmail);
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
    await prefs.remove('userName');

    Navigator.pushReplacementNamed(context, '/login');
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
        title: const Text('Welcome User'),
        automaticallyImplyLeading: true, // Ensure the drawer icon appears
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'User Menu',
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
        return const Center(child: Text("Logging out..."));
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRefreshButton(
                    'Appointments', Icons.refresh, _fetchAllAppointments),
                _buildRefreshButton(
                    'Canceled', Icons.refresh, _fetchCanceledAppointments),
                _buildRefreshButton(
                    'Completed', Icons.refresh, _fetchCompletedAppointments),
              ],
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

  // Build refresh button
  Widget _buildRefreshButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
    );
  }

  // Build create appointment tab
  Widget _buildCreateAppointmentForm() {
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createAppointment,
            child: const Text('Submit Request'),
          ),
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
    final appointmentId = appointment['id'].toString();
    final status = appointment['status'];

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
                Text('Status: $status'),
                Text('Diagnosis: ${appointment['diagnosis'] ?? 'N/A'}'),
                Text('Prescription: ${appointment['prescription'] ?? 'N/A'}'),
                const SizedBox(height: 16),
                if (status == 'CREATED') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _cancelAppointment(appointmentId),
                        child: const Text('Cancel Appointment'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
