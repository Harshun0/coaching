import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'video_player_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const LessonListScreen({super.key, required this.courseId, required this.courseTitle});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final _api = ApiClient();
  late Future<List<dynamic>> _lessons;

  @override
  void initState() {
    super.initState();
    _lessons = _api.fetchLessons(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseTitle)),
      body: FutureBuilder<List<dynamic>>(
        future: _lessons,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final lessons = snapshot.data ?? [];
          if (lessons.isEmpty) {
            return const Center(child: Text('No lessons yet'));
          }
          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              return ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(lesson['title']),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                      lessonId: lesson['id'],
                      lessonTitle: lesson['title'],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
