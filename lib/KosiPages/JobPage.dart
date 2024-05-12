import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Utils/AppColors.dart';



import 'package:flutter/material.dart';

class JobPage extends StatefulWidget {


  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController skillController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  void _submitJobApplication() {
    String name = nameController.text;
    String skill = skillController.text;
    String phone = phoneController.text;
    String city = cityController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor, // Change to your desired color
        title: Text('Job Application'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:InputDecoration(labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()),
              ),

            SizedBox(height: 20),
            TextField(
              controller: skillController,
              decoration: InputDecoration(labelText: 'Skill',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                _pushRealtimeDB();
              },
                child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
  void _pushRealtimeDB() async {
    try {
      final name = nameController.text;
      final phone = phoneController.text;
      final city = cityController.text;
      final skill = skillController.text;

      if (name.isEmpty || phone.isEmpty || city.isEmpty || skill.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      final DatabaseReference jobrequestRef =
      FirebaseDatabase.instance.reference().child('FirstClick').child('Admin').child('Jobrequest');

      final newJobRequestRef = jobrequestRef.push();
      await newJobRequestRef.set({
        'name': name,
        'phone': phone,
        'city': city,
        'skill': skill,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job request submitted successfully')),
      );

      // Clear text controllers after submission
      nameController.clear();
      phoneController.clear();
      cityController.clear();
      skillController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding user data to Realtime Database: $e')),
      );
    }
  }



}

