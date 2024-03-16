import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:translator_plus/translator_plus.dart';

import '../helper/global.dart';

class APIs {
  //get answer from chat gpt
  static Future<String> getAnswer(String question) async {
    try {
      //
      final res =
          await post(Uri.parse('https://api.openai.com/v1/chat/completions'),

              //headers
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'Bearer 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'
              },

              //body
              body: jsonEncode({
                "model": "gpt-3.5-turbo",
                "max_tokens": 2000,
                "temperature": 0,
                "messages": [
                  {"role": "user", "content": question},
                ]
              }));

      final data = jsonDecode(res.body);

      log('res: $data');
      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('getAnswerE: $e');
      return 'Something went wrong (Try again in sometime)';
    }
  }

  static Future<List<String>> searchAiImages(String prompt) async {
    final headers = {
      'accept': 'application/json',
      'authorization': 'Bearer key-1SzFv3T4hknQGGTfEnS8twOx7hPxF6VvBrdyudRiEOrnoShTskyj9Yn6x11Ot4XcAq40QfWCIV1k3aBaHIJIW5mF8GV2p6fq',
      'content-type': 'application/json'
    };

    try {
      final data1 = {
        'prompt': prompt
      };
      final res = await http.post(
        Uri.parse('https://api.getimg.ai/v1/essential/text-to-image'),
        headers: headers,
        body: jsonEncode(data1),
      );

      if (res.statusCode == 200) {
        List<String> base64String = [jsonDecode(res.body)['image']];
        return base64String;
      } else {
        return [];
      }
    } catch (e) {
      print('searchAiImagesE: $e');
      return [];
    }
  }

  static Future<String> googleTranslate(
      {required String from, required String to, required String text}) async {
    try {
      final res = await GoogleTranslator().translate(text, from: from, to: to);

      return res.text;
    } catch (e) {
      log('googleTranslateE: $e ');
      return 'Something went wrong!';
    }
  }
}
