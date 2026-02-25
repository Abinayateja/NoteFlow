import 'package:flutter/material.dart';
import '../screens/songs_screen.dart';
import '../screens/liked_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        children: [

          DrawerHeader(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.deepPurple, Colors.black],
    ),
  ),
  child: Row(
    children: [

      Image.asset(
        "assets/images/app_logo.png",
        height:40,
        width: 40,
        fit: BoxFit.contain,
      ),

      const SizedBox(width:10),

      const Text(
        "N o t e F l o w",
        style: TextStyle(
          color: Colors.white,
          fontSize:22,
          fontWeight: FontWeight.bold,
        ),
      ),

    ],
  ),
),

          ListTile(
            leading: const Icon(Icons.library_music, color: Colors.white),
            title: const Text("S O N G S"),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder:(_)=> const SongsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text("L I K E D"),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder:(_)=> const LikedSongsScreen()),
              );
            },
          ),

        ],
      ),
    );
  }
}