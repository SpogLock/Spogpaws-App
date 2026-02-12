import 'dart:developer' as dev;

import 'package:spogpaws/models/tip_of_the_day.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TipRepositoryException implements Exception {
  TipRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'TipRepositoryException: $message';
}

class TipRepository {
  TipRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<TipOfTheDay?> getLatestActiveTip() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw TipRepositoryException('You must be logged in to view tips.');
    }

    _logRequest('tips_of_the_day.select.latest', {'is_active': true});
    try {
      final response = await _client
          .from('tips_of_the_day')
          .select()
          .eq('is_active', true)
          .lte('published_on', DateTime.now().toIso8601String().split('T')[0])
          .order('published_on', ascending: false)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        _logResponse('tips_of_the_day.select.latest', {'found': false});
        return null;
      }

      final tip = TipOfTheDay.fromMap(response.first);
      _logResponse('tips_of_the_day.select.latest', {
        'found': true,
        'tip_id': tip.id,
      });
      return tip;
    } on PostgrestException catch (e) {
      _logError('tips_of_the_day.select.latest', e);
      throw TipRepositoryException('Failed to fetch tip: ${e.message}');
    } catch (_) {
      _logError('tips_of_the_day.select.latest', 'Unknown error');
      throw TipRepositoryException('Failed to fetch tip.');
    }
  }

  void _logRequest(String operation, Map<String, Object?> payload) {
    dev.log('[REQUEST] $operation -> $payload', name: 'TipRepository');
  }

  void _logResponse(String operation, Map<String, Object?> payload) {
    dev.log('[RESPONSE] $operation -> $payload', name: 'TipRepository');
  }

  void _logError(String operation, Object error) {
    dev.log('[ERROR] $operation -> $error', name: 'TipRepository', level: 1000);
  }
}
