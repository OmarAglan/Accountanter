import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../data/database.dart';
import '../../services/secure_storage_service.dart';

class AuthService extends ChangeNotifier {
  final AppDatabase database = AppDatabase.instance;
  final SecureStorageService _secureStorage = SecureStorageService();
  final Random _random = Random.secure();

  String _legacyHashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  bool _isLicenseKeySyntaxValid(String key) {
    final normalized = key.trim().toUpperCase();
    if (normalized.isEmpty) return false;
    if (kDebugMode && normalized == 'TEST-LICENSE-KEY') return true;
    return RegExp(r'^[A-Z0-9]{4}(?:-[A-Z0-9]{4}){3}$').hasMatch(normalized);
  }

  String _hashLicenseKey(String licenseKey) {
    final normalized = licenseKey.trim().toUpperCase();
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  String _generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPasswordV1(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  String _encodePasswordHash(String password) {
    final salt = _generateSalt();
    final hash = _hashPasswordV1(password, salt);
    return 'v1:$salt:$hash';
  }

  bool _verifyPassword(String password, String storedHash) {
    if (storedHash.startsWith('v1:')) {
      final parts = storedHash.split(':');
      if (parts.length != 3) return false;
      final salt = parts[1];
      final expected = parts[2];
      return _hashPasswordV1(password, salt) == expected;
    }
    return _legacyHashPassword(password) == storedHash;
  }

  Future<bool> isAppActivated() async {
    final license = await database.getLicense();
    return license != null;
  }

  Future<bool> validateAndSaveLicense(String licenseKey) async {
    if (!_isLicenseKeySyntaxValid(licenseKey)) return false;

    final newLicense = LicensesCompanion(
      licenseKeyEncrypted: Value(_hashLicenseKey(licenseKey)),
      activationDate: Value(DateTime.now()),
    );
    await database.saveLicense(newLicense);
    return true;
  }

  Future<void> createLocalUser(String username, String password) async {
    final newUser = UsersCompanion(
      username: Value(username),
      passwordHash: Value(_encodePasswordHash(password)),
    );
    await database.createLocalUser(newUser);
  }

  Future<bool> login(String username, String password, bool rememberMe) async {
    final user = await database.getLocalUser();
    if (user == null) return false;

    final ok = user.username == username && _verifyPassword(password, user.passwordHash);
    if (!ok) return false;

    if (!user.passwordHash.startsWith('v1:')) {
      await database.updateLocalUserPasswordHash(user.id, _encodePasswordHash(password));
    }

    if (rememberMe) {
      await _secureStorage.saveRememberMeToken(username);
    } else {
      await _secureStorage.deleteRememberMeToken();
    }

    return true;
  }

  Future<String?> getLoggedInUser() async {
    final remembered = await _secureStorage.getRememberMeToken();
    if (remembered == null) return null;

    final user = await database.getLocalUser();
    if (user == null || user.username != remembered) {
      await _secureStorage.deleteRememberMeToken();
      return null;
    }

    return remembered;
  }

  Future<void> logout() async {
    await _secureStorage.deleteRememberMeToken();
  }

  Future<void> factoryReset() async {
    await database.factoryReset();
    await _secureStorage.deleteRememberMeToken();
  }
}
