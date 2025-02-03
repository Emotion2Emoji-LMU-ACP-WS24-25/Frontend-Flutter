import 'package:flutter/material.dart';

class ProfileModel extends ChangeNotifier {
  Map<int, String> customReactions = {};

  get userReactions => null; 

  void setCustomReaction(int index, String emojiPath) {
    customReactions[index] = emojiPath;
    notifyListeners(); 
  }
}
