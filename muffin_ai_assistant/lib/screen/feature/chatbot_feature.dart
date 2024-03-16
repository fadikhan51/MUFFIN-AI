import 'package:ai_assistant/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controller/chat_controller.dart';
import '../../helper/global.dart';
import '../../widget/message_card.dart';

class ChatBotFeature extends StatefulWidget {
  const ChatBotFeature({super.key});

  @override
  State<ChatBotFeature> createState() => _ChatBotFeatureState();
}

class _ChatBotFeatureState extends State<ChatBotFeature> {
  final _c = ChatController();

  ChatUser myself = ChatUser(id: '1', firstName: 'GuestUser');
  ChatUser gemini = ChatUser(id: '2', firstName: 'Gemini');
  final targetURL =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyDmkcO9mHjejFFWNPSx5sXYSuQZApcc5tU';
  final headers = {'Content-Type': 'application/json'};

  List<ChatMessage> allMessages = [];
  List<ChatUser> currentlyTyping = [];
  XFile? chatImage;


  Future<void> pickImageFromGallery(ImageSource ourSource) async {
    final picker = ImagePicker();
    XFile? imagePicked = await picker.pickImage(source: ourSource);

    if (imagePicked != null) {
      chatImage = imagePicked;
      ChatMedia imageMedia = ChatMedia(
          url: imagePicked.path,
          fileName: imagePicked.name,
          type: MediaType.image);

      ChatMessage imageMessage = ChatMessage(
        medias: [imageMedia],
        user: myself,
        createdAt: DateTime.now(),
      );

      setState(() {
        allMessages.insert(0, imageMessage);
      });
    }
  }

  void queryAboutImage(ChatMessage m) async {
    setState(() {
      currentlyTyping.add(gemini);
      allMessages.insert(0, m);
    });
    try {
      List<int> imageBytes = File(chatImage!.path).readAsBytesSync();
      String base64File = base64.encode(imageBytes);

      String? mimeType = lookupMimeType(chatImage!.path);
      final data = {
        "contents": [
          {
            "parts": [
              {"text": m.text},
              {
                "inlineData": {
                  "mimeType": mimeType,
                  "data": base64File,
                }
              }
            ]
          }
        ],
      };
      const apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro-vision-latest:generateContent?key=AIzaSyDmkcO9mHjejFFWNPSx5sXYSuQZApcc5tU';

      await http
          .post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      )
          .then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          var resText = result['candidates'][0]['content']['parts'][0]['text'];
          allMessages.insert(
            0,
            ChatMessage(user: gemini, createdAt: DateTime.now(), text: resText),
          );
        } else {
          print(response.body);
          var result = jsonDecode(response.body);
          var resText =
              'Sorry the request could not be completed successfully : (\n'
              'Message : ${result['error']['message']}';
          allMessages.insert(
            0,
            ChatMessage(user: gemini, createdAt: DateTime.now(), text: resText),
          );
        }
        setState(() {});
      }).catchError((error) {
        allMessages.insert(
          0,
          ChatMessage(user: gemini, createdAt: DateTime.now(), text: "Error Occurred, Please try again later : )"),
        );
      });
    } catch (e) {
      allMessages.insert(
        0,
        ChatMessage(user: gemini, createdAt: DateTime.now(), text: "Error Occurred, Please try again later : )"),
      );
    }

    setState(() {
      currentlyTyping.remove(gemini);
    });
  }

  void insertIntoMessages(ChatMessage m) async {
    setState(() {
      currentlyTyping.add(gemini);
      allMessages.insert(0, m);
    });

    var query = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(targetURL), headers: headers, body: jsonEncode(query))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);

        ChatMessage response = ChatMessage(
            text: result['candidates'][0]['content']['parts'][0]['text'],
            user: gemini,
            createdAt: DateTime.now());
        allMessages.insert(0, response);
      } else {
        ChatMessage response = ChatMessage(
            text:
            "Sorry, there was an error getting the response back. Please send your query again : )",
            user: gemini,
            createdAt: DateTime.now());
        allMessages.insert(0, response);
      }
    }).catchError((error) {
      ChatMessage response = ChatMessage(
          text:
          "Sorry, there was an error getting the response back. Please send your query again : )",
          user: gemini,
          createdAt: DateTime.now());
      allMessages.insert(0, response);
    });

    setState(() {
      currentlyTyping.remove(gemini);
    });
    chatImage = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with AI Assistant"),
      ),
      body: DashChat(
        typingUsers: currentlyTyping,
        currentUser: myself,
        onSend: (ChatMessage message) {
          chatImage != null
              ? queryAboutImage(message)
              : insertIntoMessages(message);
        },
        messages: allMessages,
        inputOptions: InputOptions(trailing: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              pickImageFromGallery(ImageSource.gallery);
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_sharp),
            onPressed: () {
              pickImageFromGallery(ImageSource.camera);
            },
          )
        ]),
      ),
    );
  }
}
