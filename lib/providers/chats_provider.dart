import 'package:flutter/cupertino.dart';

import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  List<Map<String, dynamic>> convertToClaudeMessagesList(
      List<ChatModel> chatModels) {
    List<Map<String, dynamic>> claudeMessages = [];

    for (int i = 0; i < chatModels.length; i++) {
      if (i % 2 == 0) {
        claudeMessages.add({"role": "user", "content": chatModels[i].msg});
      } else {
        claudeMessages.add({"role": "assistant", "content": chatModels[i].msg});
      }
    }

    return claudeMessages;
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String chosenModelId}) async {
    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      chatList.addAll(await ApiService.sendMessageGPT(
        message: msg,
        modelId: chosenModelId,
      ));
    } else if (chosenModelId.toLowerCase().startsWith("claude-3")) {
      chatList.addAll(await ApiService.sendMessageClaude(
        message: convertToClaudeMessagesList(chatList),
        modelId: chosenModelId,
      ));
    } else {
      chatList.addAll(await ApiService.sendMessage(
        message: msg,
        modelId: chosenModelId,
      ));
    }
    notifyListeners();
  }
}
