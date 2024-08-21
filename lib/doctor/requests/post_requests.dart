import 'package:flutter_test_api_call/network.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostRequests {
  final ApiService apiService;

  PostRequests(this.apiService);

  // Create appointment
  Future<void> createAppointment(
    String doctorEmail,
    dynamic selectedAppointment,
    DateTime? selectedDate,
    String prescription,
    String diagnosis,
    String severity,
  ) async {
    final appointmentData = {
      'appointmentId': selectedAppointment['id'],
      'appointmentDate': DateFormat('yyyy/MM/dd').format(selectedDate!),
      'prescription': prescription,
      'diagnosis': diagnosis,
      'sevearity': severity,
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      apiService.dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await apiService.dio.post(
        '/doctors/create-appointment',
        queryParameters: {'email': doctorEmail},
        data: appointmentData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      print("Error creating appointment: $e");
      rethrow;
    }
  }

  // Complete appointment
  Future<void> completeAppointment(String appointmentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      apiService.dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await apiService.dio.post(
        '/doctors/complete-appointment/${appointmentId.toString()}', // Convert to string
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to complete appointment');
      }
    } catch (e) {
      print("Error completing appointment: $e");
      rethrow;
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      apiService.dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await apiService.dio.post(
        '/doctors/cancel-appointment/${appointmentId.toString()}', // Convert to string
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      print("Error canceling appointment: $e");
      rethrow;
    }
  }
}
