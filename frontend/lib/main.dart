import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MelodyHubApp());

const String baseUrl = 'http://127.0.0.1:5000'; // Your backend URL

class MelodyHubApp extends StatelessWidget {
  const MelodyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MelodyHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4B0082),
        scaffoldBackgroundColor: const Color(0xFF120024),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ===================== WELCOME SCREEN =====================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120024),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png.jpeg", height: 150),
            const SizedBox(height: 30),
            const Text(
              'Welcome to MelodyHub',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AuthPage())),
              child: const Text("Get Started",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== LOGIN / REGISTER PAGE =====================
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> submit() async {
    final url = Uri.parse('$baseUrl/api/${isLogin ? 'login' : 'register'}');
    final body = jsonEncode({
      'username': username.text,
      if (!isLogin) 'email': email.text,
      'password': password.text,
    });

    try {
      final res = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final userId = data['user']?['_id'] ?? '';
        if (userId.isEmpty) {
          throw Exception("Invalid user data from server");
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SongsPage(userId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Error occurred'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/song.jpg", fit: BoxFit.cover),
          Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isLogin ? "Login" : "Register",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: username,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white38)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (!isLogin)
                    TextField(
                      controller: email,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.white38)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                      ),
                    ),
                  if (!isLogin) const SizedBox(height: 15),
                  TextField(
                    controller: password,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white38)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isLogin ? "Login" : "Register",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== SONGS PAGE =====================
class SongsPage extends StatefulWidget {
  final String userId;
  const SongsPage({super.key, required this.userId});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final AudioPlayer player = AudioPlayer();
  List<String> songs = [];
  int currentIndex = -1;
  bool isPlaying = false;
  bool loading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    final res = await http.get(Uri.parse('$baseUrl/api/songs'));
    if (res.statusCode == 200) {
      setState(() {
        songs = List<String>.from(jsonDecode(res.body));
        loading = false;
      });
    }
  }

  Future<void> playSong(int index) async {
    await player.play(UrlSource('$baseUrl/uploads/${songs[index]}'));
    setState(() {
      currentIndex = index;
      isPlaying = true;
    });
  }

  Future<void> pause() async {
    await player.pause();
    setState(() => isPlaying = false);
  }

  Future<void> next() async {
    int nextIndex = (currentIndex + 1) % songs.length;
    playSong(nextIndex);
  }

  Future<void> previous() async {
    int prev = (currentIndex - 1 + songs.length) % songs.length;
    playSong(prev);
  }

  Future<void> deleteSong(String song) async {
    await http.delete(Uri.parse('$baseUrl/api/songs/$song'));
    fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B0082),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B0082),
        title: const Text("MelodyHub", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) => setState(() => query = val),
                    decoration: InputDecoration(
                      hintText: "Search songs...",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: songs
                        .where((s) =>
                            s.toLowerCase().contains(query.toLowerCase()))
                        .map((song) => Card(
                              color: songs.indexOf(song) == currentIndex
                                  ? Colors.deepPurpleAccent
                                  : Colors.white10,
                              child: ListTile(
                                leading: const Icon(Icons.music_note,
                                    color: Colors.white),
                                title: Text(song,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () => deleteSong(song)),
                                    IconButton(
                                      icon: Icon(
                                        songs.indexOf(song) == currentIndex &&
                                                isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (songs.indexOf(song) ==
                                                currentIndex &&
                                            isPlaying) {
                                          pause();
                                        } else {
                                          playSong(songs.indexOf(song));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                if (currentIndex != -1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white),
                          onPressed: previous),
                      IconButton(
                          icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: Colors.white,
                              size: 40),
                          onPressed:
                              isPlaying ? pause : () => playSong(currentIndex)),
                      IconButton(
                          icon:
                              const Icon(Icons.skip_next, color: Colors.white),
                          onPressed: next),
                    ],
                  ),
                const SizedBox(height: 60),
              ],
            ),
    );
  }
}
