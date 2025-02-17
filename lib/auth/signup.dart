import 'dart:developer';
import 'dart:io';

import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_services.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/custom_widgets/custom_text_feild.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import '../custom_widgets/custom_buttons.dart';
import '../model/user_profile.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  late NavigationServices _navigationServices;
  late AuthServices _authServices;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationServices = _getIt.get<NavigationServices>();
    _authServices = _getIt.get<AuthServices>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Let's get going!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Register an account to get started",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  File? file = await _mediaService.getImageFromGalary();
                  if (file != null) {
                    setState(() {
                      selectedImage = file;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : const NetworkImage(
                          'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                ),
              ),
              const SizedBox(height: 30),
              _signUpForm(),
              const SizedBox(height: 30),
              isLoading == false
                  ? CustomButton(
                      buttonText: 'Register',
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          if ((_formKey.currentState?.validate() ?? false) &&
                              selectedImage != null) {
                            _formKey.currentState?.save();
                            bool result = await _authServices.signUp(
                              emailController.text,
                              passwordController.text,
                            );
                            if (result) {
                              String? imageUrl =
                                  await _storageService.uploadUserPfp(
                                file: selectedImage!,
                                uid: _authServices.user!.uid,
                              );
                              if (imageUrl != null) {
                                await _databaseService.createUserProfile(
                                  userProfile: UserProfile(
                                    uid: _authServices.user!.uid,
                                    name: nameController.text,
                                    pfpUrl: imageUrl,
                                  ),
                                );
                                Fluttertoast.showToast(
                                  msg: 'User Registered Successfully',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                _navigationServices.goBack();
                                _navigationServices
                                    .pushReplacementNamed('/home');
                              } else {
                                throw Exception('Failed to upload image');
                              }
                            } else {
                              throw Exception('Failed to register user');
                            }
                          }
                        } catch (e) {
                          log(e.toString());
                          Fluttertoast.showToast(
                            msg: e.toString(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          _navigationServices.goBack();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          color: Colors.white,
          child: Center(
            child: RichText(
              text: const TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Log In',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 20,
        children: [
          CustomTextFeild(
            text: 'Name',
            controller: nameController,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
            onSaved: (value) {
              log(value.toString());
            },
          ),
          CustomTextFeild(
            text: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (EmailValidator.validate(value) == false) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onSaved: (value) {
              log(value.toString());
            },
          ),
          CustomTextFeild(
            text: 'Password',
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onSaved: (value) {
              log(value.toString());
            },
          ),
        ],
      ),
    );
  }
}
