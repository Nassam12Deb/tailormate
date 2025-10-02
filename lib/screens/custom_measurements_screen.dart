import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/custom_measurement.dart';
import 'custom_measurement_form_screen.dart';

class CustomMeasurementsScreen extends StatelessWidget {
  const CustomMeasurementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesures personnalisées'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: dataService.customMeasurements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.straighten_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune mesure personnalisée',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez votre première mesure personnalisée',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: dataService.customMeasurements.length,
              itemBuilder: (context, index) {
                final measurement = dataService.customMeasurements[index];
                return _CustomMeasurementCard(measurement: measurement);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomMeasurementFormScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _CustomMeasurementCard extends StatelessWidget {
  final CustomMeasurement measurement;

  const _CustomMeasurementCard({Key? key, required this.measurement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.straighten, color: Colors.green),
        ),
        title: Text(
          measurement.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Unité: ${measurement.unit}',
          style: TextStyle(color: Colors.grey[600]),
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
                    builder: (context) => CustomMeasurementFormScreen(customMeasurement: measurement),
                  ),
                );
                break;
              case 'delete':
                _showDeleteDialog(context, measurement, dataService);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CustomMeasurement measurement, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la mesure'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${measurement.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              dataService.deleteCustomMeasurement(measurement.id);
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
}