import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/custom_measurement.dart';

class CustomMeasurementFormScreen extends StatefulWidget {
  final CustomMeasurement? customMeasurement;

  const CustomMeasurementFormScreen({Key? key, this.customMeasurement}) : super(key: key);

  @override
  _CustomMeasurementFormScreenState createState() => _CustomMeasurementFormScreenState();
}

class _CustomMeasurementFormScreenState extends State<CustomMeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedUnit = 'cm';
  bool _isEditing = false;

  final List<String> _units = ['cm', 'mm', 'pouces'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.customMeasurement != null;
    
    if (_isEditing) {
      _nameController.text = widget.customMeasurement!.name;
      _selectedUnit = widget.customMeasurement!.unit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la mesure' : 'Nouvelle mesure'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteCustomMeasurement,
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
              SizedBox(height: 20),
              _buildUnitField(),
              Spacer(),
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
          'Nom de la mesure',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Ex: Longueur genou, Tour de bras...',
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

  Widget _buildUnitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unité de mesure',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedUnit,
          items: _units.map((String unit) {
            return DropdownMenuItem<String>(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedUnit = newValue!;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
            onPressed: _saveCustomMeasurement,
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

  void _saveCustomMeasurement() {
    if (_formKey.currentState!.validate()) {
      final dataService = Provider.of<DataService>(context, listen: false);

      final customMeasurement = CustomMeasurement(
        id: _isEditing ? widget.customMeasurement!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        unit: _selectedUnit,
        dateCreated: _isEditing ? widget.customMeasurement!.dateCreated : DateTime.now(),
      );

      if (_isEditing) {
        dataService.updateCustomMeasurement(customMeasurement);
      } else {
        dataService.addCustomMeasurement(customMeasurement);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Mesure modifiée avec succès' : 'Mesure créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _deleteCustomMeasurement() {
    final dataService = Provider.of<DataService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la mesure'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${_nameController.text}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              dataService.deleteCustomMeasurement(widget.customMeasurement!.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mesure supprimée avec succès'),
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
    super.dispose();
  }
}