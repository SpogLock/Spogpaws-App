import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:spogpaws/models/update_policy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePolicyRepository {
  UpdatePolicyRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<UpdatePolicy?> fetchPolicyForCurrentPlatform() async {
    final platform = _platformKey();
    if (platform == null) {
      return null;
    }

    _logRequest('app_update_policies.select', {'platform': platform});
    try {
      final response = await _client
          .from('app_update_policies')
          .select()
          .eq('platform', platform)
          .single();

      final policy = UpdatePolicy.fromMap(response);
      _logResponse('app_update_policies.select', {
        'platform': policy.platform,
        'minRequiredVersion': policy.minRequiredVersion,
        'isEnabled': policy.isEnabled,
      });
      return policy;
    } on PostgrestException catch (e) {
      _logError('app_update_policies.select', e);
      return null;
    } catch (e) {
      _logError('app_update_policies.select', e);
      return null;
    }
  }

  String? _platformKey() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return null;
    }
  }

  void _logRequest(String operation, Map<String, Object?> payload) {
    dev.log('[REQUEST] $operation -> $payload', name: 'UpdatePolicyRepository');
  }

  void _logResponse(String operation, Map<String, Object?> payload) {
    dev.log('[RESPONSE] $operation -> $payload', name: 'UpdatePolicyRepository');
  }

  void _logError(String operation, Object error) {
    dev.log(
      '[ERROR] $operation -> $error',
      name: 'UpdatePolicyRepository',
      level: 1000,
    );
  }
}
