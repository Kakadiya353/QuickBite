import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfileScreen({required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GetStorage box = GetStorage();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.userData['name'] ?? '';
    emailController.text = widget.userData['email'] ?? '';
    phoneController.text = widget.userData['number']?.toString() ?? '';
  }

  void saveProfile() {
    Map<String, dynamic> updatedUser = {
      'name': nameController.text,
      'email': emailController.text,
      'number': phoneController.text,
    };

    box.write('loginUser', updatedUser);
    Get.back(result: updatedUser); // Return updated data to Profile Screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Curved Background
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 4.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                          MediaQuery.of(context).size.width, 105.0),
                    ),
                  ),
                ),
                // Profile Icon
                Center(
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 6.5),
                    child: Material(
                      elevation: 10.0,
                      borderRadius: BorderRadius.circular(60),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Icon(
                          Icons.person,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Edit Profile Title
                Padding(
                  padding: EdgeInsets.only(top: 70.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),

            // Editable Fields Styled like Profile Tiles
            ProfileEditTile(
              readOnly: false,
              icon: Icons.person,
              title: "Name",
              controller: nameController,
            ),
            ProfileEditTile(
              readOnly: true, // Disable editing
              icon: Icons.email,
              title: "Email",
              controller: emailController,
            ),
            ProfileEditTile(
              readOnly: true,
              // Disable editing
              icon: Icons.phone,
              title: "Phone",
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 20),
            // Save Button
            ElevatedButton.icon(
              onPressed: saveProfile,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Profile Edit Tile for Inputs (Matches ProfileTile)
class ProfileEditTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool readOnly;

  ProfileEditTile({
    required this.icon,
    required this.title,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false, // Default is editable
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              SizedBox(width: 20.0),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  // Make it uneditable if needed
                  style: TextStyle(
                    fontSize: 16.0,
                    color: readOnly
                        ? Colors.grey
                        : Colors.black, // Grey if disabled
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: title,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
