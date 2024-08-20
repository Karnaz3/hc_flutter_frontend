import 'package:flutter_test_api_call/network.dart';
import 'package:flutter_test_api_call/user/userAppointments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPostRequests {
  final ApiService apiService;

  UserPostRequests(this.apiService);

  // Create an appointment
  Future<void> createUserAppointment(UserAppointment appointment) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      apiService.dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await apiService.dio.post(
        '/users/create-appointment',
        data: appointment.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      print("Error creating appointment: $e");
      rethrow;
    }
  }

  // Cancel an appointment
  Future<void> cancelUserAppointment(
      String appointmentId, String userEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      apiService.dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await apiService.dio.post(
        '/users/cancel-appointment/$appointmentId',
        queryParameters: {'email': userEmail},
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
