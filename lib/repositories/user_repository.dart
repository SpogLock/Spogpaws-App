import 'dart:developer' as dev;

import 'package:spogpaws/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryException implements Exception {
  UserRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'UserRepositoryException: $message';
}

class UserRepository {
  UserRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
  }) async {
    _logRequest('auth.signUp', {'email': email, 'hasFullName': fullName != null});
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
          if (username != null && username.isNotEmpty) 'username': username,
        },
      );
      _logResponse('auth.signUp', {
        'userId': response.user?.id,
        'hasSession': response.session != null,
      });
      return response;
    } on AuthException catch (e) {
      _logError('auth.signUp', e);
      throw UserRepositoryException(e.message);
    } on PostgrestException catch (e) {
      _logError('auth.signUp', e);
      throw UserRepositoryException(e.message);
    } catch (_) {
      _logError('auth.signUp', 'Unknown error');
      throw UserRepositoryException('Failed to sign up user.');
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    _logRequest('auth.signInWithPassword', {'email': email});
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logResponse('auth.signInWithPassword', {
        'userId': response.user?.id,
        'hasSession': response.session != null,
      });
      return response;
    } on AuthException catch (e) {
      _logError('auth.signInWithPassword', e);
      throw UserRepositoryException(e.message);
    } catch (_) {
      _logError('auth.signInWithPassword', 'Unknown error');
      throw UserRepositoryException('Failed to log in user.');
    }
  }

  Future<UserResponse> editCurrentUser({
    String? email,
    String? password,
    String? fullName,
    String? username,
  }) async {
    _logRequest('auth.updateUser', {
      'emailChanged': email != null && email.isNotEmpty,
      'passwordChanged': password != null && password.isNotEmpty,
      'fullNameChanged': fullName != null && fullName.isNotEmpty,
      'usernameChanged': username != null && username.isNotEmpty,
    });
    try {
      final userAttributes = UserAttributes(
        email: email,
        password: password,
        data: {
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
          if (username != null && username.isNotEmpty) 'username': username,
        },
      );

      final response = await _client.auth.updateUser(userAttributes);
      _logResponse('auth.updateUser', {'userId': response.user?.id});

      final currentUser = _client.auth.currentUser;
      if (currentUser != null) {
        _logRequest('profiles.update', {'id': currentUser.id});
        await _client
            .from('profiles')
            .update({
              if (email != null && email.isNotEmpty) 'email': email,
              if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
              if (username != null && username.isNotEmpty) 'username': username,
            })
            .eq('id', currentUser.id);
        _logResponse('profiles.update', {'id': currentUser.id, 'updated': true});
      }
      return response;
    } on AuthException catch (e) {
      _logError('auth.updateUser', e);
      throw UserRepositoryException(e.message);
    } on PostgrestException catch (e) {
      _logError('profiles.update', e);
      throw UserRepositoryException('Failed to update profile: ${e.message}');
    } catch (_) {
      _logError('auth.updateUser', 'Unknown error');
      throw UserRepositoryException('Failed to update current user.');
    }
  }

  Future<UserProfile> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw UserRepositoryException('No authenticated user.');
    }

    try {
      _logRequest('profiles.select.single', {'id': user.id});
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      final profile = UserProfile.fromMap(response);
      _logResponse('profiles.select.single', {
        'id': profile.id,
        'accountStatus': accountStatusToString(profile.accountStatus),
        'role': profile.role,
      });
      return profile;
    } on PostgrestException catch (e) {
      _logError('profiles.select.single', e);
      throw UserRepositoryException('Failed to fetch profile: ${e.message}');
    } catch (_) {
      _logError('profiles.select.single', 'Unknown error');
      throw UserRepositoryException('Failed to fetch profile.');
    }
  }

  Future<void> updateUserStatus({
    required String userId,
    required AccountStatus status,
  }) async {
    try {
      _logRequest('profiles.update.status', {
        'id': userId,
        'accountStatus': accountStatusToString(status),
      });
      await _client
          .from('profiles')
          .update({'account_status': accountStatusToString(status)})
          .eq('id', userId);
      _logResponse('profiles.update.status', {
        'id': userId,
        'accountStatus': accountStatusToString(status),
      });
    } on PostgrestException catch (e) {
      _logError('profiles.update.status', e);
      throw UserRepositoryException('Failed to update user status: ${e.message}');
    } catch (_) {
      _logError('profiles.update.status', 'Unknown error');
      throw UserRepositoryException('Failed to update user status.');
    }
  }

  Future<void> deleteCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw UserRepositoryException('No authenticated user to delete.');
    }

    try {
      _logRequest('rpc.delete_user', {'id': user.id});
      // Expects a Postgres function named `delete_user` that deletes
      // auth.users row for auth.uid(). Keep service-role logic on server.
      await _client.rpc('delete_user');
      _logResponse('rpc.delete_user', {'id': user.id, 'deleted': true});
      _logRequest('auth.signOut', {'id': user.id});
      await _client.auth.signOut();
      _logResponse('auth.signOut', {'id': user.id, 'signedOut': true});
    } on PostgrestException catch (e) {
      _logError('rpc.delete_user', e);
      throw UserRepositoryException(
        'Failed to delete user. Create a secure server-side delete endpoint '
        '(RPC/Edge Function). Details: ${e.message}',
      );
    } on AuthException catch (e) {
      _logError('auth.signOut', e);
      throw UserRepositoryException(e.message);
    } catch (_) {
      _logError('deleteCurrentUser', 'Unknown error');
      throw UserRepositoryException('Failed to delete current user.');
    }
  }

  void _logRequest(String operation, Map<String, Object?> payload) {
    dev.log(
      '[REQUEST] $operation -> $payload',
      name: 'UserRepository',
      level: 800,
    );
  }

  void _logResponse(String operation, Map<String, Object?> payload) {
    dev.log(
      '[RESPONSE] $operation -> $payload',
      name: 'UserRepository',
      level: 800,
    );
  }

  void _logError(String operation, Object error) {
    dev.log(
      '[ERROR] $operation -> $error',
      name: 'UserRepository',
      level: 1000,
    );
  }
}
