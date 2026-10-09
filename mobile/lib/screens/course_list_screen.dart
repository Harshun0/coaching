import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'course_detail_screen.dart';
import 'lesson_list_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _api = ApiClient();
  late Future<List<dynamic>> _courses;

  @override
  void initState() {
    super.initState();
    _courses = _api.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: FutureBuilder<List<dynamic>>(
        future: _courses,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final courses = snapshot.data ?? [];
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, i) {
              final course = courses[i];
              final enrolled = course['enrolled'] == true;
              return ListTile(
                title: Text(course['title']),
                subtitle: Text(course['description']),
                trailing: enrolled
                    ? const Text('Enrolled', style: TextStyle(color: Colors.green))
                    : Text('₹${(course['priceInPaise'] / 100).toStringAsFixed(0)}'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => enrolled
                        ? LessonListScreen(courseId: course['id'], courseTitle: course['title'])
                        : CourseDetailScreen(course: course),
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
