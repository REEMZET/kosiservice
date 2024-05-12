import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddressInputDialog extends StatefulWidget {
  @override
  _AddressInputDialogState createState() => _AddressInputDialogState();
}

class _AddressInputDialogState extends State<AddressInputDialog> {
  TextEditingController _addressController = TextEditingController();
  String? phoneNumber;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;


  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    String address = _addressController.text;
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child(
        'FirstClick/User/$phoneNumber'+'/add');
    userRef.set(address).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Address updated"))));
    Navigator.pop(context);
  }
  @override
  void initState() {
    if(_auth.currentUser!=null){
      phoneNumber= user?.phoneNumber.toString().substring(3,13);
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Address'),
      content: TextField(
        controller: _addressController,
        decoration: InputDecoration(labelText: 'Address'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAddress,
          child: Text('Save'),
        ),
      ],
    );
  }
}
