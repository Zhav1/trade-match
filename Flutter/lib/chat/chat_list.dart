import 'package:flutter/material.dart';
import 'package:Flutter/chat/chat_detail.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
  final Color primary = Theme.of(context).colorScheme.primary;
  final Color background = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Messages",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF441606), // warna cokelat tua
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 3),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/filter.png',
                        width: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search messages...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _conversationTile(context, '1', 'Emilie', 'pp-1.png', 'Halo 👋', '23 min'),
                    _conversationTile(context, '2', 'Rafi', 'pp-1.png', 'Itu HP-nya ada minus di bagian mana ya?', '3 min'),
                    _conversationTile(context, '3', 'Tania', 'pp-2.png', 'Kalau aku tukar sama headset JBL boleh gak?', '10 min'),
                    _conversationTile(context, '4', 'Johan', 'pp-3.png', 'Kardus dan chargernya masih lengkap?', '28 min'),
                    _conversationTile(context, '5', 'Mira', 'pp-4.png', 'Kondisi barang masih mulus ya? pengen liat fotonya 📸', '1 hr'),
                    _conversationTile(context, '6', 'Dina', 'pp-5.png', 'Tuker sama sepatu Nike size 42 mau gak?', '2 hr'),
                    _conversationTile(context, '7', 'Andra', 'pp-6.png', 'Oke, nanti aku kirim lewat kurir aja ya ', 'Yesterday'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primary,
        child: const Icon(Icons.message_rounded, color: Colors.white),
      ),
    );
  }

  Widget _conversationTile(BuildContext context, String matchId, String name, String image, String preview, String time) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(radius: 26, backgroundImage: AssetImage('assets/images/$image')),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
            child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatDetailPage(matchId: matchId, otherUserName: name, otherUserImage: image)));
      },
    );
  }
}