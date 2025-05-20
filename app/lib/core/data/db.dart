import 'dart:developer';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tralala_app/core/models/contact.dart';
import 'package:tralala_app/core/models/chat.dart';
import 'package:tralala_app/core/models/message.dart';
import 'package:tralala_app/core/models/prekey.dart';
import 'package:tralala_app/core/models/session.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'tralala.db';

  static const String chatsTable = 'chats';
  static const String preKeysTable = 'prekeys';
  static const String sessionsTable = 'sessions';
  static const String contactsTable = 'contacts';
  static const String messagesTable = 'messages';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDatabase();

      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), dbName);
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) {
          print('Database opened successfully');
        },
      );

      // await db.execute('DELETE FROM $messagesTable');
      // await db.execute('DELETE FROM $chatsTable');
      // await db.execute('DELETE FROM $sessionsTable');
      // await db.execute('DELETE FROM $contactsTable');

      return db;
    } catch (e) {
      print('Error in _initDatabase: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $preKeysTable (
        identifier TEXT PRIMARY KEY NOT NULL,      	 
        public_key TEXT NOT NULL,             	 
        private_key TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expiration_date TIMESTAMP DEFAULT (datetime('now', '+7 days')),
        is_active INTEGER DEFAULT 1
      );
    ''');

    await db.execute('''
      CREATE TABLE $messagesTable (
        id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL,
        author TEXT NOT NULL,
        content TEXT NOT NULL DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        delivered_at TIMESTAMP,
        read_at TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE $chatsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        profile_image TEXT NOT NULL DEFAULT '',
        is_blocked INTEGER DEFAULT 0,
        is_muted INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        members_id TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (members_id) REFERENCES $contactsTable(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $sessionsTable (
        chat_id TEXT PRIMARY KEY,
        shared_secret TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE $contactsTable (
        id TEXT PRIMARY KEY,
        phone TEXT NOT NULL DEFAULT '',
        first_name TEXT NOT NULL DEFAULT '',
        last_name TEXT NOT NULL DEFAULT '',
        profile_image TEXT NOT NULL DEFAULT '',
        is_blocked INTEGER DEFAULT 0,
        is_muted INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> createSession(String contactId, String ephemeralKey) async {
    Database db = await instance.database;
    await db.insert(sessionsTable, {
      'contact_id': contactId,
      'ephemeral_key': ephemeralKey,
    });
  }

  Future<void> insertContact(Contact contact) async {
    try {
      Database db = await instance.database;
      await db.insert(
        contactsTable,
        contact.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting contact: $e');
      rethrow;
    }
  }

  Future<void> insertMessage(Message message) async {
    Database db = await instance.database;
    await db.insert(messagesTable, message.toJson());
  }

  Future<void> insertChat(Chat chat) async {
    Database db = await instance.database;
    await db.insert(
      chatsTable,
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Contact?> fetchContact(String id) async {
    Database db = await instance.database;
    List<Map<String, Object?>> maps = await db.query(
      contactsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return Contact.fromJson(maps[0]);
  }

  Future<int> getNumberOfKeys() async {
    Database db = await instance.database;
    List<Map<String, Object?>> maps = await db.query(preKeysTable);
    return maps.length;
  }

  Future<List<Contact>> fetchContacts() async {
    Database db = await instance.database;
    List<Map<String, Object?>> maps = await db.query(contactsTable);
    return List.generate(maps.length, (i) => Contact.fromJson(maps[i]));
  }

  Future<Session?> fetchSession(String chatId) async {
    Database db = await instance.database;
    List<Map<String, Object?>> maps = await db.query(
      sessionsTable,
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );

    if (maps.isEmpty) return null;

    return Session.fromJson(maps[0]);
  }

  Future<void> insertSession(Session session) async {
    Database db = await instance.database;
    await db.insert(
      sessionsTable,
      session.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Message>> fetchChatMessages(String chatId) async {
    Database db = await instance.database;
    List<Map<String, Object?>> maps = await db.query(
      messagesTable,
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at DESC',
    );

    print("Messages: $maps");

    return List.generate(maps.length, (i) {
      return Message.fromJson(maps[i]);
    });
  }

  Future<void> insertPreKey(KeyPair preKey) async {
    Database db = await instance.database;
    final json = await preKey.toJson();

    await db.insert(
      preKeysTable,
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPreKeys(List<KeyPair> preKeys) async {
    for (KeyPair preKey in preKeys) {
      await insertPreKey(preKey);
    }
  }

  Future<void> deleteAllPreKeys() async {
    Database db = await instance.database;
    await db.delete(preKeysTable);
  }

  Future<Map<String, dynamic>?> getPreKeyDataByIdentifier(
    String identifier,
  ) async {
    Database db = await instance.database;
    List<Map<String, Object?>> maps = await db.query(
      preKeysTable,
      where: 'identifier = ?',
      whereArgs: [identifier],
    );

    if (maps.isEmpty) return null;

    return maps[0];
  }

  Future<List<Contact>> getContacts() async {
    Database db = await instance.database;
    List<Map<String, Object?>> maps = await db.query(contactsTable);
    return List.generate(maps.length, (i) => Contact.fromJson(maps[i]));
  }

  Future<void> updateMessage(Message message) async {
    Database db = await instance.database;
    await db.update(
      messagesTable,
      message.toJson(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<void> updateContact(Contact contact) async {
    Database db = await instance.database;
    await db.update(
      contactsTable,
      contact.toJson(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<List<Chat>> fetchChats() async {
    Database db = await instance.database;

    List<Map<String, Object?>> results = await db.query(chatsTable);
    List<Map<String, dynamic>> mutableResults = [];

    for (Map<String, dynamic> result in results) {
      final membersIdStr = result['members_id'] as String;
      print("Members ID Str: $membersIdStr");
      final membersId = List<String>.from(jsonDecode(membersIdStr));
      print("Members ID: ${membersId[0]}");
      if (membersId.isEmpty) continue;

      // Create a new mutable map with all the original data plus messages
      Map<String, dynamic> mutableResult = Map<String, dynamic>.from(result);
      mutableResults.add(mutableResult);
    }

    return mutableResults.map((result) => Chat.fromJson(result)).toList();
  }
}
