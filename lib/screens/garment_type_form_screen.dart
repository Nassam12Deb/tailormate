import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/garment_type.dart';

class GarmentTypeFormScreen extends StatefulWidget {
  final GarmentType? garmentType;

  const GarmentTypeFormScreen({Key? key, this.garmentType}) : super(key: key);

  @override
  _GarmentTypeFormScreenState createState() => _GarmentTypeFormScreenState();
}

class _GarmentTypeFormScreenState extends State<GarmentTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<TextEditingController> _measurementControllers = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.garmentType != null;
    
    if (_isEditing) {
      _nameController.text = widget.garmentType!.name;
      for (final field in widget.garmentType!.measurementFields) {
        _measurementControllers.add(TextEditingController(text: field));
      }
    } else {
      // Ajouter un champ vide par défaut
      _measurementControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le type' : 'Nouveau type de vêtement'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteGarmentType,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildNameField(),
              SizedBox(height: 24),
              _buildMeasurementFields(),
              SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom du type de vêtement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Ex: Robe, Jupe, Costume...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMeasurementFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Mesures associées',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.add, color: Colors.blue),
              onPressed: _addMeasurementField,
            ),
          ],
        ),
        SizedBox(height: 8),
        ..._measurementControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Nom de la mesure (ex: Longueur genou)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                ),
                if (_measurementControllers.length > 1)
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.red),
                    onPressed: () => _removeMeasurementField(index),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Annuler'),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveGarmentType,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_isEditing ? 'Modifier' : 'Créer'),
          ),
        ),
      ],
    );
  }

  void _addMeasurementField() {
    setState(() {
      _measurementControllers.add(TextEditingController());
    });
  }

  void _removeMeasurementField(int index) {
    setState(() {
      _measurementControllers.removeAt(index);
    });
  }

  void _saveGarmentType() {
    if (_formKey.currentState!.validate()) {
      final dataService = Provider.of<DataService>(context, listen: false);
      final measurementFields = _measurementControllers
          .map((controller) => controller.text.trim())
          .where((field) => field.isNotEmpty)
          .toList();

      if (measurementFields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez ajouter au moins une mesure'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final garmentType = GarmentType(
        id: _isEditing ? widget.garmentType!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        measurementFields: measurementFields,
        dateCreated: _isEditing ? widget.garmentType!.dateCreated : DateTime.now(),
      );

      if (_isEditing) {
        dataService.updateGarmentType(garmentType);
      } else {
        dataService.addGarmentType(garmentType);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Type modifié avec succès' : 'Type créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _deleteGarmentType() {
    final dataService = Provider.of<DataService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le type'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${_nameController.text}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              dataService.deleteGarmentType(widget.garmentType!.id);
              Navigator.pop(context); // Fermer la dialog
              Navigator.pop(context); // Revenir à l'écran précédent
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Type supprimé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _measurementControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}