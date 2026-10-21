import 'dart:convert';
import 'dart:io';

import 'package:cash_up/utilities/api_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

enum APIMethod { post, get, delete, put }

class ApiServices {
  static final http.Client client = http.Client();

  static Future<dynamic> api({
    Map<String, dynamic> requestBodyMap = const {},
    required String endPoint,
    bool withToken = true,
    String param = "",
    int version = 1,
    required APIMethod type,
    Map<String, String> additionalHeaders = const {},
  }) async {
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    final Uri url = Uri.parse("$kBaseUrl$endPoint$param");

    if (withToken) {
      headers.addAll(_authHeaders());
    }

    headers.addAll(additionalHeaders);
    debugPrint("Additional Headers : ${jsonEncode(additionalHeaders)}");

    final String body = jsonEncode(requestBodyMap);
    debugPrint("REQUEST BODY : $body");

    final http.Response response = switch (type) {
      APIMethod.post => await client.post(url, headers: headers, body: body),
      APIMethod.get => await client.get(url, headers: headers),
      APIMethod.put => await client.put(url, headers: headers, body: body),
      APIMethod.delete => await client.delete(url, headers: headers),
    };

    debugPrint("URL PARSE : $url");
    debugPrint("$endPoint RESPONSE BODY : ${response.body}");
    debugPrint("HTTP STATUS CODE: ${response.statusCode}");

    return _decode(response.body);
  }

  static Future<dynamic> apiFormData({
    required String endPoint,
    required Map<String, String> requestBodyMap,
    File? media,
    String param = "",
    Map<String, String> additionalHeaders = const {},
  }) async {
    final Map<String, String> headers = {
      "Accept": "application/json",
      ..._authHeaders(),
      ...additionalHeaders,
    };

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("kBaseUrl$endPoint$param"),
    );

    request.headers.addAll(headers);
    request.fields.addAll(requestBodyMap);

    if (media != null) {
      final String fileExtension = media.path.split('.').last.toLowerCase();
      final String mimeType = _getMimeType(fileExtension);

      request.files.add(
        await http.MultipartFile.fromPath(
          'Media',
          media.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");
    debugPrint("Headers $headers");

    return _decode(response.body);
  }

  static Map<String, String> _authHeaders() {
    final box = GetStorage();
    final String phone = box.read('phone')?.toString() ?? '';
    final String token = box.read('token')?.toString() ?? '';

    debugPrint("Token : $token");

    return {"phoneNumber": phone, "token": token};
  }

  static dynamic _decode(String body) {
    try {
      return body.isNotEmpty ? json.decode(body) : null;
    } catch (e) {
      debugPrint('ERROR SERVICES $body');
      return null;
    }
  }

  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'ico':
        return 'image/x-icon';
      case 'mp4':
        return 'video/mp4';
      case 'm4v':
        return 'video/x-m4v';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'wmv':
        return 'video/x-ms-wmv';
      case 'flv':
        return 'video/x-flv';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'flac':
        return 'audio/flac';
      case 'm4a':
        return 'audio/mp4';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      default:
        return 'application/octet-stream';
    }
  }
}
