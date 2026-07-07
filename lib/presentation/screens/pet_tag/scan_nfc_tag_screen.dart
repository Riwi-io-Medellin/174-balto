import 'package:flutter/material.dart';

import '../../../core/services/nfc_service.dart';
import 'public_pet_tag_screen.dart';

/// Prompts the user to tap an NFC pet tag, reads the pet id from it, then
/// opens that pet's public tag info.
class ScanNfcTagScreen extends StatefulWidget {
  const ScanNfcTagScreen({super.key});

  @override
  State<ScanNfcTagScreen> createState() => _ScanNfcTagScreenState();
}

class _ScanNfcTagScreenState extends State<ScanNfcTagScreen> {
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _primary = Color(0xFF1BAA71);

  final _nfc = NfcService();
  String? _error;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _nfc.stopSession();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _error = null;
    });

    try {
      final available = await _nfc.isAvailable();
      if (!available) {
        setState(() {
          _scanning = false;
          _error =
              'NFC is not available on this device. Turn it on in your device settings.';
        });
        return;
      }

      final petId = await _nfc.readPetId();
      if (!mounted) return;

      if (petId == null) {
        setState(() {
          _scanning = false;
          _error = 'This tag is not linked to a Balto pet.';
        });
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PublicPetTagScreen(petId: petId)),
      );
    } on NfcFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = 'Something went wrong: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        title: const Text('Scan Pet Tag'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.nfc_rounded,
                size: 72,
                color: _scanning ? _primary : _textMuted,
              ),
              const SizedBox(height: 20),
              Text(
                _scanning
                    ? 'Hold your phone near the pet tag'
                    : (_error ?? 'Ready to scan'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _error != null ? Colors.red.shade700 : _textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              if (!_scanning)
                ElevatedButton(
                  onPressed: _startScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Try again'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
