import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String password;

  const VerifyEmailScreen({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Bouton retour
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.blue),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/welcome');
                  },
                ),
                SizedBox(height: 40),
                Center(
                  child: Icon(
                    Icons.email_outlined,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Vérification d\'email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Nous avons envoyé un code de vérification à',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                _buildCodeField(),
                SizedBox(height: 24),
                if (_errorMessage.isNotEmpty) _buildErrorWidget(),
                SizedBox(height: 24),
                _buildVerifyButton(),
                SizedBox(height: 20),
                _buildResendCodeSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code de vérification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: 'Entrez le code à 6 chiffres',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le code de vérification';
            }
            if (value.length != 6) {
              return 'Le code doit contenir 6 chiffres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Vérifier l\'email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildResendCodeSection() {
    return Column(
      children: [
        Text(
          'Vous n\'avez pas reçu le code ?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: _isResending ? null : _resendCode,
          child: _isResending
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              : Text(
                  'Renvoyer le code',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
        ),
        SizedBox(height: 8),
        Text(
          'Le code expire après 12 heures',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        final result = await dataService.verifyEmail(
          widget.email,
          _codeController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Connexion automatique après vérification
          final loginResult = await dataService.login(
            widget.email,
            widget.password,
          );

          if (loginResult['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            setState(() {
              _errorMessage = loginResult['message'];
            });
          }
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur lors de la vérification. Veuillez réessayer.';
        });
      }
    }
  }

  void _resendCode() async {
    setState(() {
      _isResending = true;
      _errorMessage = '';
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final result = await dataService.resendVerificationCode(widget.email);

      setState(() {
        _isResending = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _isResending = false;
        _errorMessage = 'Erreur lors de l\'envoi du code. Veuillez réessayer.';
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}