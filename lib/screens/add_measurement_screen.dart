import 'dart:io'; // Doit être présent
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/image_service.dart';
import '../services/permission_service.dart'; // Doit être présent
import '../models/client.dart';
import '../models/measurement.dart';
import '../models/garment_type.dart';

class AddMeasurementScreen extends StatefulWidget {
  final Client client;

  const AddMeasurementScreen({Key? key, required this.client}) : super(key: key);

  @override
  _AddMeasurementScreenState createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  GarmentType? _selectedType;
  final Map<String, TextEditingController> _controllers = {};
  List<String> _fabricImagePaths = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers.clear();
    final dataService = Provider.of<DataService>(context, listen: false);
    if (dataService.garmentTypes.isNotEmpty) {
      _selectedType = dataService.garmentTypes.first;
      for (final field in _selectedType!.measurementFields) {
        _controllers[field] = TextEditingController();
      }
    }
  }

  void _updateMeasurementFields(GarmentType? type) {
    setState(() {
      _selectedType = type;
      _controllers.clear();
      if (type != null) {
        for (final field in type.measurementFields) {
          _controllers[field] = TextEditingController();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle mesure'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type de vêtement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<GarmentType>(
                      value: _selectedType,
                      items: dataService.garmentTypes.map((GarmentType type) {
                        return DropdownMenuItem<GarmentType>(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (GarmentType? newValue) {
                        _updateMeasurementFields(newValue);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Section photos du tissu
                    _buildFabricPhotosSection(),
                    SizedBox(height: 24),

                    if (_selectedType != null) ...[
                      Text(
                        'Mesures (en cm)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: _buildMeasurementFields(),
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFabricPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Photos du tissu/pagne',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '(${_fabricImagePaths.length}/2)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        _fabricImagePaths.isEmpty
            ? _buildPhotosPlaceholder()
            : _buildPhotosGrid(),
        SizedBox(height: 8),
        if (_fabricImagePaths.length < 2) _buildPhotoButtons(),
      ],
    );
  }

  Widget _buildPhotosPlaceholder() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera, size: 40, color: Colors.grey[600]),
          SizedBox(height: 8),
          Text(
            'Ajoutez jusqu\'à 2 photos du tissu',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            '(${_fabricImagePaths.length}/2 utilisées)',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: _fabricImagePaths.length + (_fabricImagePaths.length < 2 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _fabricImagePaths.length) {
          return _buildPhotoItem(_fabricImagePaths[index], index);
        } else {
          return _buildAddPhotoButton();
        }
      },
    );
  }

  Widget _buildPhotoItem(String imagePath, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.grey[400]),
                      SizedBox(height: 4),
                      Text(
                        'Image non disponible',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.white),
              onPressed: () => _removePhoto(index),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Photo ${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _showAddPhotoOptions,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[600]),
            SizedBox(height: 4),
            Text(
              'Ajouter\nphoto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _takePhotoFromCamera,
            icon: Icon(Icons.camera_alt),
            label: Text('Prendre photo'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickPhotoFromGallery,
            icon: Icon(Icons.photo_library),
            label: Text('Galerie'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveMeasurement,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Enregistrer la mesure',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMeasurementFields() {
    if (_selectedType == null) return [];

    return _selectedType!.measurementFields.map((field) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _controllers[field],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Entrez la mesure en cm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'cm',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                if (double.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showAddPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickPhotoFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhotoFromCamera() async {
    try {
      if (_fabricImagePaths.length >= 2) {
        _showErrorSnackBar('Maximum 2 photos autorisées');
        return;
      }

      final String? imagePath = await ImageService.pickImageFromCamera();
      if (imagePath != null) {
        setState(() {
          _fabricImagePaths.add(imagePath);
        });
      } else {
        _showPermissionErrorDialog('caméra');
      }
    } catch (e) {
      _showPermissionErrorDialog('caméra');
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      if (_fabricImagePaths.length >= 2) {
        _showErrorSnackBar('Maximum 2 photos autorisées');
        return;
      }

      final String? imagePath = await ImageService.pickImageFromGallery();
      if (imagePath != null) {
        setState(() {
          _fabricImagePaths.add(imagePath);
        });
      } else {
        _showPermissionErrorDialog('galerie');
      }
    } catch (e) {
      _showPermissionErrorDialog('galerie');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _fabricImagePaths.removeAt(index);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPermissionErrorDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission requise'),
        content: Text('L\'application a besoin d\'accéder à votre $type pour ajouter des photos de tissus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionService.openAppSettings();
            },
            child: Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _saveMeasurement() async {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        
        final valeurs = <String, double>{};
        for (final field in _selectedType!.measurementFields) {
          valeurs[field] = double.parse(_controllers[field]!.text);
        }

        final newMeasurement = Measurement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          clientId: widget.client.id,
          type: _selectedType!.name,
          valeurs: valeurs,
          dateCreation: DateTime.now(),
          fabricImagePaths: _fabricImagePaths,
        );

        dataService.addMeasurement(newMeasurement);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesure ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la sauvegarde: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}