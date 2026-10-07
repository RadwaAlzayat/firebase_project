import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_mini_project/screens/display_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final hobbyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  var db = FirebaseFirestore.instance;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    hobbyController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    // Stop here if any field is invalid (this runs all the validators)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // Add a new document with a generated id
      await db.collection("users").add({
        "name": nameController.text.trim(),
        "age": ageController.text.trim(), // save the age as a number
        "hobby": hobbyController.text.trim(),
      });
      if (!mounted) return;
      nameController.clear();
      ageController.clear();
      hobbyController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("data_saved".tr())));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("something_went_wrong".tr())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("user-form".tr()),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            onPressed: () {
              // Switch between English and Arabic
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('ar'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    decoration: InputDecoration(label: Text("name".tr())),
                    controller: nameController,
                    validator: (nameController) {
                      if (nameController == null ||
                          nameController.trim().isEmpty) {
                        return "please_enter_name".tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(label: Text("age".tr())),
                    controller: ageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "please_enter_age".tr();
                      }
                      // The age must be a positive number
                      final age = int.tryParse(value);
                      if (age == null || age <= 0) {
                        return "invalid_age".tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: Text("favourite_hobby".tr()),
                    ),
                    controller: hobbyController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please_enter_hobby".tr();
                      }
                      return null;
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: _saveUser,
                    child: Text("save".tr()),
                  ),
                ),
                // Second button: open the display page
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayUsersScreen(),
                        ),
                      );
                    },
                    child: Text("view_saved_data".tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
