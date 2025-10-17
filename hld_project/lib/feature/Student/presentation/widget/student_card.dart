import 'package:flutter/material.dart';
import '../../domain/entities/student.dart';

/// ✅ Widget hiển thị thông tin một sinh viên
class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const StudentCard({
    super.key,
    required this.student,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Ten : ${student.name}\nLớp: ${student.className}"),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
