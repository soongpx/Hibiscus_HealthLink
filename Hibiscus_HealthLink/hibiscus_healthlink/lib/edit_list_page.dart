import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditListPage extends StatefulWidget {
  final String fieldName; // Name of the field being edited
  final List<String> fieldValues; // Current list of values

  const EditListPage({
    super.key,
    required this.fieldName,
    required this.fieldValues,
  });

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  late List<String> values; // Local copy of the field values
  final TextEditingController _controller = TextEditingController(); // Controller for the input field
  String? _errorMessage; // Error message for validation

  @override
  void initState() {
    super.initState();
    values = List.from(widget.fieldValues); // Create a copy of the initial values
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.fieldName}'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // List of current values or "No entries" placeholder
            Expanded(
              child: values.isEmpty
                  ? Center(
                      child: Text(
                        'No ${widget.fieldName} added.',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: values.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(values[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                values.removeAt(index); // Remove the item
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 16.h),

            // Input field to add new values
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add New ${widget.fieldName}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                errorText: _errorMessage,
              ),
            ),
            SizedBox(height: 8.h),

            // Button to add the new value
            ElevatedButton(
              onPressed: _addValue,
              child: const Text('Add'),
            ),
            SizedBox(height: 16.h),

            // Save changes button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, values); // Return the updated list
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to add a new value
  void _addValue() {
    final newValue = _controller.text.trim();

    if (newValue.isEmpty) {
      setState(() {
        _errorMessage = 'Value cannot be empty.';
      });
    } else if (values.contains(newValue)) {
      setState(() {
        _errorMessage = 'Duplicate entry not allowed.';
      });
    } else {
      setState(() {
        values.add(newValue); // Add the new value
        _controller.clear(); // Clear the input field
        _errorMessage = null; // Clear error message
      });
    }
  }
}
