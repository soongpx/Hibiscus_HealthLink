import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'edit_profile_page.dart';
import 'edit_list_page.dart';
import 'sign_in_page.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Non-editable fields
  final String nationalID = "12110-05-9101";
  final String userName = "Peng Xiang";
  final String dob = "10 October 2012";
  final String gender = "Male";
  final String bloodType = "O+";

  // Editable fields
  String emergencyContact = "+60123456789";
  String address = "123, Jalan Tengah, Kuala Lumpur, Malaysia";
  String preferredHospital = "Universiti Malaya Medical Centre";

  // Editable list fields
  List<String> medicalConditions = ["Hypertension"];
  List<String> allergies = [];

  // List of hospitals for dropdown
  final List<String> hospitals = [
    "Universiti Malaya Medical Centre",
    "KMI Taman Desa Community Clinic",
    "Kuala Lumpur Hospital",
    "KPJ Sentosa KL Specialist Hospital"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 246, 254),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundImage: const AssetImage('assets/user_avatar.jpg'),
                ),
              ),
              SizedBox(height: 16.h),

              // Non-Editable Information Section
              Text(
                'Personal Information',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              _buildInfoTile('National ID', nationalID, Icons.perm_identity),
              _buildInfoTile('Name', userName, Icons.person),
              _buildInfoTile('Date of Birth', dob, Icons.cake),
              _buildInfoTile('Gender', gender, Icons.male),
              _buildInfoTile('Blood Type', bloodType, Icons.bloodtype),
              SizedBox(height: 24.h),

              // Editable Healthcare Information Section
              Text(
                'Healthcare Information',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              _buildListTile(
                'Medical Conditions',
                medicalConditions,
                Icons.local_hospital,
                (updatedList) {
                  setState(() {
                    medicalConditions = updatedList; // Update the list dynamically
                  });
                },
              ),
              _buildListTile(
                'Allergies',
                allergies,
                Icons.warning,
                (updatedList) {
                  setState(() {
                    allergies = updatedList; // Update the list dynamically
                  });
                },
              ),
              _buildEditableField(
                'Emergency Contact',
                emergencyContact,
                Icons.phone_in_talk,
                (newValue) {
                  setState(() {
                    emergencyContact = newValue;
                  });
                },
              ),
              _buildEditableField(
                'Address',
                address,
                Icons.location_on,
                (newValue) {
                  setState(() {
                    address = newValue;
                  });
                },
                isMultiLine: true,
              ),
              _buildDropdownField(
                'Preferred Hospital',
                preferredHospital,
                hospitals,
                (newValue) {
                  setState(() {
                    preferredHospital = newValue;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Logout Section
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _logout(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for non-editable tiles
  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(color: Colors.black)),
    );
  }

  // Helper widget for editable list tiles (Medical Conditions & Allergies)
  Widget _buildListTile(
    String label,
    List<String> values,
    IconData icon,
    Function(List<String>) onValueChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        values.isEmpty ? 'None' : values.join(', '), // Display "None" if empty
      ),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        final updatedList = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditListPage(
              fieldName: label,
              fieldValues: values, // Pass only actual entries
            ),
          ),
        );
        if (updatedList != null) {
          onValueChanged(updatedList);
        }
      },
    );
  }

  // Helper widget for editable single/multi-line fields
  Widget _buildEditableField(
    String label,
    String value,
    IconData icon,
    Function(String) onValueChanged, {
    bool isMultiLine = false,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfilePage(
              fieldName: label,
              fieldValue: value,
              isMultiLine: isMultiLine,
            ),
          ),
        );
        if (result != null) {
          onValueChanged(result);
        }
      },
    );
  }

  // Helper widget for dropdown fields
  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    Function(String) onValueChanged,
  ) {
    return ListTile(
      leading: const Icon(Icons.local_hospital),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text('Select $label'),
              children: options.map((option) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, option);
                  },
                  child: Text(option),
                );
              }).toList(),
            );
          },
        );
        if (result != null) {
          onValueChanged(result);
        }
      },
    );
  }
}

void _logout(BuildContext context) {
  // You can add any logout logic here, such as clearing user sessions or tokens.
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const SignInPage()),
    (route) => false, // This clears all previous routes.
  );
}
