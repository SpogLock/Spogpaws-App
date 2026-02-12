import 'dart:developer' as dev;

import 'package:spogpaws/models/clinic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicRepositoryException implements Exception {
  ClinicRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'ClinicRepositoryException: $message';
}

class ClinicRepository {
  ClinicRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Clinic>> getActiveClinics({
    int limit = 10,
    int offset = 0,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw ClinicRepositoryException('You must be logged in to view clinics.');
    }

    final rangeEnd = offset + limit - 1;
    _logRequest('clinics.select.active', {
      'offset': offset,
      'limit': limit,
      'is_active': true,
    });

    try {
      final response = await _client
          .from('clinics')
          .select()
          .eq('is_active', true)
          .order('is_24_hours', ascending: false)
          .order('name', ascending: true)
          .range(offset, rangeEnd);

      final list = (response as List)
          .map((item) => Clinic.fromMap(item as Map<String, dynamic>))
          .toList();

      _logResponse('clinics.select.active', {
        'offset': offset,
        'limit': limit,
        'count': list.length,
      });
      return list;
    } on PostgrestException catch (e) {
      _logError('clinics.select.active', e);
      throw ClinicRepositoryException('Failed to fetch clinics: ${e.message}');
    } catch (_) {
      _logError('clinics.select.active', 'Unknown error');
      throw ClinicRepositoryException('Failed to fetch clinics.');
    }
  }

  void _logRequest(String operation, Map<String, Object?> payload) {
    dev.log('[REQUEST] $operation -> $payload', name: 'ClinicRepository');
  }

  void _logResponse(String operation, Map<String, Object?> payload) {
    dev.log('[RESPONSE] $operation -> $payload', name: 'ClinicRepository');
  }

  void _logError(String operation, Object error) {
    dev.log(
      '[ERROR] $operation -> $error',
      name: 'ClinicRepository',
      level: 1000,
    );
  }
}
