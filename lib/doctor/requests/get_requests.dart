import 'package:flutter_test_api_call/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetRequests {
  final ApiService apiService;

  GetRequests(this.apiService);

  Future<List<dynamic>> fetchAppointments() async {
    return _fetchFromApi('/doctors/appointments/list');
  }

  Future<List<dynamic>> fetchCompletedAppointments() async {
    return _fetchFromApi('/doctors/completed/appointments');
  }

  Future<List<dynamic>> fetchCanceledAppointments() async {
    return _fetchFromApi('/doctors/cancelled/appointments');
  }

  Future<List<dynamic>> _fetchFromApi(String endpoint) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      apiService.dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await apiService.dio.get(endpoint);

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
