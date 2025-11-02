import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/doctor.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;
  const DoctorDetailPage({super.key, required this.doctor});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  bool _isWorkTab = true;

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/user/chat'); // Quay về Chat nếu không có stack
            }
          },
        ),
        title: const Text(
          'HLD',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD BÁC SĨ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      doctor.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Type: ${doctor.type}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          'Organ organizer',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          'Experienced: ${doctor.experienceYears} years',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TAB WORK / ACTIVITY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTab('WORK', true),
                  _buildTab('ACTIVITY', false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // GRID 4 Ô
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: _isWorkTab
                  ? [
                      _buildStat(
                        'Số ca khám',
                        '${doctor.totalExaminations} ca',
                      ),
                      _buildStat(
                        'Tỉ lệ chính xác',
                        '${doctor.accurateRate.toStringAsFixed(0)}%',
                      ),
                      _buildStat(
                        'Đánh giá',
                        '${doctor.averageRating.toStringAsFixed(1)} sao',
                      ),
                      _buildStat('Số phản hồi', '${doctor.totalReviews}'),
                    ]
                  : [
                      _buildStat('Tư vấn', '${doctor.totalConsultations}'),
                      _buildStat('Giờ online', '${doctor.onlineHours}h'),
                      _buildStat(
                        'Tỉ lệ phản hồi',
                        '${doctor.responseRate.toStringAsFixed(0)}%',
                      ),
                      _buildStat('Ngày hoạt động', '${doctor.activeDays}'),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isWork) {
    final selected = _isWorkTab == isWork;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isWorkTab = isWork),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.green : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
