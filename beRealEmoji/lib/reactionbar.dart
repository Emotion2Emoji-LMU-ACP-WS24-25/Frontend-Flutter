import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  final bool isExpanded;
  final List<dynamic> reactions;
  final List<String> reactionLabels;
  final Function(int) onPickImage;

  const ReactionBar({
    Key? key,
    required this.isExpanded,
    required this.reactions,
    required this.reactionLabels,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            isExpanded ? "Click on an emoji to change it" : "Reactions",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(reactions.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => onPickImage(index),
                      child: reactions[index] is String
                          ? Image.asset(
                              reactions[index],  
                              width: 40,
                              height: 40,
                            )
                          : Image.memory(
                              reactions[index],  
                              width: 40,
                              height: 40,
                            ),
                    ),
                    if (isExpanded)
                      Text(
                        reactionLabels[index],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
