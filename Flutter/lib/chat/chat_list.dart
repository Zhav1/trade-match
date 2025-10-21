import 'package:flutter/material.dart';
import 'package:Flutter/chat/widget_Template/chat_list_widget.dart';

class ChatListScreen extends StatefulWidget{
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}
class _ChatListScreenState extends State<ChatListScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Column(
        children: [
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                    "Messages",
                  style: TextStyle(
                    fontFamily: "Sk-Modernist",
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: Color(0xffE8E6EA)),
                    color: Color(0xffF8F9FA),
                  ),
                  child: Image.asset('assets/images/filter.png'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          const SizedBox(
            height: 48,
            width: 295,
            child:
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  hintText: "Search",
                  hintStyle: TextStyle(
                    fontFamily: "Sk-Modernist",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  )
                ),
          ),
          const SizedBox(height: 30,),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 49,),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Image.asset('assets/images/pp-1.png'),
                        ),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Emilie",
                              style: TextStyle(
                                fontFamily: "Sk-Modernist",
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Halo",
                              style: TextStyle(
                                fontFamily: "Sk-Modernist",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            "23 min",
                          style: TextStyle(
                            fontFamily: "Sk-Modernist",
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffADAFBB),
                          ),
                        ),
                        const SizedBox(width: 48,),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                const SizedBox(width: 165,),
                Container(
                  height: 2,
                  width: 285,
                  color: Color(0xffE8E6EA),
                ),

            ChatList(
            image: "pp-1.png",
            name: "Rafi",
            message: "Itu HP-nya ada minus di bagian mana ya?",
            time: "3 min",
            ),
                const SizedBox(height: 5,),
                const SizedBox(width: 165,),
                Container(
                  height: 2,
                  width: 285,
                  color: Color(0xffE8E6EA),
                ),
            ChatList(
              image: "pp-2.png",
              name: "Tania",
              message: "Kalau aku tukar sama headset JBL boleh gak?",
              time: "10 min",
            ),
                const SizedBox(height: 5,),
                const SizedBox(width: 165,),
                Container(
                  height: 2,
                  width: 285,
                  color: Color(0xffE8E6EA),
                ),
            ChatList(
              image: "pp-3.png",
              name: "Johan",
              message: "Kardus dan chargernya masih lengkap?",
              time: "28 min",
            ),
                const SizedBox(height: 5,),
                const SizedBox(width: 165,),
                Container(
                  height: 2,
                  width: 285,
                  color: Color(0xffE8E6EA),
                ),
            ChatList(
              image: "pp-4.png",
              name: "Mira",
              message: "Kondisi barang masih mulus ya? pengen liat fotonya 📸",
              time: "1 hr",
            ),
                const SizedBox(height: 5,),
                const SizedBox(width: 165,),
                Container(
                  height: 2,
                  width: 285,
                  color: Color(0xffE8E6EA),
                ),
            ChatList(
              image: "pp-5.png",
              name: "Dina",
              message: "Tuker sama sepatu Nike size 42 mau gak?",
              time: "2 hr",
            ),
                const SizedBox(height: 5,),
                const SizedBox(width: 165,),
                Container(
                  height: 2,
                  width: 285,
                  color: Color(0xffE8E6EA),
                ),
            ChatList(
              image: "pp-6.png",
              name: "Andra",
              message: "Oke, nanti aku kirim lewat kurir aja ya 📦",
              time: "Yesterday",
            ),
                const SizedBox(height: 5,),
                const SizedBox(width: 165,),
                Container(
                  height: 2,
                  width: 285,
                  color: Color(0xffE8E6EA),
                ),



        ],
            ),
          )
        ],
      ),
    );
  }
}