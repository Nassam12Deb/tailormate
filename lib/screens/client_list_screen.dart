import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/client.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des clients'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: dataService.clients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun client',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez votre premier client',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: dataService.clients.length,
              itemBuilder: (context, index) {
                final client = dataService.clients[index];
                return _ClientCard(client: client);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addClient');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;

  const _ClientCard({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          client.fullName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.telephone),
            Text(client.adresse),
            Text(
              '${dataService.getMeasurementsByClient(client.id).length} mesures',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Voir les mesures'),
              value: 'measures',
            ),
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
              case 'measures':
                Navigator.pushNamed(
                  context,
                  '/clientMeasures',
                  arguments: client,
                );
                break;
              case 'edit':
                // Implémenter l'édition
                break;
              case 'delete':
                _showDeleteDialog(context, client, dataService);
                break;
            }
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/clientMeasures',
            arguments: client,
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Client client, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le client'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${client.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              dataService.deleteClient(client.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Client supprimé avec succès'),
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