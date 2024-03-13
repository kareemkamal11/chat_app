// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:chat_app/widgets/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isShow = false;
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String _userEmail = '';
  String _userPassword = '';
  File? selectedImage;
  var isUpLoading = false;

  void trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid || (selectedImage == null && !isLogin)) {
      return;
    }
    _formKey.currentState!.save();
    if (isLogin) {
      try {
        if (mounted) {
          isUpLoading = true;
        }
        await auth.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const ChatScreen(),
        ),
      );
    } else {
      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _userEmail,
          'image_url': imageUrl,
          'username': username,
        });
      } on FirebaseAuthException catch (e) {
        log(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() {
            isUpLoading = false;
          });
        }
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const ChatScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                width: 200,
                child: Image.asset('assets/image/chat.png'),
              ),
              Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isLogin)
                              Column(
                                children: [
                                  UsreImagePicker(
                                    onImagePick: (imageFile) {
                                      selectedImage = imageFile;
                                    },
                                  ),
                                  // textformfield for username
                                  TextFormField(
                                    key: const ValueKey('username'),
                                    onSaved: (value) => username = value!,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().length < 6) {
                                        return 'Please enter a username, at least 6 characters long';
                                      }
                                      return null;
                                    }, // يتحقق من القيمة المدخلة
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                ],
                              ),
                            TextFormField(
                              key: const ValueKey('email'),
                              onSaved: (value) => _userEmail = value!,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                            ),
                            TextFormField(
                              key: const ValueKey('password'),
                              onSaved: (value) => _userPassword = value!,
                              validator: (value) {
                                if (value == null || value.length < 7) {
                                  return 'Password must be at least 7 characters long';
                                }
                                return null;
                              },
                              obscureText: isShow,
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isShow = !isShow;
                                      });
                                    },
                                    icon: Icon(isShow
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  )),
                            ),
                            const SizedBox(height: 12),
                            if (isUpLoading) const CircularProgressIndicator(),
                            if (!isUpLoading)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                onPressed: trySubmit,
                                child: Text(isLogin ? 'Login' : 'Signup'),
                              ),
                            if (!isUpLoading)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                },
                                child: Text(isLogin
                                    ? 'Create new account'
                                    : 'I already have an account'),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
