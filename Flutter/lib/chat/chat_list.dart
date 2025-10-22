import 'package:flutter/material.dart';
import 'package:Flutter/widget_Template/chat_list_widget.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFFFD7E14);
    final Color background = const Color(0xFFFFF8ED);
    final Color borderColor = const Color(0xFFE8E6EA);

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
                  children:  [
                    ChatList(
                      image: "pp-1.png",
                      name: "Emilie",
                      message: "Halo 👋",
                      time: "23 min",
                    ),
                    ChatList(
                      image: "pp-1.png",
                      name: "Rafi",
                      message: "Itu HP-nya ada minus di bagian mana ya?",
                      time: "3 min",
                    ),
                    ChatList(
                      image: "pp-2.png",
                      name: "Tania",
                      message: "Kalau aku tukar sama headset JBL boleh gak?",
                      time: "10 min",
                    ),
                    ChatList(
                      image: "pp-3.png",
                      name: "Johan",
                      message: "Kardus dan chargernya masih lengkap?",
                      time: "28 min",
                    ),
                    ChatList(
                      image: "pp-4.png",
                      name: "Mira",
                      message: "Kondisi barang masih mulus ya? pengen liat fotonya 📸",
                      time: "1 hr",
                    ),
                    ChatList(
                      image: "pp-5.png",
                      name: "Dina",
                      message: "Tuker sama sepatu Nike size 42 mau gak?",
                      time: "2 hr",
                    ),
                    ChatList(
                      image: "pp-6.png",
                      name: "Andra",
                      message: "Oke, nanti aku kirim lewat kurir aja ya 📦",
                      time: "Yesterday",
                    ),
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
}
