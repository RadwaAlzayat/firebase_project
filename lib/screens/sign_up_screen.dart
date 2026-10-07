import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_mini_project/screens/user_form.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();

  // Free the controllers when the screen is closed
  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sign_up".tr()),
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
                    decoration: InputDecoration(label: Text("full_name".tr())),
                    controller: fullNameController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Check that the first letter is capitalized
                        if (value[0] == value[0].toUpperCase()) {
                          return null;
                        } else {
                          return "first_letter_capital".tr();
                        }
                      } else {
                        return "please_enter_full_name".tr();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    decoration: InputDecoration(label: Text("email".tr())),
                    controller: emailController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Check that the email contains the @ symbol
                        if (value.contains('@')) {
                          return null;
                        } else {
                          return "email_must_contain_at".tr();
                        }
                      } else {
                        return "please_enter_email".tr();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    obscureText: _hidePassword, // hide the password
                    decoration: InputDecoration(
                      label: Text("password".tr()),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    controller: passwordController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Check that the password has at least 6 characters
                        if (value.length >= 6) {
                          return null;
                        } else {
                          return "password_min_length".tr();
                        }
                      } else {
                        return "please_enter_password".tr();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    obscureText: _hideConfirmPassword, // hide the password
                    decoration: InputDecoration(
                      label: Text("confirm_password".tr()),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hideConfirmPassword = !_hideConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _hideConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Check that both passwords are identical
                        if (value == passwordController.text) {
                          return null;
                        } else {
                          return "passwords_not_match".tr();
                        }
                      } else {
                        return "please_confirm_password".tr();
                      }
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: () async {
                      // Validate the form before navigating
                      if (_formKey.currentState!.validate()) {
                        try {
                          final credential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                          await _showMyDialog();
                          Navigator.push(context, _createRoute());
                        } on FirebaseAuthException catch (e) {
                          String message;
                          if (e.code == 'weak-password') {
                            message = 'weak-password'.tr();
                          } else if (e.code == 'email-already-in-use') {
                            message = 'email-already-in-use'.tr();
                          } else if (e.code == 'invalid-email') {
                            message = 'invalid-email'.tr();
                          } else {
                            message = e.message ?? 'something_went_wrong'.tr();
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: Text("sign_up".tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("account_created".tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ok'.tr()),
            ),
          ],
        );
      },
    );
  }

  Route<void> _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const UserFormScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Apply a fade animation when opening the Shopping Screen
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
