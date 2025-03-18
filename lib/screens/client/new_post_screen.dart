import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
// import 'package:depanini/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;

final _auth = FirebaseAuth.instance;

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final List<String> _domains = [
    'Plomberie',
    'Électricité',
    'Mécanique',
    'Informatique',
    'Jardinage',
  ];

  String? _selectedDomain;
  var _enteredDescription = '';
  var _enteredDomaine = '';
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  final _formKey = GlobalKey<FormState>();
  void _savePost() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      // ***********HTTP Request**************
      final url = Uri.http('10.0.2.2:3000', 'api/data');
      http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': _auth.currentUser!.uid,
          'description': _enteredDescription,
          'service': _enteredDomaine,
          'date':
              _selectedDate == null
                  ? 'Aucune date sélectionnée'
                  : formatter.format(_selectedDate!),
          // 'image1': _pickImageFile_1,
          // 'image2': _pickImageFile_2,
          // 'image3': _pickImageFile_3,
          // 'image4': _pickImageFile_4,
        }),
      );
      // *************************************
      // Navigator.of(context).pop();
    }
  }

  DateTime? _selectedDate;
  final formatter = DateFormat.yMd();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une annonce')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 150,
                    decoration: InputDecoration(
                      label: Text('Description'),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 5 ||
                          value.trim().length > 150) {
                        return 'Veuillez entrer votre description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredDescription = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.domain_outlined),
                      labelText: 'Service',
                    ),
                    value: _selectedDomain,
                    items:
                        _domains.map((domain) {
                          return DropdownMenuItem(
                            value: domain,
                            child: Text(domain),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDomain = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner un service';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredDomaine = newValue!;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? ''
                            : formatter.format(_selectedDate!),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Row(
                        children: [
                          Text(
                            'Sélectionnez une date',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          IconButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final lastDate = DateTime(
                                now.year + 1,
                                now.month,
                                now.day,
                              );
                              final pickedDate = await showDatePicker(
                                context: context,
                                firstDate: now,
                                lastDate: lastDate,
                              );
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            },
                            icon: Icon(
                              Icons.calendar_month_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ajouter des photos',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 10),
                  // ***********Images***********************
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            final pickedImage = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50,
                              maxWidth: 150,
                            );
                            if (pickedImage == null) {
                              return;
                            }
                            setState(() {
                              _pickImageFile_1 = File(pickedImage.path);
                            });
                          },
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                              image:
                                  _pickImageFile_1 != null
                                      ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_pickImageFile_1!),
                                      )
                                      : null,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_pickImageFile_1 == null)
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 7),
                        InkWell(
                          onTap: () async {
                            final pickedImage = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50,
                              maxWidth: 150,
                            );
                            if (pickedImage == null) {
                              return;
                            }
                            setState(() {
                              _pickImageFile_2 = File(pickedImage.path);
                            });
                          },
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                              image:
                                  _pickImageFile_2 != null
                                      ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_pickImageFile_2!),
                                      )
                                      : null,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_pickImageFile_2 == null)
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 7),
                        InkWell(
                          onTap: () async {
                            final pickedImage = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50,
                              maxWidth: 150,
                            );
                            if (pickedImage == null) {
                              return;
                            }
                            setState(() {
                              _pickImageFile_3 = File(pickedImage.path);
                            });
                          },
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                              image:
                                  _pickImageFile_3 != null
                                      ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_pickImageFile_3!),
                                      )
                                      : null,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_pickImageFile_3 == null)
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 7),
                        InkWell(
                          onTap: () async {
                            final pickedImage = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50,
                              maxWidth: 150,
                            );
                            if (pickedImage == null) {
                              return;
                            }
                            setState(() {
                              _pickImageFile_4 = File(pickedImage.path);
                            });
                          },
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                              image:
                                  _pickImageFile_4 != null
                                      ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_pickImageFile_4!),
                                      )
                                      : null,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_pickImageFile_4 == null)
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _savePost, child: Text('Ajouter')),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
