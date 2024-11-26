import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionApp extends StatefulWidget {
  const EncryptionApp({Key? key}) : super(key: key);

  @override
  _EncryptionAppState createState() => _EncryptionAppState();
}

class _EncryptionAppState extends State<EncryptionApp> {
  final TextEditingController _textController = TextEditingController();
  String _encryptedText = '';
  String _decryptedText = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fixed encryption key and IV
  static final _key =
      encrypt.Key.fromUtf8('MySecretKey12345MySecretKey12345'); // 32 chars
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // Encryption method
  String encryptText(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      return 'Error during encryption: $e';
    }
  }

  // Decryption method
  String decryptText(String encryptedText) {
    try {
      final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return 'Error during decryption: $e';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Encryption/Decryption App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter Text to Encrypt/Decrypt',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.isEmpty) {
                      _showSnackBar('Please enter text to encrypt');
                      return;
                    }
                    setState(() {
                      _encryptedText = encryptText(_textController.text);
                      _decryptedText = ''; // Clear decrypted text
                    });
                  },
                  child: const Text('Encrypt'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_encryptedText.isEmpty) {
                      _showSnackBar('Please encrypt text first');
                      return;
                    }
                    setState(() {
                      _decryptedText = decryptText(_encryptedText);
                    });
                  },
                  child: const Text('Decrypt'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_encryptedText.isNotEmpty) ...[
              Text(
                'Encrypted Text:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(_encryptedText),
              ),
            ],
            if (_decryptedText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Decrypted Text:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(_decryptedText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
