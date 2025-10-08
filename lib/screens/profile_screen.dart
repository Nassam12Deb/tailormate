import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/cloud_service.dart';
import 'edit_personal_data_screen.dart';
import 'update_email_screen.dart';
import 'change_password_screen.dart';
import '../services/cloud_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon compte'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // En-tête utilisateur
          if (dataService.currentUser != null)
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 40,
                      child: Text(
                        dataService.currentUser!.prenom[0].toUpperCase() + dataService.currentUser!.nom[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      dataService.currentUser!.fullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      dataService.currentUser!.email,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dataService.currentUser!.telephone,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Membre depuis ${_formatDate(dataService.currentUser!.dateCreation)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                _ProfileSection(
                  title: 'Données personnelles',
                  actionText: 'Mettre à jour →',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPersonalDataScreen(),
                      ),
                    );
                  },
                ),
                _ProfileSection(
                  title: 'Adresse Email',
                  actionText: 'Modifier Adresse email →',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateEmailScreen(),
                      ),
                    );
                  },
                ),
                _ProfileSection(
                  title: 'Sécurité',
                  actionText: 'Changer votre mot de passe →',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                // Nouvelle section Sauvegarde Cloud
                _ProfileSection(
                  title: 'Sauvegarde Cloud',
                  actionText: 'Gérer →',
                  onTap: () {
                    _showCloudBackupDialog(context);
                  },
                ),
                _ProfileSection(
                  title: 'À propos',
                  actionText: 'Information sur l\'application →',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                _ProfileSection(
                  title: 'Se déconnecter',
                  actionText: '',
                  onTap: () {
                    _showLogoutDialog(context, dataService);
                  },
                  isLogout: true,
                ),
                _ProfileSection(
                  title: 'Supprimer votre compte',
                  actionText: '',
                  onTap: () {
                    _showDeleteAccountDialog(context, dataService);
                  },
                  isDelete: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCloudBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sauvegarde Cloud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Protégez vos données avec la sauvegarde cloud',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '• Sauvegarde automatique',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              '• Restauration facile',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              '• Sécurisé et chiffré',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCloudBackupOptions(context);
            },
            child: Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showCloudBackupOptions(BuildContext context) {
    final cloudService = CloudService();
    final dataService = Provider.of<DataService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Sauvegarde Cloud'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.cloud_upload, color: Colors.blue),
                  title: Text('Sauvegarder sur le cloud'),
                  subtitle: Text('Télécharge vos données vers le cloud'),
                  onTap: () async {
                    Navigator.pop(context);
                    _showBackupProgress(context, true);
                    
                    final success = await cloudService.backupToCloud(dataService);
                    
                    Navigator.pop(context); // Fermer la dialog de progression
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sauvegarde cloud réussie !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Échec de la sauvegarde cloud'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.cloud_download, color: Colors.green),
                  title: Text('Restaurer depuis le cloud'),
                  subtitle: Text('Télécharge vos données du cloud'),
                  onTap: () async {
                    Navigator.pop(context);
                    _showBackupProgress(context, false);
                    
                    final success = await cloudService.restoreFromCloud(dataService);
                    
                    Navigator.pop(context); // Fermer la dialog de progression
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Restauration cloud réussie !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Échec de la restauration cloud'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.history, color: Colors.orange),
                  title: Text('Historique des sauvegardes'),
                  subtitle: Text('Voir vos sauvegardes précédentes'),
                  onTap: () {
                    Navigator.pop(context);
                    _showBackupHistory(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBackupProgress(BuildContext context, bool isBackup) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isBackup ? 'Sauvegarde en cours' : 'Restauration en cours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(isBackup 
              ? 'Téléchargement de vos données vers le cloud...'
              : 'Téléchargement de vos données depuis le cloud...'
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupHistory(BuildContext context) {
    final cloudService = CloudService();
    
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<BackupItem>>(
        future: cloudService.getBackupHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              title: Text('Historique des sauvegardes'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement...'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fermer'),
                ),
              ],
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return AlertDialog(
              title: Text('Historique des sauvegardes'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_toggle_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune sauvegarde trouvée'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fermer'),
                ),
              ],
            );
          }
          
          final backups = snapshot.data!;
          
          return AlertDialog(
            title: Text('Historique des sauvegardes'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: backups.length,
                itemBuilder: (context, index) {
                  final backup = backups[index];
                  return ListTile(
                    leading: Icon(Icons.backup, color: Colors.blue),
                    title: Text('Sauvegarde du ${_formatDateTime(backup.date)}'),
                    subtitle: Text('${backup.dataCount} éléments'),
                    trailing: Text('${backup.size}'),
                    onTap: () {
                      // Option pour restaurer cette sauvegarde spécifique
                      _showRestoreConfirmation(context, backup);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context, BackupItem backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restaurer la sauvegarde'),
        content: Text(
          'Voulez-vous restaurer la sauvegarde du ${_formatDateTime(backup.date)} ?\n\n'
          'Cette action écrasera vos données actuelles.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer cette dialog
              Navigator.pop(context); // Fermer l'historique
              _performSpecificRestore(context, backup);
            },
            child: Text('Restaurer'),
          ),
        ],
      ),
    );
  }

  void _performSpecificRestore(BuildContext context, BackupItem backup) async {
    final cloudService = CloudService();
    final dataService = Provider.of<DataService>(context, listen: false);
    
    _showBackupProgress(context, false);
    
    final success = await cloudService.restoreSpecificBackup(dataService, backup.id);
    
    Navigator.pop(context); // Fermer la dialog de progression
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sauvegarde restaurée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la restauration'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('À propos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TailorMate v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Application de gestion de mesures pour tailleurs.'),
            SizedBox(height: 8),
            Text('Développé avec Flutter.'),
            SizedBox(height: 8),
            Text('© 2024 Tous droits réservés.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Se déconnecter'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              dataService.logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le compte'),
        content: Text(
            'Cette action est irréversible. Toutes vos données seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (dataService.currentUser != null) {
                dataService.deleteUserAccount(dataService.currentUser!.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Compte supprimé avec succès.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
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

class _ProfileSection extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;
  final bool isLogout;
  final bool isDelete;

  const _ProfileSection({
    required this.title,
    required this.actionText,
    required this.onTap,
    this.isLogout = false,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: isDelete ? Colors.red : null,
              fontWeight: isLogout || isDelete ? FontWeight.bold : null,
            ),
          ),
          trailing: actionText.isNotEmpty
              ? Text(
                  actionText,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
          onTap: onTap,
        ),
        Divider(height: 1),
      ],
    );
  }
}