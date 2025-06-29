import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';


class ApiServiceRecommendation {
  final Dio _dio = Dio();
  final String apiUrl = 'http://10.0.2.2:5000/recommend'; // Replace with your actual API URL



  Future<Map<String, dynamic>> fetchRecommendations(String request,String category) async {
    try {
      final response = await _dio.post(
        apiUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'request': request,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        print(response.data);
        return response.data;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API');
    }
  }
}