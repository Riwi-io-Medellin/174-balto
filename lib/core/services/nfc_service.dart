import 'dart:convert';

import 'package:nfc_manager/nfc_manager.dart';

class NfcFailure implements Exception {
  NfcFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Wraps nfc_manager to read/write the pet-tag URL stored on an NFC tag's
/// NDEF URI record. Tags are written with the public pet-tag page URL
/// (e.g. http://api-balto.duckdns.org/pet-tag/{petId}) so that any phone,
/// with or without the Balto app, can tap the tag and see the pet's info.
class NfcService {
  Future<bool> isAvailable() => NfcManager.instance.isAvailable();

  /// Waits for a tag tap and returns the pet id parsed from its NDEF URI
  /// record, or null if the tag has no readable pet-tag URI.
  Future<String?> readPetId() async {
    String? petId;
    Object? error;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);
          final uri = _extractUri(ndef?.cachedMessage);
          petId = uri == null ? null : _petIdFromUri(uri);
        } catch (e) {
          error = e;
        } finally {
          await NfcManager.instance.stopSession();
        }
      },
    );

    if (error != null) throw NfcFailure('Could not read the tag: $error');
    return petId;
  }

  /// Waits for a tag tap and writes [url] as an NDEF URI record.
  Future<void> writeUrl(String url) async {
    Object? error;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            error = NfcFailure('This tag does not support NDEF.');
            return;
          }
          if (!ndef.isWritable) {
            error = NfcFailure('This tag is read-only.');
            return;
          }
          await ndef.write(NdefMessage([NdefRecord.createUri(Uri.parse(url))]));
        } catch (e) {
          error = e;
        } finally {
          await NfcManager.instance.stopSession();
        }
      },
    );

    if (error != null) throw NfcFailure('Could not write the tag: $error');
  }

  Future<void> stopSession() => NfcManager.instance.stopSession();

  Uri? _extractUri(NdefMessage? message) {
    final records = message?.records;
    if (records == null || records.isEmpty) return null;
    for (final record in records) {
      if (record.typeNameFormat != NdefTypeNameFormat.nfcWellknown) continue;
      if (record.type.length != 1 || record.type[0] != 0x55) continue;
      if (record.payload.isEmpty) continue;

      final prefixIndex = record.payload[0];
      final prefix = prefixIndex < NdefRecord.URI_PREFIX_LIST.length
          ? NdefRecord.URI_PREFIX_LIST[prefixIndex]
          : '';
      final rest = utf8.decode(record.payload.sublist(1));
      final uri = Uri.tryParse('$prefix$rest');
      if (uri != null) return uri;
    }
    return null;
  }

  String? _petIdFromUri(Uri uri) {
    if (uri.pathSegments.isEmpty) return null;
    return uri.pathSegments.last;
  }
}
