import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> uploadImageToCloudinary(String imagePath) async {
  final url = Uri.parse('https://api.cloudinary.com/v1_1/rentevent/upload');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = 'autodisp123'
    ..files.add(await http.MultipartFile.fromPath('file', imagePath));

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.toBytes();
      final responseString = String.fromCharCodes(body);
      final jsonMap = jsonDecode(responseString);

      final url = jsonMap['url'];
      return url;
    } else {
      print('Error uploading image: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exception caught: $e');
    return null;
  }
}
