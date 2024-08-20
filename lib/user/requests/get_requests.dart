import 'package:flutter_test_api_call/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserGetRequests {
  final ApiService apiService;

  UserGetRequests(this.apiService);

  // Fetch all appointments
  Future<List<dynamic>> fetchUserAppointments(String userEmail) async {
    return _fetchFromApi('/users/own/appointments', userEmail);
  }

  // Fetch completed appointments
  Future<List<dynamic>> fetchCompletedAppointments(String userEmail) async {
    return _fetchFromApi('/users/completed/appointments', userEmail);
  }

  // Fetch canceled appointments
  Future<List<dynamic>> fetchCanceledAppointments(String userEmail) async {
    return _fetchFromApi('/users/canceled/appointments', userEmail);
  }

  Future<List<dynamic>> _fetchFromApi(String endpoint, String userEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      apiService.dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await apiService.dio.get(
        endpoint,
        queryParameters: {'email': userEmail},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch data from $endpoint');
      }
    } catch (e) {
      print("Error fetching data from $endpoint: $e");
      rethrow;
    }
  }
}
