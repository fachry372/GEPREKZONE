import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/admin_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
        primaryColor: const Color(0xffe53935),
      ),
      debugShowCheckedModeBanner: false,
      home: const AdminPage(),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final supabase = Supabase.instance.client;

  int totalMenu = 0;
  int totalUser = 0;
  int totalMeja = 0;

  bool isLoading = true;

  Future<void> getDashboardData() async {
    setState(() => isLoading = true);

    final menu = await supabase.from('products').select();
    final user = await supabase.from('users').select();
    final meja = await supabase.from('meja').select();

    setState(() {
      totalMenu = menu.length;
      totalUser = user.length;
      totalMeja = meja.length;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDashboardData();
  }

  Widget infoCard(IconData icon, String title, String total) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.red, size: 30),
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 5),
          Text(
            total,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      drawer: const AdminDrawer(),
     
      body: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 35, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe51c23), Color(0xffb31217)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu,
                        color: Colors.white, size: 22),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                const Text(
                  "GEPREKZONE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.red, size: 18),
                ),
              ],
            ),
          ),

          /// CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ListView(
                children: [
                  const Text(
                    "Dashboard Admin",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// LOADING / DATA
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            infoCard(Icons.restaurant_menu, "Total Menu",
                                totalMenu.toString()),
                            infoCard(Icons.people, "Total User",
                                totalUser.toString()),
                            infoCard(Icons.table_bar, "Total Meja",
                                totalMeja.toString()),
                          ],
                        ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}