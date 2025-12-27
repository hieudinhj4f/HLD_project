import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
import '../../data/models/doctor_model.dart';
import 'doctor_profile_edit_page.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'HLD',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            color: Colors.green,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorProfileEditPage(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Doctor profile not found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DoctorProfileEditPage(),
                              ),
                            );
                          },
                          child: const Text('Create Profile'),
                        ),
                      ],
                    ),
                  );
                }

                final doctor = DoctorModel.fromFirestore(snapshot.data!);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.green.withOpacity(0.1),
                                backgroundImage: doctor.imageUrl.isNotEmpty
                                    ? NetworkImage(doctor.imageUrl)
                                    : null,
                                child: doctor.imageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 60, color: Colors.green)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                doctor.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                doctor.specialty,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor.degree,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Statistics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Examinations',
                              doctor.totalExaminations.toString(),
                              Icons.medical_services,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Rating',
                              doctor.averageRating.toStringAsFixed(1),
                              Icons.star,
                              Colors.amber,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Consultations',
                              doctor.totalConsultations.toString(),
                              Icons.chat,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Experience',
                              '${doctor.experienceYears} yrs',
                              Icons.work,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Profile Details
                      Card(
                        child: Column(
                          children: [
                            _buildDetailTile(
                              Icons.badge,
                              'Type',
                              doctor.type,
                            ),
                            _buildDetailTile(
                              Icons.local_hospital,
                              'Specialty',
                              doctor.specialty,
                            ),
                            _buildDetailTile(
                              Icons.school,
                              'Degree',
                              doctor.degree,
                            ),
                            _buildDetailTile(
                              Icons.trending_up,
                              'Accurate Rate',
                              '${doctor.accurateRate.toStringAsFixed(1)}%',
                            ),
                            _buildDetailTile(
                              Icons.reviews,
                              'Total Reviews',
                              doctor.totalReviews.toString(),
                            ),
                            _buildDetailTile(
                              Icons.timer,
                              'Online Hours',
                              '${doctor.onlineHours} hours',
                            ),
                            _buildDetailTile(
                              Icons.speed,
                              'Response Rate',
                              '${doctor.responseRate.toStringAsFixed(1)}%',
                            ),
                            _buildDetailTile(
                              Icons.calendar_today,
                              'Active Days',
                              '${doctor.activeDays} days',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Account Info
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                final email = userData?['email'] ?? '';
                                final phone = userData?['phone'] ?? '';

                                return Column(
                                  children: [
                                    if (email.isNotEmpty)
                                      _buildDetailTile(Icons.email, 'Email', email),
                                    if (phone.isNotEmpty)
                                      _buildDetailTile(Icons.phone, 'Phone', phone),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && mounted) {
                              await fb_auth.FirebaseAuth.instance.signOut();
                              // Navigation will be handled by auth provider
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey[700]),
      ),
    );
  }
}

