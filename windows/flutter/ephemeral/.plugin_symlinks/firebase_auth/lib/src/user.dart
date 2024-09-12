part of firebase_auth;

class User {
  UserPlatform _delegate;

  final FirebaseAuth _auth;
  MultiFactor? _multiFactor;

  User._(this._auth, this._delegate) {
    UserPlatform.verify(_delegate);
  }

  String? get displayName {
    return _delegate.displayName;
  }

  String? get email {
    return _delegate.email;
  }

  bool get emailVerified {
    return _delegate.isEmailVerified;
  }

  bool get isAnonymous {
    return _delegate.isAnonymous;
  }

  UserMetadata get metadata {
    return _delegate.metadata;
  }

  String? get phoneNumber {
    return _delegate.phoneNumber;
  }

  String? get photoURL {
    return _delegate.photoURL;
  }

  List<UserInfo> get providerData {
    return _delegate.providerData;
  }

  String? get refreshToken {
    return _delegate.refreshToken;
  }

  String? get tenantId {
    return _delegate.tenantId;
  }

  String get uid {
    return _delegate.uid;
  }

  Future<void> delete() async {
    return _delegate.delete();
  }

  Future<String?> getIdToken([bool forceRefresh = false]) {
    return _delegate.getIdToken(forceRefresh);
  }

  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) {
    return _delegate.getIdTokenResult(forceRefresh);
  }
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    try {
      return UserCredential._(
        _auth,
        await _delegate.linkWithCredential(credential),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(_auth, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> linkWithProvider(
    AuthProvider provider,
  ) async {
    try {
      return UserCredential._(
        _auth,
        await _delegate.linkWithProvider(provider),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(_auth, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> reauthenticateWithProvider(
    AuthProvider provider,
  ) async {
    try {
      return UserCredential._(
        _auth,
        await _delegate.reauthenticateWithProvider(provider),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(_auth, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> reauthenticateWithPopup(
    AuthProvider provider,
  ) async {
    return UserCredential._(
      _auth,
      await _delegate.reauthenticateWithPopup(provider),
    );
  }

  Future<void> reauthenticateWithRedirect(
    AuthProvider provider,
  ) async {
    await _delegate.reauthenticateWithRedirect(provider);
  }

  Future<UserCredential> linkWithPopup(AuthProvider provider) async {
    try {
      return UserCredential._(
        _auth,
        await _delegate.linkWithPopup(provider),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(_auth, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> linkWithRedirect(AuthProvider provider) async {
    try {
      await _delegate.linkWithRedirect(provider);
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(_auth, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<ConfirmationResult> linkWithPhoneNumber(
    String phoneNumber, [
    RecaptchaVerifier? verifier,
  ]) async {
    assert(phoneNumber.isNotEmpty);

    bool mustClear = verifier == null;
    verifier ??= RecaptchaVerifier(auth: _delegate.auth);
    try {
      final result =
          await _delegate.linkWithPhoneNumber(phoneNumber, verifier.delegate);
      if (mustClear) {
        verifier.clear();
      }
      return ConfirmationResult._(_auth, result);
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(_auth, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    try {
      return UserCredential._(
        _auth,
        await _delegate.reauthenticateWithCredential(credential),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(_auth, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reload() async {
    await _delegate.reload();
  }

  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings,]) async {
    await _delegate.sendEmailVerification(actionCodeSettings);
  }

  Future<User> unlink(String providerId) async {
    return User._(_auth, await _delegate.unlink(providerId));
  }

  Future<void> updatePassword(String newPassword) async {
    await _delegate.updatePassword(newPassword);
  }

  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    await _delegate.updatePhoneNumber(phoneCredential);
  }

  Future<void> updateDisplayName(String? displayName) {
    return _delegate
        .updateProfile(<String, String?>{'displayName': displayName});
  }

  Future<void> updatePhotoURL(String? photoURL) {
    return _delegate.updateProfile(<String, String?>{'photoURL': photoURL});
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) {
    return _delegate.updateProfile(<String, String?>{
      'displayName': displayName,
      'photoURL': photoURL,
    });
  }

  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings,]) async {
    await _delegate.verifyBeforeUpdateEmail(newEmail, actionCodeSettings);
  }

  MultiFactor get multiFactor {
    if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
      throw UnimplementedError(
        'MultiFactor Authentication is only supported on web, Android and iOS.',
      );
    }
    return _multiFactor ??= MultiFactor._(_delegate.multiFactor);
  }

  @override
  String toString() {
    return '$User('
        'displayName: $displayName, '
        'email: $email, '
        'isEmailVerified: $emailVerified, '
        'isAnonymous: $isAnonymous, '
        'metadata: $metadata, '
        'phoneNumber: $phoneNumber, '
        'photoURL: $photoURL, '
        'providerData, $providerData, '
        'refreshToken: $refreshToken, '
        'tenantId: $tenantId, '
        'uid: $uid)';
  }
}
