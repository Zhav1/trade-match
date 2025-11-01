import 'package:flutter/material.dart';

class ChatDetailPage extends StatelessWidget {
  final String name;
  final String image;

  const ChatDetailPage({Key? key, required this.name, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/images/$image')),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Mock messages
                  _buildBubble(context, 'Hi! Ini sample chat.', false),
                  _buildBubble(context, 'Halo, apakah barangnya masih ada?', true),
                  _buildBubble(context, 'Masih ada, mau lihat foto lagi?', false),
                ],
              ),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: Colors.grey)),
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: 'Tulis pesan...', border: InputBorder.none),
            ),
          ),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.primary,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }
}
