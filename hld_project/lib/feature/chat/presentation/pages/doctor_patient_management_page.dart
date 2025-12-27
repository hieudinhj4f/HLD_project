import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
import 'doctor_chat_list_page.dart';

class DoctorPatientManagementPage extends StatefulWidget {
  const DoctorPatientManagementPage({super.key});

  @override
  State<DoctorPatientManagementPage> createState() => _DoctorPatientManagementPageState();
}

class _DoctorPatientManagementPageState extends State<DoctorPatientManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final doctorId = authProvider.userId;

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
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients by name, phone, email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Patient list
          Expanded(
            child: doctorId == null
                ? const Center(child: Text('Please log in'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: doctorId)
                        .snapshots(),
                    builder: (context, appointmentsSnapshot) {
                      if (appointmentsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!appointmentsSnapshot.hasData) {
                        return const Center(child: Text('No data'));
                      }

                      // Get unique patient IDs from appointments
                      final appointments = appointmentsSnapshot.data!.docs;
                      final patientIds = <String>{};
                      final patientAppointmentData = <String, Map<String, dynamic>>{};

                      for (var apt in appointments) {
                        final data = apt.data() as Map<String, dynamic>;
                        final patientId = data['patientId'] as String?;
                        final email = data['email'] as String?;
                        
                        if (patientId != null) {
                          patientIds.add(patientId);
                          patientAppointmentData[patientId] = data;
                        } else if (email != null) {
                          // If no patientId, use email as identifier
                          patientIds.add(email);
                          patientAppointmentData[email] = data;
                        }
                      }

                      if (patientIds.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No patients yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: patientIds.length,
                        itemBuilder: (context, index) {
                          final patientIdentifier = patientIds.elementAt(index);
                          final appointmentData = patientAppointmentData[patientIdentifier]!;
                          
                          // Check if it's an email or patientId
                          final isEmail = patientIdentifier.contains('@');
                          
                          if (isEmail) {
                            // Display from appointment data
                            return _buildPatientCardFromAppointment(appointmentData);
                          } else {
                            // Fetch patient data from users collection
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(patientIdentifier)
                                  .get(),
                              builder: (context, patientSnapshot) {
                                if (!patientSnapshot.hasData || !patientSnapshot.data!.exists) {
                                  return _buildPatientCardFromAppointment(appointmentData);
                                }

                                final patientData = patientSnapshot.data!.data() as Map<String, dynamic>;
                                
                                // Apply search filter
                                final name = patientData['name'] ?? '';
                                final phone = patientData['phone'] ?? '';
                                final email = patientData['email'] ?? '';
                                
                                if (_searchQuery.isNotEmpty) {
                                  if (!name.toLowerCase().contains(_searchQuery) &&
                                      !phone.contains(_searchQuery) &&
                                      !email.toLowerCase().contains(_searchQuery)) {
                                    return const SizedBox.shrink();
                                  }
                                }

                                return _buildPatientCard(patientData, appointmentData, patientIdentifier);
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(
    Map<String, dynamic> patientData,
    Map<String, dynamic> appointmentData,
    String patientId,
  ) {
    final name = patientData['name'] ?? 'Unknown';
    final phone = patientData['phone'] ?? '';
    final email = patientData['email'] ?? '';
    final dob = patientData['dob'] ?? '';
    final gender = patientData['gender'] ?? '';
    final avatarUrl = patientData['avatarUrl'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPatientDetails(context, patientData, patientId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(phone, style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ],
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (dob.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'DOB: $dob | $gender',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorPatientChatPage(
                        patientId: patientId,
                        patientName: name,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCardFromAppointment(Map<String, dynamic> appointmentData) {
    final firstName = appointmentData['firstName'] ?? '';
    final lastName = appointmentData['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();
    final phone = appointmentData['phone'] ?? '';
    final email = appointmentData['email'] ?? '';

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      if (!name.toLowerCase().contains(_searchQuery) &&
          !phone.contains(_searchQuery) &&
          !email.toLowerCase().contains(_searchQuery)) {
        return const SizedBox.shrink();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Unknown Patient',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(phone, style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ],
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientDetails(
    BuildContext context,
    Map<String, dynamic> patientData,
    String patientId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PatientDetailsSheet(
        patientData: patientData,
        patientId: patientId,
      ),
    );
  }
}

class PatientDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final String patientId;

  const PatientDetailsSheet({
    super.key,
    required this.patientData,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final name = patientData['name'] ?? 'Unknown';
    final phone = patientData['phone'] ?? '';
    final email = patientData['email'] ?? '';
    final dob = patientData['dob'] ?? '';
    final gender = patientData['gender'] ?? '';
    final address = patientData['address'] ?? '';
    final avatarUrl = patientData['avatarUrl'] ?? '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (email.isNotEmpty)
                      Text(email, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(Icons.phone, 'Phone', phone),
          _buildDetailRow(Icons.calendar_today, 'Date of Birth', dob),
          _buildDetailRow(Icons.person, 'Gender', gender),
          if (address.isNotEmpty) _buildDetailRow(Icons.location_on, 'Address', address),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorPatientChatPage(
                          patientId: patientId,
                          patientName: name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }
}

