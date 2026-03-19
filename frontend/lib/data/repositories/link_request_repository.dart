import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/link_request/link_request_model.dart';

class LinkRequestRepository {
  final DioClient _dioClient;

  LinkRequestRepository({required DioClient dioClient})
    : _dioClient = dioClient;

  Future<List<LinkRequestModel>> getInbox({String status = 'PENDING'}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/link-requests/inbox',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (item) => LinkRequestModel.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    } on DioException catch (error) {
      developer.log(
        'Get inbox link requests failed: ${error.response?.statusCode} - ${error.message}',
      );
    } catch (error) {
      developer.log('Unexpected error when fetching inbox requests: $error');
    }
    return [];
  }

  Future<List<LinkRequestModel>> getOutbox({String status = 'PENDING'}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/link-requests/outbox',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (item) => LinkRequestModel.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    } on DioException catch (error) {
      developer.log(
        'Get outbox link requests failed: ${error.response?.statusCode} - ${error.message}',
      );
    } catch (error) {
      developer.log('Unexpected error when fetching outbox requests: $error');
    }
    return [];
  }

  Future<bool> approve(String requestId) async {
    return _actOnRequest(requestId, 'approve');
  }

  Future<bool> reject(String requestId) async {
    return _actOnRequest(requestId, 'reject');
  }

  Future<bool> cancel(String requestId) async {
    return _actOnRequest(requestId, 'cancel');
  }

  Future<bool> _actOnRequest(String requestId, String action) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/link-requests/$requestId/$action',
      );
      return response.statusCode == 200;
    } on DioException catch (error) {
      developer.log(
        'Action $action failed for $requestId: ${error.response?.statusCode} - ${error.message}',
      );
      return false;
    } catch (error) {
      developer.log('Unexpected action error: $error');
      return false;
    }
  }
}
