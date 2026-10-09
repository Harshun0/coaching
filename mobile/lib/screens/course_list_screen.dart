import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/course_card.dart';
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

  Future<void> _refresh() async {
    setState(() => _courses = _api.fetchCourses());
    await _courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<dynamic>>(
            future: _courses,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text('${snapshot.error}')),
                  ],
                );
              }
              final courses = snapshot.data ?? [];
              final enrolledCourses = courses.where((c) => c['enrolled'] == true).toList();
              final exploreCourses = courses.where((c) => c['enrolled'] != true).toList();

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome 👋', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text('Your classes', style: Theme.of(context).textTheme.headlineSmall),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (enrolledCourses.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                      sliver: SliverToBoxAdapter(
                        child: Text('Continue learning', style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemCount: enrolledCourses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final course = enrolledCourses[i];
                          return CourseCard(
                            course: course,
                            index: i,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LessonListScreen(
                                  courseId: course['id'],
                                  courseTitle: course['title'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Text('Explore courses', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                  if (exploreCourses.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Text('No courses published yet', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList.separated(
                        itemCount: exploreCourses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final course = exploreCourses[i];
                          return CourseCard(
                            course: course,
                            index: i + 1,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
