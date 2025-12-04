import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/shared_preferences_services.dart';
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SharedPreferencesService.getUserName();
    final email = await SharedPreferencesService.getUserEmail();
    final imagePath = await SharedPreferencesService.getProfileImagePath();
    if (name != null) {
      _nameController.text = name;
    }
    if (email != null) {
      _emailController.text = email;
    }
    setState(() {
      _profileImagePath = imagePath;
    });
  }

  Future<void> _saveUser() async {
    await SharedPreferencesService.setUserName(_nameController.text);
    await SharedPreferencesService.setUserEmail(_emailController.text);
    if (_profileImagePath != null) {
      await SharedPreferencesService.setProfileImagePath(_profileImagePath!);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil salvo com sucesso!'),
      ),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImagePath = base64Encode(bytes);
        });
      } else {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImagePath != null
                      ? (kIsWeb
                          ? MemoryImage(base64Decode(_profileImagePath!))
                          : FileImage(File(_profileImagePath!))) as ImageProvider
                      : null,
                  child: _profileImagePath == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveUser,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
