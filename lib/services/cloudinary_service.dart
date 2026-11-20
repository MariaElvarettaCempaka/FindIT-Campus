import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Helper Service untuk mengunggah media gambar ke Cloudinary CDN
/// Sesuai SOP & Panduan Operasi Backend Tim FindIT Campus PAB 2026.
/// - Unsigned Upload Mode (aman tanpa API Secret di client)
/// - Kompatibel lintas platform (Flutter Web, Android, iOS, Desktop)
class CloudinaryService {
  CloudinaryService._();

  // Kredensial Resmi Tim FindIT Campus
  static const String cloudName = 'igxzr7cc';
  static const String uploadPreset = 'findit_unsigned';

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Mengunggah berkas [XFile] ke Cloudinary dan mengembalikan secure HTTPS URL
  /// Mengembalikan `null` jika pengunggahan gagal.
  static Future<String?> uploadImage(XFile file) async {
    try {
      debugPrint('[CloudinaryService] Memulai unggah gambar: ${file.name}');

      final uri = Uri.parse(_uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Parameter Unsigned Cloudinary
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'findit_campus/reports';

      // Baca byte gambar (kompatibel penuh Web dan Mobile)
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name.isNotEmpty ? file.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      // Kirim request ke Cloudinary API
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 35),
            onTimeout: () => throw Exception('Koneksi upload Cloudinary timeout'),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? secureUrl = data['secure_url'] as String?;
        debugPrint('[CloudinaryService] Berhasil unggah foto: $secureUrl');
        return secureUrl;
      } else {
        debugPrint(
          '[CloudinaryService] Gagal unggah (${response.statusCode}): ${response.body}',
        );
        return null;
      }
    } catch (e, stack) {
      debugPrint('[CloudinaryService] Error saat upload ke Cloudinary: $e');
      debugPrint(stack.toString());
      return null;
    }
  }
}
