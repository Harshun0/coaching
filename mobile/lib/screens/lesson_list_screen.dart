import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../theme.dart';
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
            return Center(
              child: Text('No lessons yet', style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                      lessonId: lesson['id'],
                      lessonTitle: lesson['title'],
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${lesson['order']}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(lesson['title'], style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 30),
                    ],
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
