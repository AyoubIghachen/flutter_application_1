import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/models/Construction.dart';
import 'package:flutter_application_1/models/User.dart';
import 'package:flutter_application_1/models/Point.dart';

import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection, ObjectId;

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Db? _db;
  static DbCollection? _userCollection;
  static DbCollection? _constructionCollection;
  static DbCollection? _pointCollection;

  Future<DbCollection> get userCollection async =>
      _userCollection ??= _db!.collection('users');

  Future<DbCollection> get constructionCollection async =>
      _constructionCollection ??= _db!.collection('constructions');

  Future<DbCollection> get pointCollection async =>
      _pointCollection ??= _db!.collection('points');

  Future<void> initDatabase() async {
    _db = await Db.create(dotenv.env['MONGODB_CONNECTION_STRING']!);
    await _db!.open();
  }

  // Authentification
  Future<User?> authenticate(String username, String password) async {
    final collection = await instance.userCollection;
    final userMap = await collection.findOne({
      'username': username,
      'password': password,
    });
    return userMap != null ? User.fromMap(userMap) : null;
  }

  // CRUD for Users
  Future<void> createUserOnline(User user) async {
    final collection = await instance.userCollection;
    collection.insert(user.toMap());
  }

  Future<List<User>> readUsersOnline() async {
    final collection = await instance.userCollection;
    final maps = await collection.find().toList();
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<void> updateUserOnline(String id, User updatedUser) async {
    final collection = await instance.userCollection;
    collection.update({'_id': id}, updatedUser.toMap());
  }

  Future<void> deleteUserOnline(String id) async {
    final collection = await instance.userCollection;
    collection.remove({'_id': id});
  }

  Future<List<User>> getAgents() async {
    final collection = await instance.userCollection;
    final maps = await collection.find({'role': 'agent'}).toList();
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // CRUD for Constructions

  Future<void> createConstructionOnline(Construction construction) async {
    final collection = await instance.constructionCollection;
    await collection.insert(construction.toMap());
  }

  Future<List<Construction>> readConstructionsOnline() async {
    final collection = await instance.constructionCollection;
    final maps = await collection.find().toList();
    return maps.map((map) => Construction.fromMap(map)).toList();
  }

  Future<void> updateConstructionOnline(
      String id, Construction updatedConstruction) async {
    final collection = await instance.constructionCollection;
    collection.update({'_id': id}, updatedConstruction.toMap());
  }

  Future<void> deleteConstructionOnline(String id) async {
    final collection = await instance.constructionCollection;
    collection.remove({'_id': id});
  }

  Future<String> getConstructionIdByPointId(String idPoint) async {
    final collection = await instance.constructionCollection;
    final map = await collection.findOne({'idPoint': idPoint});
    if (map != null) {
      final construction = Construction.fromMap(map);
      if (construction.id != null) {
        return construction.id!;
      } else {
        throw Exception('Construction ID is null for point id: $idPoint');
      }
    } else {
      throw Exception('Construction not found for point id: $idPoint');
    }
  }

  Future<List<Construction>> readConstructionsOnlineByAgentId(
      String agentId) async {
    final collection = await instance.constructionCollection;
    final maps = await collection.find({'idAgent': agentId}).toList();
    return maps.map((map) => Construction.fromMap(map)).toList();
  }

  // CRUD for Points
  Future<void> createPointOnline(Point point) async {
    final collection = await instance.pointCollection;
    collection.insert(point.toMap());
  }

  Future<List<Point>> readPointsOnline() async {
    final collection = await instance.pointCollection;
    final maps = await collection.find().toList();
    return maps.map((map) => Point.fromMap(map)).toList();
  }

  Future<void> updatePointOnline(String id, Point updatedPoint) async {
    String subId = id.substring(10, 34);
    var nid = ObjectId.fromHexString(subId);
    final collection = await instance.pointCollection;
    var idconstruction = updatedPoint.idConstruction;
    var result = await collection.update({
      '_id': nid
    }, {
      '\$set': {'idConstruction': idconstruction}
    });
    print('Update result: $result');
  }

  Future<void> deletePointOnline(String id) async {
    final collection = await instance.pointCollection;
    collection.remove({'_id': id});
  }

  Future<List<Point>> readPointsOnlineByAgentId(String agentId) async {
    final collection = await instance.pointCollection;
    final maps = await collection.find({'idAgent': agentId}).toList();
    return maps.map((map) => Point.fromMap(map)).toList();
  }

  Future<Point> readPointOnline(String id) async {
    String subId = id.substring(10, 34);
    var nid = ObjectId.fromHexString(subId);
    final collection = await instance.pointCollection;
    final map = await collection.findOne({'_id': nid});
    if (map != null) {
      return Point.fromMap(map);
    } else {
      throw Exception('Point not found');
      // return Point(jsonData: '{}');
    }
  }
}
