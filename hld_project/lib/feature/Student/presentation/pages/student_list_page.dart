import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/student_provider.dart';
import '../widget/student_card.dart';
import '../widget/search_bar.dart';

/// ✅ Trang hiển thị danh sách sinh viên
class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<StudentProvider>(context, listen: false).fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh viên'),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            onChanged: provider.setSearchQuery,
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: provider.filteredStudents.length,
              itemBuilder: (context, index) {
                final student = provider.filteredStudents[index];
                return StudentCard(
                  student: student,
                  onDelete: () =>
                      provider.deleteStudent(student.id.toString()), onEdit: () {  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Chuyển sang màn thêm sinh viên
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
