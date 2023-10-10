import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore

class AddCustomer extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String phone = '';

  CollectionReference customers = FirebaseFirestore.instance
      .collection('customers'); // Firestore Collection Reference

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Customer"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) {
                  address = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  phone = value!;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Adding the new customer to Firestore
                    customers
                        .add({
                          'name': name,
                          'address': address,
                          'phone': phone,
                        })
                        .then((value) => print("Customer Added"))
                        .catchError(
                            (error) => print("Failed to add customer: $error"));

                    Navigator.pop(context);
                  }
                },
                child: Text('Add Customer'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
