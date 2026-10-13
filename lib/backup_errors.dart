import 'dart:async';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' show DetailedApiRequestError;
import 'package:http/http.dart' as http;
import 'crypto_backup.dart';

/// The user must sign in / grant Drive access again (expired, revoked or never granted). Actionable, so it is
/// worth a notification even on the first failure.
class BackupAuthException implements Exception {
  final String message;
  const BackupAuthException(this.message);
  @override
  String toString() => message;
}

bool isAuthProblem(Object e) {
  if (e is BackupAuthException) return true;
  if (e is DetailedApiRequestError && e.status == 401) return true;
  if (e is GoogleSignInException) {
    return e.code != GoogleSignInExceptionCode.canceled && e.code != GoogleSignInExceptionCode.interrupted;
  }
  return false;
}

/// A sentence a person can act on, instead of a raw exception.
String friendlyBackupError(Object e) {
  if (e is String) return e;
  if (e is BackupAuthException) return e.message;
  if (e is WrongPassphrase) return e.toString();
  if (e is SocketException || e is http.ClientException || e is TimeoutException) {
    return 'No internet connection. The backup will try again on its own.';
  }
  if (e is DetailedApiRequestError) {
    final detail = '${e.message ?? ''} ${e.errors.map((x) => x.reason).join(' ')}'.toLowerCase();
    switch (e.status) {
      case 401:
        return 'Your Google sign-in ran out. Open Pagemark, go to Settings, then Backup and restore, then Back up to Google Drive, and sign in again.';
      case 403:
        if (detail.contains('quota') || detail.contains('storage')) return 'Your Google Drive is full. Free some space and back up again.';
        if (detail.contains('ratelimit') || detail.contains('rate limit')) return 'Google is limiting requests right now. Try again in a few minutes.';
        if (detail.contains('accessnotconfigured') || detail.contains('has not been used')) {
          return 'Google Drive is not switched on for this app yet. See the setup guide, then try again.';
        }
        return 'Google Drive said no. Check the setup guide, then try again.';
      case 404:
        return 'Google Drive could not find the backup. Please try Back up now again.';
      case 429:
        return 'Google is limiting requests right now. Try again in a few minutes.';
      default:
        if ((e.status ?? 0) >= 500) return 'Google Drive is having problems. Pagemark will try again later.';
    }
    return 'Google Drive had a problem (code ${e.status}). Please try again later.';
  }
  if (e is GoogleSignInException) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return 'Sign-in was cancelled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google would not accept the sign-in settings. See the setup guide.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'A different Google account is signed in. Sign out, then sign in with the account you backed up with.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in could not open. Please try again.';
      default:
        return 'Google sign-in failed. Check your connection and try again.';
    }
  }
  return 'The backup failed (${e.runtimeType}). Details are in Settings, Help and about, Problem report.';
}

/// When a background backup fails, should we bother the user? Auth problems need action: tell them at once.
/// Everything else (offline, Drive hiccup) is usually transient: wait for the second failure, then once a week.
bool shouldNotifyBackupFailure(int streak, {required bool authProblem}) {
  if (authProblem && streak == 1) return true;
  return streak == 2 || (streak >= 7 && streak % 7 == 0);
}
