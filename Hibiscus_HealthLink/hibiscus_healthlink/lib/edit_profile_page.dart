import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfilePage extends StatelessWidget {
  final String fieldName;
  final String fieldValue;
  final bool isMultiLine;

  const EditProfilePage({
    super.key,
    required this.fieldName,
    required this.fieldValue,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: fieldValue);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $fieldName'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: isMultiLine ? 5 : 1,
              decoration: InputDecoration(
                labelText: fieldName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text); // Pass updated value back
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
