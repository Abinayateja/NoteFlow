import 'package:flutter/material.dart';
import '../data/liked_songs.dart';
import '../models/song_model.dart';
import 'player_screen.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {

  void removeSong(Song song){
    setState(() {
      likedSongs.removeWhere((s)=> s.name == song.name);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Liked Songs")),

      body: ListView.builder(
        itemCount: likedSongs.length,
        itemBuilder:(context,index){

          final song = likedSongs[index];

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors:[Colors.deepPurple, Colors.black],
              ),
              boxShadow:[
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 10,
                )
              ]
            ),

            child: ListTile(

              leading: Image.asset(song.cover, width:60),

              title: Text(song.name,
                style: const TextStyle(color:Colors.white),
              ),

              trailing: IconButton(

                icon: const Icon(Icons.favorite,
                  color: Colors.red,
                  size:30,
                ),

                onPressed: (){
                  removeSong(song);
                },
              ),

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:(_)=> PlayerScreen(song: song.name),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}