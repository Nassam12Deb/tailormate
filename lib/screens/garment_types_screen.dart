import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/garment_type.dart';
import 'garment_type_form_screen.dart';

class GarmentTypesScreen extends StatelessWidget {
  const GarmentTypesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Types de vêtements'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: dataService.garmentTypes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun type de vêtement',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez votre premier type de vêtement',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: dataService.garmentTypes.length,
              itemBuilder: (context, index) {
                final type = dataService.garmentTypes[index];
                return _GarmentTypeCard(type: type);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GarmentTypeFormScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _GarmentTypeCard extends StatelessWidget {
  final GarmentType type;

  const _GarmentTypeCard({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.checkroom, color: Colors.blue),
        ),
        title: Text(
          type.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${type.measurementFields.length} mesures associées',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: type.measurementFields.take(3).map((field) {
                return Chip(
                  label: Text(field),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Modifier'),
              value: 'edit',
            ),
            PopupMenuItem(
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              value: 'delete',
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GarmentTypeFormScreen(garmentType: type),
                  ),
                );
                break;
              case 'delete':
                _showDeleteDialog(context, type, dataService);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, GarmentType type, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le type de vêtement'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${type.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              dataService.deleteGarmentType(type.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Type de vêtement supprimé avec succès'),
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
}