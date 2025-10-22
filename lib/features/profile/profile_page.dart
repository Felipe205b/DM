import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:typed_data';
import '../../services/shared_preferences_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  XFile? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SharedPreferencesService.getUserName();
    final email = await SharedPreferencesService.getUserEmail();
    if (kIsWeb) {
      final base64 = await SharedPreferencesService.getProfileImageBase64();
      if (base64 != null) {
        setState(() {
          _imageBytes = base64Decode(base64);
        });
      }
    } else {
      final imagePath = await SharedPreferencesService.getProfileImagePath();
      if (imagePath != null) {
        setState(() {
          _imageFile = XFile(imagePath);
        });
      }
    }

    setState(() {
      _nameController.text = name ?? '';
      _emailController.text = email ?? '';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        if (kIsWeb) {
          _imageBytes = bytes;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    await SharedPreferencesService.setUserName(_nameController.text);
    await SharedPreferencesService.setUserEmail(_emailController.text);
    if (_imageFile != null) {
      if (kIsWeb) {
        final bytes = await _imageFile!.readAsBytes();
        final base64 = base64Encode(bytes);
        await SharedPreferencesService.setProfileImageBase64(base64);
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_imageFile!.path);
        final savedImage = await File(_imageFile!.path).copy('${appDir.path}/$fileName');
        await SharedPreferencesService.setProfileImagePath(savedImage.path);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo com sucesso!')),
    );
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
            GestureDetector(
              onTap: () {
                _showImagePickerOptions();
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: kIsWeb
                    ? (_imageBytes != null ? MemoryImage(_imageBytes!) : null)
                    : (_imageFile != null ? FileImage(File(_imageFile!.path)) : null),
                child: (_imageFile == null && _imageBytes == null)
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
