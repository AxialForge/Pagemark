import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' show DetailedApiRequestError;
import 'package:http/http.dart' as http;
import 'package:pagemark/backup_errors.dart';
import 'package:pagemark/crypto_backup.dart';

void main() {
  group('friendlyBackupError', () {
    test('network problems are explained, not dumped', () {
      for (final e in [const SocketException('x'), http.ClientException('x'), TimeoutException('x')]) {
        expect(friendlyBackupError(e), contains('No internet'));
      }
    });

    test('Drive status codes map to actions', () {
      expect(friendlyBackupError(DetailedApiRequestError(401, 'bad')), contains('sign in again'));
      expect(friendlyBackupError(DetailedApiRequestError(403, 'The user has exceeded their storage quota')), contains('Drive is full'));
      expect(friendlyBackupError(DetailedApiRequestError(403, 'Rate Limit Exceeded')), contains('limiting'));
      expect(friendlyBackupError(DetailedApiRequestError(403, 'Google Drive API has not been used in project 123')), contains('not enabled'));
      expect(friendlyBackupError(DetailedApiRequestError(403, 'forbidden')), contains('refused'));
      expect(friendlyBackupError(DetailedApiRequestError(404, 'x')), contains('could not find'));
      expect(friendlyBackupError(DetailedApiRequestError(429, 'x')), contains('limiting'));
      expect(friendlyBackupError(DetailedApiRequestError(503, 'x')), contains('having problems'));
      expect(friendlyBackupError(DetailedApiRequestError(418, 'x')), contains('418'));
    });

    test('sign-in exceptions and our own messages', () {
      expect(friendlyBackupError(const GoogleSignInException(code: GoogleSignInExceptionCode.canceled)), contains('cancelled'));
      expect(friendlyBackupError(const GoogleSignInException(code: GoogleSignInExceptionCode.clientConfigurationError)), contains('client ID'));
      expect(friendlyBackupError(const BackupAuthException('sign in please')), 'sign in please');
      expect(friendlyBackupError('plain string'), 'plain string');
      expect(friendlyBackupError(WrongPassphrase()), contains('Wrong passphrase'));
      expect(friendlyBackupError(StateError('boom')), allOf(contains('StateError'), contains('Diagnostics')));
    });
  });

  test('auth problems are recognised (they need the user, so they notify at once)', () {
    expect(isAuthProblem(const BackupAuthException('x')), isTrue);
    expect(isAuthProblem(DetailedApiRequestError(401, 'x')), isTrue);
    expect(isAuthProblem(const GoogleSignInException(code: GoogleSignInExceptionCode.clientConfigurationError)), isTrue);
    expect(isAuthProblem(const GoogleSignInException(code: GoogleSignInExceptionCode.canceled)), isFalse);
    expect(isAuthProblem(DetailedApiRequestError(500, 'x')), isFalse);
    expect(isAuthProblem(const SocketException('x')), isFalse);
  });

  test('notification policy: immediate for auth, quiet for transient failures, then weekly', () {
    expect(shouldNotifyBackupFailure(1, authProblem: true), isTrue);
    expect(shouldNotifyBackupFailure(2, authProblem: true), isTrue);
    expect(shouldNotifyBackupFailure(3, authProblem: true), isFalse);
    expect(shouldNotifyBackupFailure(1, authProblem: false), isFalse, reason: 'a single offline night is not worth a buzz');
    expect(shouldNotifyBackupFailure(2, authProblem: false), isTrue);
    expect([for (var i = 1; i <= 15; i++) if (shouldNotifyBackupFailure(i, authProblem: false)) i], [2, 7, 14]);
  });
}
