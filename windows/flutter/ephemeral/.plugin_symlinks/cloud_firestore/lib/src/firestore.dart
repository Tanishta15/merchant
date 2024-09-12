part of cloud_firestore;

class FirebaseFirestore extends FirebasePluginPlatform {
  FirebaseFirestore._({
    required this.app,
    @Deprecated(
      '`databaseURL` has been deprecated. Please use `databaseId` instead.',
    )
    required this.databaseURL,
    required this.databaseId,
  }) : super(app.name, 'plugins.flutter.io/firebase_firestore');

  static final Map<String, FirebaseFirestore> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseFirestore get instance {
    return FirebaseFirestore.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseFirestore instanceFor({
    required FirebaseApp app,
    @Deprecated(
      '`databaseURL` has been deprecated. Please use `databaseId` instead.',
    )
    String? databaseURL,
    String? databaseId,
  }) {
    String firestoreDatabaseId = databaseId ?? databaseURL ?? '(default)';
    String cacheKey = '${app.name}|$firestoreDatabaseId';
    if (_cachedInstances.containsKey(cacheKey)) {
      return _cachedInstances[cacheKey]!;
    }

    FirebaseFirestore newInstance =
        FirebaseFirestore._(
      app: app,
      databaseURL: firestoreDatabaseId,
      databaseId: firestoreDatabaseId,
    );
    _cachedInstances[cacheKey] = newInstance;

    return newInstance;
  }

  FirebaseFirestorePlatform? _delegatePackingProperty;

  FirebaseFirestorePlatform get _delegate {
    return _delegatePackingProperty ??= FirebaseFirestorePlatform.instanceFor(
      app: app,
      databaseId: databaseId,
    );
  }

  FirebaseApp app;

  @Deprecated(
    '`databaseURL` has been deprecated. Please use `databaseId` instead.',
  )
  String databaseURL;

  String databaseId;

  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    assert(
      collectionPath.isNotEmpty,
      'a collectionPath path must be a non-empty string',
    );
    assert(
      !collectionPath.contains('//'),
      'a collection path must not contain "//"',
    );
    assert(
      isValidCollectionPath(collectionPath),
      'a collection path must point to a valid collection.',
    );

    return _JsonCollectionReference(this, _delegate.collection(collectionPath));
  }

  WriteBatch batch() {
    return WriteBatch._(this, _delegate.batch());
  }

  Future<void> clearPersistence() {
    return _delegate.clearPersistence();
  }
  @Deprecated('Use Settings.persistenceEnabled instead.')
  Future<void> enablePersistence([
    PersistenceSettings? persistenceSettings,
  ]) async {
    return _delegate.enablePersistence(persistenceSettings);
  }

  LoadBundleTask loadBundle(Uint8List bundle) {
    return LoadBundleTask._(_delegate.loadBundle(bundle));
  }

  void useFirestoreEmulator(
    String host,
    int port, {
    bool sslEnabled = false,
    bool automaticHostMapping = true,
  }) {
    if (kIsWeb) {
      try {
        _delegate.useEmulator(host, port);
      } catch (e) {

        String strError = e.toString();

        if (!strError.contains('failed-precondition')) {
          rethrow;
        }
      }
    } else {
      String mappedHost = host;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if ((mappedHost == 'localhost' || mappedHost == '127.0.0.1') &&
            automaticHostMapping) {
          // ignore: avoid_print
          print('Mapping Firestore Emulator host "$mappedHost" to "10.0.2.2".');
          mappedHost = '10.0.2.2';
        }
      }

      _delegate.settings = _delegate.settings.copyWith(
        sslEnabled: sslEnabled,
        host: '$mappedHost:$port',
      );
    }
  }

  Future<QuerySnapshot<T>> namedQueryWithConverterGet<T>(
    String name, {
    GetOptions options = const GetOptions(),
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) async {
    final snapshot = await namedQueryGet(name, options: options);

    return _WithConverterQuerySnapshot<T>(snapshot, fromFirestore, toFirestore);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> namedQueryGet(
    String name, {
    GetOptions options = const GetOptions(),
  }) async {
    QuerySnapshotPlatform snapshotDelegate =
        await _delegate.namedQueryGet(name, options: options);
    return _JsonQuerySnapshot(FirebaseFirestore.instance, snapshotDelegate);
  }

  Query<Map<String, dynamic>> collectionGroup(String collectionPath) {
    assert(
      collectionPath.isNotEmpty,
      'a collection path must be a non-empty string',
    );
    assert(
      !collectionPath.contains('/'),
      'a collection path passed to collectionGroup() cannot contain "/"',
    );

    return _JsonQuery(this, _delegate.collectionGroup(collectionPath));
  }

  Future<void> disableNetwork() {
    return _delegate.disableNetwork();
  }

  DocumentReference<Map<String, dynamic>> doc(String documentPath) {
    assert(
      documentPath.isNotEmpty,
      'a document path must be a non-empty string',
    );
    assert(
      !documentPath.contains('//'),
      'a collection path must not contain "//"',
    );
    assert(
      isValidDocumentPath(documentPath),
      'a document path must point to a valid document.',
    );

    return _JsonDocumentReference(this, _delegate.doc(documentPath));
  }

  Future<void> enableNetwork() {
    return _delegate.enableNetwork();
  }

  Stream<void> snapshotsInSync() {
    return _delegate.snapshotsInSync();
  }

  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    late T output;
    await _delegate.runTransaction(
      (transaction) async {
        output = await transactionHandler(Transaction._(this, transaction));
      },
      timeout: timeout,
      maxAttempts: maxAttempts,
    );

    return output;
  }

  set settings(Settings settings) {
    _delegate.settings = _delegate.settings.copyWith(
      sslEnabled: settings.sslEnabled,
      persistenceEnabled: settings.persistenceEnabled,
      host: settings.host,
      cacheSizeBytes: settings.cacheSizeBytes,
      webExperimentalForceLongPolling: settings.webExperimentalForceLongPolling,
      webExperimentalAutoDetectLongPolling:
          settings.webExperimentalAutoDetectLongPolling,
      webExperimentalLongPollingOptions:
          settings.webExperimentalLongPollingOptions,
    );
  }

  Settings get settings {
    return _delegate.settings;
  }

  Future<void> terminate() {
    return _delegate.terminate();
  }

  Future<void> waitForPendingWrites() {
    return _delegate.waitForPendingWrites();
  }

  @Deprecated(
    'setIndexConfiguration() has been deprecated. Please use `PersistentCacheIndexManager` instead.',
  )
  Future<void> setIndexConfiguration({
    required List<Index> indexes,
    List<FieldOverrides>? fieldOverrides,
  }) async {
    String json = jsonEncode(
      {
        'indexes': indexes.map((index) => index.toMap()).toList(),
        'fieldOverrides':
            fieldOverrides?.map((index) => index.toMap()).toList() ?? [],
      },
    );

    return _delegate.setIndexConfiguration(json);
  }

  PersistentCacheIndexManager? persistentCacheIndexManager() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      throw UnimplementedError(
        '`PersistentCacheIndexManager` is not available on Windows platform',
      );
    }

    PersistentCacheIndexManagerPlatform? indexManager =
        _delegate.persistentCacheIndexManager();
    if (indexManager != null) {
      return PersistentCacheIndexManager._(
        indexManager,
      );
    }
    return null;
  }

  @experimental
  Future<void> setIndexConfigurationFromJSON(String json) async {
    return _delegate.setIndexConfiguration(json);
  }

  static Future<void> setLoggingEnabled(bool enabled) {
    return FirebaseFirestorePlatform.instance.setLoggingEnabled(enabled);
  }

  @override
  bool operator ==(Object other) =>
      other is FirebaseFirestore && other.app.name == app.name;

  @override
  int get hashCode => Object.hash(app.name, app.options);

  @override
  String toString() => '$FirebaseFirestore(app: ${app.name})';
}
