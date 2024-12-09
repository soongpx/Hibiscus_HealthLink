import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunitySupportPage extends StatelessWidget {
  const CommunitySupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Support',
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
              '👥 Connect with Your Community',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF11698E),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Join groups, participate in discussions, and find support from others.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),

            // Example Features
            _buildFeatureCard(
              title: 'Discussion Forums',
              description: 'Ask questions, share experiences, and engage with others.',
              icon: Icons.chat,
            ),
            SizedBox(height: 16.h),
            _buildFeatureCard(
              title: 'Group Chats',
              description: 'Join private chats with people who share your goals.',
              icon: Icons.group,
            ),
            SizedBox(height: 16.h),
            _buildFeatureCard(
              title: 'Event Invitations',
              description: 'Participate in wellness events, webinars, and meetups.',
              icon: Icons.event,
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
            backgroundColor: const Color(0xFFE8F5E9),
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
