import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header + Gambar Profil
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(
                      "assets/images/profile.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  "Qhanakin Putri",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  "Medan, Indonesia",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xffFFF8ED),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _StatItem(title: "Offers", value: "8"),
                      _StatItem(title: "Requests", value: "3"),
                      _StatItem(title: "Trades", value: "5"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xffFD7E14),
                      tabs: [
                        Tab(text: "Ditawarkan"),
                        Tab(text: "Dicari"),
                      ],
                    ),
                    SizedBox(
                      height: 250,
                      child: TabBarView(
                        children: [
                          _ItemList(isOffer: true),
                          _ItemList(isOffer: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pengaturan Akun",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SettingTile(icon: Icons.person, title: "Ubah Foto / Bio"),
                    _SettingTile(icon: Icons.lock, title: "Ganti Password"),
                    _SettingTile(icon: Icons.notifications, title: "Notifikasi Barter"),
                    _SettingTile(icon: Icons.logout, title: "Logout", isDanger: true),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Column(
                children: const [
                  Text(
                    "Rating Pengguna",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star_half, color: Colors.amber),
                      Icon(Icons.star_border, color: Colors.amber),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Trader Aktif ⭐️ | Respons Cepat ⚡️",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  final bool isOffer;
  const _ItemList({required this.isOffer});

  @override
  Widget build(BuildContext context) {
    final items = isOffer
        ? [
      {"name": "Laptop Asus", "status": "🟢 Aktif"},
      {"name": "Sepeda Fixie", "status": "🟡 Dalam Proses"},
      {"name": "Kamera Canon", "status": "🔴 Selesai"},
    ]
        : [
      {"name": "iPhone Bekas", "status": "🟢 Aktif"},
      {"name": "Kursi Gaming", "status": "🟢 Aktif"},
      {"name": "Monitor 24 inch", "status": "🟡 Dalam Proses"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: ListTile(
            leading: const Icon(Icons.inventory_2_outlined, color: Colors.black),
            title: Text(item["name"]!),
            subtitle: Text(item["status"]!),
          ),
        );
      },
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
