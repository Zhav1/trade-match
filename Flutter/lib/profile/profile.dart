import 'package:flutter/material.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFFD7E14);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
                ),
              ],
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/profile.jpg',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.12),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.white.withOpacity(0.95)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 56,
                            backgroundImage: AssetImage('assets/images/pp-1.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: primary,
                    tabs: const [Tab(text: 'Ditawarkan'), Tab(text: 'Dicari')],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: const [
                    SizedBox(height: 8),
                    _ProfileInfo(),
                  ],
                ),
              ),
            ),
          ],
          body: const TabBarView(children: [_ItemList(isOffer: true), _ItemList(isOffer: false)]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          backgroundColor: primary,
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Qhanakin Putri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Medan, Indonesia', style: TextStyle(color: Colors.grey[700])),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _StatItem(value: '8', title: 'Offers'),
            _StatItem(value: '3', title: 'Requests'),
            _StatItem(value: '5', title: 'Trades'),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String title;
  const _StatItem({required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
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
            {"name": "Laptop Asus", "status": "Aktif", "color": Colors.green},
            {"name": "Sepeda Fixie", "status": "Dalam Proses", "color": Colors.orange},
            {"name": "Kamera Canon", "status": "Selesai", "color": Colors.red},
          ]
        : [
            {"name": "iPhone Bekas", "status": "Aktif", "color": Colors.green},
            {"name": "Kursi Gaming", "status": "Aktif", "color": Colors.green},
          ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.inventory_2_outlined, color: Colors.black54)),
          title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(item['status'] as String, style: TextStyle(color: Colors.grey[700])),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {},
        );
      },
    );
  }
}

// Note: no unused helper delegates remain. If you later need a sticky TabBar, re-add
// a SliverPersistentHeaderDelegate here.