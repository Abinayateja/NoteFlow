import 'package:ai_voice_music/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/voice_service.dart';
import '../services/groq_service.dart';
import '../data/liked_songs.dart';
import '../data/song_data.dart';
import 'dart:math';

class PlayerScreen extends StatefulWidget {

  final String? song;

  const PlayerScreen({super.key, this.song});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController rotationController;
  bool isProcessingAI = false;

  final AudioPlayer player = AudioPlayer();

  bool isPlaying = false;

  String currentSong = "believer";

  Map<String,String> covers = {

  "believer":"assets/images/believer.jpg",
  "focus":"assets/images/focus.jpg",
  "chill":"assets/images/chill.jpeg",
  "cheapthrills":"assets/images/cheapthrills.png",
  "company":"assets/images/company.jpg",
  "friends":"assets/images/friends.jpg",
  "lovemelikeyoudo":"assets/images/lovemelikeyoudo.jpg",
  "memories":"assets/images/memories.jpeg",
  "perfect":"assets/images/perfect.jpg",
  "playdate":"assets/images/playdate.jpeg",
  "rockabye":"assets/images/rockabye.jpeg",
  "shapeofyou":"assets/images/shapeofyou.png",

};

Map<String,String> songs = {

  "believer":"assets/music/believer.mp3",
  "focus":"assets/music/focus.mp3",
  "chill":"assets/music/chill.mp3",
  "cheapthrills":"assets/music/cheapthrills.mp3",
  "company":"assets/music/company.mp3",
  "friends":"assets/music/marshmello-friends.mp3",
  "lovemelikeyoudo":"assets/music/lovemelikeyoudo.mp3",
  "memories":"assets/music/memories.mp3",
  "perfect":"assets/music/perfect.mp3",
  "playdate":"assets/music/playdate.mp3",
  "rockabye":"assets/music/rockabye.mp3",
  "shapeofyou":"assets/music/shapeofyou.mp3",

};

  List<String> songKeys = [

  "believer",
  "focus",
  "chill",
  "cheapthrills",
  "company",
  "friends",
  "lovemelikeyoudo",
  "memories",
  "perfect",
  "playdate",
  "rockabye",
  "shapeofyou",

];
Map<String,List<String>> moodSongs = {

  "relax": ["chill","memories","rockabye"],

  "focus": ["focus","company"],

  "happy": ["believer","perfect","cheapthrills","playdate"],

  "love": ["lovemelikeyoudo","friends","shapeofyou"],

};



  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 20),
);
    

    if(widget.song != null){
      currentSong = widget.song!;
    }

    player.playerStateStream.listen((state){
      if(state.playing){
    rotationController.repeat();
  }else{
    rotationController.stop();
  }
      if(mounted){
        setState(() {
          isPlaying = state.playing;
        });
      }
    });

    playSong(currentSong);
  }

String getRandomSong(String mood){

  final list = moodSongs[mood]!;

  final random = Random();

  return list[random.nextInt(list.length)];
}
  Future playSong(String key) async {

    currentIndex = songKeys.indexOf(key);

    await player.setAsset(songs[key]!);
    player.play();

    setState(() {
      currentSong = key;
      isPlaying = true;
    });
  }

  void nextSong() {
    currentIndex++;
    if(currentIndex >= songKeys.length){
      currentIndex = 0;
    }
    playSong(songKeys[currentIndex]);
  }

  void previousSong() {
    currentIndex--;
    if(currentIndex < 0){
      currentIndex = songKeys.length - 1;
    }
    playSong(songKeys[currentIndex]);
  }
Future startVoiceCommand() async {

  setState(() {
    isProcessingAI = true;
  });

  String spokenText = await startListening();

  String mood = await askGroq(spokenText);

  print("AI MOOD: $mood");

  setState(() {
    isProcessingAI = false;
  });

  if(mood.contains("relax")){
    playSong(getRandomSong("relax"));

  }else if(mood.contains("focus")){
    playSong(getRandomSong("focus"));

  }else if(mood.contains("love")){
    playSong(getRandomSong("love"));

  }else{
    playSong(getRandomSong("happy"));
  }
}

  // ✅ FIXED FAVORITE LOGIC
  void toggleFavorite() {

    final selectedSong = allSongs.firstWhere(
      (song) => song.name == currentSong,
    );

    setState(() {

      if(likedSongs.any((s) => s.name == selectedSong.name)){
        likedSongs.removeWhere((s) => s.name == selectedSong.name);
      }else{
        likedSongs.add(selectedSong);
      }

    });
  }

  bool isLiked() {

    return likedSongs.any((s) => s.name == currentSong);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

  title: Row(
    children: [

      Image.asset(
        "assets/images/app_logo.png",
        height:40,
        width: 40,
        fit: BoxFit.contain,

      ),

      const SizedBox(width:10),

      Text(currentSong),
    ],
  ),

),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors:[Colors.deepPurple, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[

                RotationTransition(
  turns: rotationController,
  child: Image.asset(
    covers[currentSong] ?? covers["believer"]!,
    height:150,
  ),
),

                const SizedBox(height:20),

                Text(
                  currentSong,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize:22,
                  ),
                ),

                // ✅ FIXED FAVORITE BUTTON
                IconButton(
                  icon: Icon(
                    isLiked()
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                    size:30,
                  ),
                  onPressed: toggleFavorite,
                ),

                const SizedBox(height:20),

                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder:(context,snapshot){

                    final position = snapshot.data ?? Duration.zero;
                    final total = player.duration ?? Duration.zero;

                    return Slider(
                      min:0,
                      max: total.inSeconds == 0
                          ? 1
                          : total.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble().clamp(
                        0,
                        total.inSeconds == 0
                            ? 1
                            : total.inSeconds.toDouble(),
                      ),
                      onChanged:(value){
                        player.seek(Duration(seconds:value.toInt()));
                      },
                    );
                  },
                ),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder:(context,snapshot){

                    final position = snapshot.data ?? Duration.zero;
                    final total = player.duration ?? Duration.zero;

                    String format(Duration d){
                      String two(int n)=> n.toString().padLeft(2,'0');
                      final min = two(d.inMinutes.remainder(60));
                      final sec = two(d.inSeconds.remainder(60));
                      return "$min:$sec";
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal:20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[

                          Text(
                            format(position),
                            style: const TextStyle(color: Colors.white),
                          ),

                          Text(
                            format(total),
                            style: const TextStyle(color: Colors.white),
                          ),

                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[

                    IconButton(
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white,size:40),
                      onPressed: previousSong,
                    ),

                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size:40,
                      ),
                      onPressed: (){
                        if(isPlaying){
                          player.pause();
                        }else{
                          player.play();
                        }
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          color: Colors.white,size:40),
                      onPressed: nextSong,
                    ),

                  ],
                ),

                const SizedBox(height:30),

                FloatingActionButton(
  onPressed: isProcessingAI ? null : startVoiceCommand,
  child: isProcessingAI
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
      : const Icon(Icons.mic),
)

              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
void dispose() {
  rotationController.dispose();
  player.dispose();
  super.dispose();
}
}