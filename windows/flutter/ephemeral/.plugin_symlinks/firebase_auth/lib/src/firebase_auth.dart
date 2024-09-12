part of firebase_auth;

class FirebaseAuth extends FirebasePluginPlatform {
  static Map<String, FirebaseAuth> _firebaseAuthInstances = {};

  FirebaseAuthPlatform? _delegatePackingProperty;

  FirebaseAuthPlatform get _delegate {
    _delegatePackingProperty ??= FirebaseAuthPlatform.instanceFor(
      app: app,
      pluginConstants: pluginConstants,
    );
    return _delegatePackingProperty!;
  }

  FirebaseApp app;

  FirebaseAuth._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_auth');

  static FirebaseAuth get instance {
    FirebaseApp defaultAppInstance = Firebase.app();

    return FirebaseAuth.instanceFor(app: defaultAppInstance);
  }

  factory FirebaseAuth.instanceFor({
    required FirebaseApp app,
    @Deprecated(
      'Will be removed in future release. Use setPersistence() instead.',
    )
    Persistence? persistence,
  }) {
    return _firebaseAuthInstances.putIfAbsent(app.name, () {
      return FirebaseAuth._(app: app);
    });
  }

  User? get currentUser {
    if (_delegate.currentUser != null) {
      return User._(this, _delegate.currentUser!);
    }

    return null;
  }

  String? get languageCode {
    return _delegate.languageCode;
  }

  Future<void> useAuthEmulator(String host, int port,
      {bool automaticHostMapping = true}) async {
    String mappedHost = host;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if ((mappedHost == 'localhost' || mappedHost == '127.0.0.1') &&
          automaticHostMapping) {
        print('Mapping Auth Emulator host "$mappedHost" to "10.0.2.2".');
        mappedHost = '10.0.2.2';
      }
    }

    await _delegate.useAuthEmulator(mappedHost, port);
  }

  String? get tenantId {
    return _delegate.tenantId;
  }

  set tenantId(String? tenantId) {
    _delegate.tenantId = tenantId;
  }

  String? get customAuthDomain {
    return _delegate.customAuthDomain;
  }

  set customAuthDomain(String? customAuthDomain) {

    if (defaultTargetPlatform == TargetPlatform.windows || kIsWeb) {
      final message = defaultTargetPlatform == TargetPlatform.windows
          ? 'Cannot set custom auth domain on a FirebaseAuth instance for windows platform'
          : 'Cannot set custom auth domain on a FirebaseAuth instance. Set the custom auth domain on `FirebaseOptions.authDomain` instance and pass into `Firebase.initializeApp()` instead.';
      throw UnimplementedError(
        message,
      );
    }
    _delegate.customAuthDomain = customAuthDomain;
  }

  Future<void> applyActionCode(String code) async {
    await _delegate.applyActionCode(code);
  }

  Future<ActionCodeInfo> checkActionCode(String code) {
    return _delegate.checkActionCode(code);
  }
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    await _delegate.confirmPasswordReset(code, newPassword);
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return UserCredential._(
      this,
      await _delegate.createUserWithEmailAndPassword(email, password),
    );
  }

  @Deprecated('fetchSignInMethodsForEmail() has been deprecated. '
      'Migrating off of this method is recommended as a security best-practice. Learn more in the Identity Platform documentation: '
      ' https://cloud.google.com/identity-platform/docs/admin/email-enumeration-protection.')
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    return _delegate.fetchSignInMethodsForEmail(email);
  }

  Future<UserCredential> getRedirectResult() async {
    return UserCredential._(this, await _delegate.getRedirectResult());
  }

  bool isSignInWithEmailLink(String emailLink) {
    return _delegate.isSignInWithEmailLink(emailLink);
  }

  Stream<User?> _pipeStreamChanges(Stream<UserPlatform?> stream) {
    return stream.map((delegateUser) {
      if (delegateUser == null) {
        return null;
      }

      return User._(this, delegateUser);
    }).asBroadcastStream(onCancel: (sub) => sub.cancel());
  }

  Stream<User?> authStateChanges() =>
      _pipeStreamChanges(_delegate.authStateChanges());

  Stream<User?> idTokenChanges() =>
      _pipeStreamChanges(_delegate.idTokenChanges());

  Stream<User?> userChanges() => _pipeStreamChanges(_delegate.userChanges());
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    return _delegate.sendPasswordResetEmail(email, actionCodeSettings);
  }

  Future<void> sendSignInLinkToEmail({
    required String email,
    required ActionCodeSettings actionCodeSettings,
  }) async {
    if (actionCodeSettings.handleCodeInApp != true) {
      throw ArgumentError(
        'The [handleCodeInApp] value of [ActionCodeSettings] must be `true`.',
      );
    }

    await _delegate.sendSignInLinkToEmail(email, actionCodeSettings);
  }

  Future<void> setLanguageCode(String? languageCode) {
    return _delegate.setLanguageCode(languageCode);
  }
  Future<void> setSettings({
    bool appVerificationDisabledForTesting = false,
    String? userAccessGroup,
    String? phoneNumber,
    String? smsCode,
    bool? forceRecaptchaFlow,
  }) {
    return _delegate.setSettings(
      appVerificationDisabledForTesting: appVerificationDisabledForTesting,
      userAccessGroup: userAccessGroup,
      phoneNumber: phoneNumber,
      smsCode: smsCode,
      forceRecaptchaFlow: forceRecaptchaFlow,
    );
  }

  Future<void> setPersistence(Persistence persistence) async {
    return _delegate.setPersistence(persistence);
  }

  Future<UserCredential> signInAnonymously() async {
    return UserCredential._(this, await _delegate.signInAnonymously());
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    try {
      return UserCredential._(
        this,
        await _delegate.signInWithCredential(credential),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(this, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithCustomToken(String token) async {
    try {
      return UserCredential._(
          this, await _delegate.signInWithCustomToken(token));
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(this, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return UserCredential._(
        this,
        await _delegate.signInWithEmailAndPassword(email, password),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(this, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      return UserCredential._(
        this,
        await _delegate.signInWithEmailLink(email, emailLink),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(this, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithProvider(
    AuthProvider provider,
  ) async {
    try {
      return UserCredential._(
        this,
        await _delegate.signInWithProvider(provider),
      );
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(this, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<ConfirmationResult> signInWithPhoneNumber(
    String phoneNumber, [
    RecaptchaVerifier? verifier,
  ]) async {
    assert(phoneNumber.isNotEmpty);

    bool mustClear = verifier == null;
    verifier ??= RecaptchaVerifier(auth: _delegate);
    final result =
        await _delegate.signInWithPhoneNumber(phoneNumber, verifier.delegate);
    if (mustClear) {
      verifier.clear();
    }
    return ConfirmationResult._(this, result);
  }

  Future<UserCredential> signInWithPopup(AuthProvider provider) async {
    try {
      return UserCredential._(this, await _delegate.signInWithPopup(provider));
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(this, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithRedirect(AuthProvider provider) {
    try {
      return _delegate.signInWithRedirect(provider);
    } on FirebaseAuthMultiFactorExceptionPlatform catch (e) {
      throw FirebaseAuthMultiFactorException._(this, e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _delegate.signOut();
  }

  Future<String> verifyPasswordResetCode(String code) {
    return _delegate.verifyPasswordResetCode(code);
  }

  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    @visibleForTesting String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
  }) {
    assert(
      phoneNumber != null || multiFactorInfo != null,
      'Either phoneNumber or multiFactorInfo must be provided.',
    );
    return _delegate.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      multiFactorInfo: multiFactorInfo,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting,
      multiFactorSession: multiFactorSession,
    );
  }

  Future<void> revokeTokenWithAuthorizationCode(String authorizationCode) {
    return _delegate.revokeTokenWithAuthorizationCode(authorizationCode);
  }

  @override
  String toString() {
    return 'FirebaseAuth(app: ${app.name})';
  }
}
