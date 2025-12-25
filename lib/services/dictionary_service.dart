import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> fetchMeaning(String word) async {
  try {
    final response = await http.get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0]['meanings'][0]['definitions'][0]['definition'];
    }
  } catch (_) {}

  return 'Meaning not available';
}
