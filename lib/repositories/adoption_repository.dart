import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:spogpaws/models/adoption_post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdoptionRepositoryException implements Exception {
  AdoptionRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'AdoptionRepositoryException: $message';
}

class AdoptionRepository {
  AdoptionRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> createAdoptionPost({
    required String petType,
    required String petName,
    required String breed,
    required String age,
    required String vaccinated,
    required String aboutPet,
    required String city,
    required String nearbyArea,
    required String contactName,
    required String contactPhone,
    List<String> photoUrls = const [],
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AdoptionRepositoryException(
        'You must be logged in to create a post.',
      );
    }

    final payload = {
      'user_id': user.id,
      'pet_type': petType,
      'pet_name': petName,
      'breed': breed,
      'age': age,
      'vaccinated': vaccinated,
      'about_pet': aboutPet,
      'city': city,
      'nearby_area': nearbyArea,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'photo_urls': photoUrls,
    };

    _logRequest('adoptions.insert', payload);
    try {
      await _client.from('adoptions').insert(payload);
      _logResponse('adoptions.insert', {'created': true, 'userId': user.id});
    } on PostgrestException catch (e) {
      _logError('adoptions.insert', e);
      throw AdoptionRepositoryException(
        'Failed to create adoption post: ${e.message}',
      );
    } catch (_) {
      _logError('adoptions.insert', 'Unknown error');
      throw AdoptionRepositoryException('Failed to create adoption post.');
    }
  }

  Future<List<String>> uploadAdoptionPhotos({
    required List<Uint8List> files,
    required List<String> extensions,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AdoptionRepositoryException(
        'You must be logged in to upload photos.',
      );
    }
    if (files.isEmpty) {
      return const [];
    }
    if (files.length != extensions.length) {
      throw AdoptionRepositoryException('Invalid photo upload payload.');
    }

    const bucket = 'adoption-photos';
    final now = DateTime.now().millisecondsSinceEpoch;
    final uploadedUrls = <String>[];

    try {
      for (var i = 0; i < files.length; i++) {
        final ext = _normalizeExtension(extensions[i]);
        final objectPath = '${user.id}/$now-$i.$ext';
        await _client.storage
            .from(bucket)
            .uploadBinary(
              objectPath,
              files[i],
              fileOptions: FileOptions(
                contentType: _contentTypeFor(ext),
                upsert: false,
              ),
            );
        uploadedUrls.add(_client.storage.from(bucket).getPublicUrl(objectPath));
      }

      _logResponse('adoptions.photos.upload', {'count': uploadedUrls.length});
      return uploadedUrls;
    } on StorageException catch (e) {
      _logError('adoptions.photos.upload', e);
      throw AdoptionRepositoryException(
        'Failed to upload photos: ${e.message}',
      );
    } catch (_) {
      _logError('adoptions.photos.upload', 'Unknown error');
      throw AdoptionRepositoryException('Failed to upload photos.');
    }
  }

  Future<List<AdoptionPost>> getMyPosts() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AdoptionRepositoryException(
        'You must be logged in to view your posts.',
      );
    }

    _logRequest('adoptions.select.my_posts', {'user_id': user.id});
    try {
      final response = await _client
          .from('adoptions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((item) => AdoptionPost.fromMap(item as Map<String, dynamic>))
          .toList();

      _logResponse('adoptions.select.my_posts', {'count': list.length});
      return list;
    } on PostgrestException catch (e) {
      _logError('adoptions.select.my_posts', e);
      throw AdoptionRepositoryException(
        'Failed to fetch your posts: ${e.message}',
      );
    } catch (_) {
      _logError('adoptions.select.my_posts', 'Unknown error');
      throw AdoptionRepositoryException('Failed to fetch your posts.');
    }
  }

  Future<List<AdoptionPost>> getActivePosts({
    int limit = 10,
    int offset = 0,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AdoptionRepositoryException('You must be logged in to view posts.');
    }

    final rangeEnd = offset + limit - 1;
    _logRequest('adoptions.select.active', {
      'status': 'approved',
      'offset': offset,
      'limit': limit,
    });

    try {
      final response = await _client
          .from('adoptions')
          .select()
          .eq('status', 'approved')
          .order('created_at', ascending: false)
          .range(offset, rangeEnd);

      final list = (response as List)
          .map((item) => AdoptionPost.fromMap(item as Map<String, dynamic>))
          .toList();

      _logResponse('adoptions.select.active', {
        'offset': offset,
        'limit': limit,
        'count': list.length,
      });
      return list;
    } on PostgrestException catch (e) {
      _logError('adoptions.select.active', e);
      throw AdoptionRepositoryException(
        'Failed to fetch active posts: ${e.message}',
      );
    } catch (_) {
      _logError('adoptions.select.active', 'Unknown error');
      throw AdoptionRepositoryException('Failed to fetch active posts.');
    }
  }

  Future<void> updatePostStatus({
    required String postId,
    required String status,
  }) async {
    _logRequest('adoptions.update.status', {'id': postId, 'status': status});
    try {
      await _client
          .from('adoptions')
          .update({'status': status})
          .eq('id', postId);
      _logResponse('adoptions.update.status', {
        'id': postId,
        'status': status,
        'updated': true,
      });
    } on PostgrestException catch (e) {
      _logError('adoptions.update.status', e);
      throw AdoptionRepositoryException(
        'Failed to update post status: ${e.message}',
      );
    } catch (_) {
      _logError('adoptions.update.status', 'Unknown error');
      throw AdoptionRepositoryException('Failed to update post status.');
    }
  }

  Future<void> submitAdoptionReport({
    required String adoptionId,
    required String reason,
    String details = '',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AdoptionRepositoryException(
        'You must be logged in to report a post.',
      );
    }

    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw AdoptionRepositoryException('Report reason is required.');
    }

    final payload = {
      'adoption_id': adoptionId,
      'reporter_user_id': user.id,
      'reason': trimmedReason,
      'details': details.trim(),
    };

    _logRequest('adoption_reports.insert', payload);
    try {
      await _client.from('adoption_reports').insert(payload);
      _logResponse('adoption_reports.insert', {
        'adoption_id': adoptionId,
        'reporter_user_id': user.id,
        'created': true,
      });
    } on PostgrestException catch (e) {
      _logError('adoption_reports.insert', e);
      throw AdoptionRepositoryException(
        'Failed to submit report: ${e.message}',
      );
    } catch (_) {
      _logError('adoption_reports.insert', 'Unknown error');
      throw AdoptionRepositoryException('Failed to submit report.');
    }
  }

  void _logRequest(String operation, Map<String, Object?> payload) {
    dev.log('[REQUEST] $operation -> $payload', name: 'AdoptionRepository');
  }

  void _logResponse(String operation, Map<String, Object?> payload) {
    dev.log('[RESPONSE] $operation -> $payload', name: 'AdoptionRepository');
  }

  void _logError(String operation, Object error) {
    dev.log(
      '[ERROR] $operation -> $error',
      name: 'AdoptionRepository',
      level: 1000,
    );
  }

  String _normalizeExtension(String extension) {
    final sanitized = extension.trim().toLowerCase().replaceAll('.', '');
    return sanitized.isEmpty ? 'jpg' : sanitized;
  }

  String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'jpeg':
      case 'jfif':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
