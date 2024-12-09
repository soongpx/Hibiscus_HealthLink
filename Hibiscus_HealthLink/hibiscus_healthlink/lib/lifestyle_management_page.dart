import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LifestyleManagementPage extends StatelessWidget {
  const LifestyleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lifestyle Management',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏋️‍♀️ Manage Your Lifestyle',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF11698E),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Get personalized recommendations to improve your lifestyle.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),

            // Example Features
            _buildFeatureCard(
              title: 'Fitness Goals',
              description: 'Set and track your daily exercise routines.',
              icon: Icons.fitness_center,
            ),
            SizedBox(height: 16.h),
            _buildFeatureCard(
              title: 'Nutrition Plans',
              description: 'Personalized meal plans to match your health needs.',
              icon: Icons.restaurant,
            ),
            SizedBox(height: 16.h),
            _buildFeatureCard(
              title: 'Sleep Tracker',
              description: 'Monitor your sleep patterns and improve rest quality.',
              icon: Icons.bedtime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: const Color(0xFFE3F2FD),
            child: Icon(icon, color: const Color(0xFF11698E), size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
