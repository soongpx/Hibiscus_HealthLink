import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        "icon": "bell",
        "title": "Medical Check-Up Reminder",
        "description": "Your next medical check-up is scheduled for tomorrow at 10:00 AM.",
        "timestamp": "5 min ago"
      },
      {
        "icon": "heart",
        "title": "Heart Rate Alert",
        "description": "Your heart rate spiked to 120 bpm. Stay hydrated and rest.",
        "timestamp": "2 hours ago"
      },
      {
        "icon": "calendar",
        "title": "Prescription Renewal",
        "description": "Renew your prescription for Diabetes Medication before 12/05.",
        "timestamp": "Yesterday"
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 246, 254),
      appBar: AppBar(
        title: Text(
          'Notifications',
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
      body: Container( // Light grey background
        child: notifications.isEmpty
            ? Center(
                child: Text(
                  "No new notifications",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(
                    icon: notification["icon"]!,
                    title: notification["title"]!,
                    description: notification["description"]!,
                    timestamp: notification["timestamp"]!,
                  );
                },
              ),
      ),
    );
  }

  // Notification Card Widget
  Widget _buildNotificationCard({
    required String icon,
    required String title,
    required String description,
    required String timestamp,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Notification Icon
          CircleAvatar(
            radius: 24.r,
            backgroundColor: const Color(0xFFEFEFEF),
            child: Icon(
              _getIcon(icon),
              color: Colors.blue,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          // Notification Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Map icon strings to actual icons
  IconData _getIcon(String icon) {
    switch (icon) {
      case "bell":
        return Icons.notifications;
      case "heart":
        return Icons.favorite;
      case "calendar":
        return Icons.calendar_today;
      default:
        return Icons.info;
    }
  }
}
