import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'doctor_chat_list_page.dart';
import 'doctor_schedule_page.dart';
import 'doctor_profile_page.dart';
import 'doctor_patient_management_page.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith('/doctor/chat')) {
      return const DoctorChatListPage();
    } else if (location.startsWith('/doctor/schedule')) {
      return const DoctorSchedulePage();
    } else if (location.startsWith('/doctor/patients')) {
      return const DoctorPatientManagementPage();
    } else if (location.startsWith('/doctor/profile')) {
      return const DoctorProfilePage();
    }

    // Default to chat
    return const DoctorChatListPage();
  }
}
