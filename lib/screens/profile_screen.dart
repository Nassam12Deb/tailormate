import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

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
      body: ListView(
        children: [
          _ProfileSection(
            title: 'Données personnelles',
            actionText: 'Mettre à jour →',
            onTap: () {
              _showUpdatePersonalDataDialog(context);
            },
          ),
          _ProfileSection(
            title: 'Adresse Email',
            actionText: 'Modifier Adresse email →',
            onTap: () {
              _showUpdateEmailDialog(context);
            },
          ),
          _ProfileSection(
            title: 'Sécurité',
            actionText: 'Changer votre mot de passe →',
            onTap: () {
              _showChangePasswordDialog(context);
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
              _showDeleteAccountDialog(context);
            },
            isDelete: true,
          ),
        ],
      ),
    );
  }

  void _showUpdatePersonalDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mettre à jour les données personnelles'),
        content: Text('Fonctionnalité disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUpdateEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier l\'adresse email'),
        content: Text('Fonctionnalité disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le mot de passe'),
        content: Text('Fonctionnalité disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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

  void _showDeleteAccountDialog(BuildContext context) {
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fonctionnalité disponible prochainement.'),
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