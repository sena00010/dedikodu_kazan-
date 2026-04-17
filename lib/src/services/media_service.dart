import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

final mediaServiceProvider = Provider((ref) => MediaService(ref.read(apiClientProvider)));

class UploadedMedia {
  const UploadedMedia({
    required this.url,
    required this.mediaType,
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.durationMs,
  });

  final String url;
  final String mediaType;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final int? durationMs;

  Map<String, dynamic> toMessagePayload({String content = ''}) => {
        'content': content,
        'message_type': mediaType,
        'media_url': url,
        'file_name': fileName,
        'mime_type': mimeType,
        'file_size': fileSize,
        'duration_ms': durationMs,
      };
}

class MediaService {
  const MediaService(this._api);
  final ApiClient _api;

  Future<UploadedMedia> upload(File file, String mediaType, {int? durationMs}) async {
    final form = FormData.fromMap({
      'media_type': mediaType,
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });
    final res = await _api.dio.post<Map<String, dynamic>>('/api/uploads', data: form);
    final json = res.data!;
    return UploadedMedia(
      url: json['url'] as String,
      mediaType: json['media_type'] as String? ?? mediaType,
      fileName: json['file_name'] as String?,
      mimeType: json['mime_type'] as String?,
      fileSize: json['file_size'] as int?,
      durationMs: durationMs,
    );
  }
}
