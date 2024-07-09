import 'package:netflixbro/models/duration_rule.dart';
import 'package:netflixbro/models/watched_anime.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:netflixbro/models/models.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class SQLiteHelper {
  static final SQLiteHelper instance = SQLiteHelper._init();

  static Database? _database;

  SQLiteHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('netflixbro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final varcharType = 'varchar(100) NOT NULL';
    final intType = 'INTEGER NOT NULL';


    await db.execute('''CREATE TABLE $tableUser (${UserFields.id} $idType,${UserFields.email} $textType,${UserFields.time} $textType)''');
    await db.execute('''CREATE TABLE $tableWatchedEpisode (${WatchedEpisodeField.id} $idType,${WatchedEpisodeField.name} $textType,${WatchedEpisodeField.time} $intType,${WatchedEpisodeField.num} $intType,${WatchedEpisodeField.sent} $intType)''');
    await db.execute('''CREATE TABLE $tableHomeAnime (${AnimeField.id} $idType,${AnimeField.name} $varcharType,${AnimeField.imageUrl} $textType,${AnimeField.titleUrl} $textType,${AnimeField.description} $textType,${AnimeField.episodesNum} $textType,${AnimeField.evaluation} $textType,${AnimeField.kind} $textType,${AnimeField.released} $textType,${AnimeField.country} $textType,${HomeAnimeField.main} $textType,${HomeAnimeField.trending} $textType,${HomeAnimeField.myList} $textType)''');
    await db.execute('''CREATE TABLE $tableAnime (${AnimeField.id} $idType,${AnimeField.name} $varcharType,${AnimeField.imageUrl} $textType,${AnimeField.titleUrl} $textType,${AnimeField.description} $textType,${AnimeField.episodesNum} $textType,${AnimeField.evaluation} $textType,${AnimeField.kind} $textType,${AnimeField.released} $textType,${AnimeField.country} $textType)''');
    await db.execute('''CREATE TABLE $tableListAnime (${AnimeField.id} $idType,${AnimeField.name} $varcharType,${AnimeField.imageUrl} $textType,${AnimeField.titleUrl} $textType,${AnimeField.description} $textType,${AnimeField.episodesNum} $textType,${AnimeField.evaluation} $textType,${AnimeField.kind} $textType,${AnimeField.released} $textType,${AnimeField.country} $textType)''');
    await db.execute('''CREATE TABLE switchTable (id $idType,darkMood INTEGER ,storage INTEGER )''');
    await db.execute('''CREATE TABLE trackingTable (id $idType,date varchar(20),firstOpen varchar(20),lastOpen varchar(20),period Integer,episodeNum Integer )''');
    await db.execute('''CREATE TABLE $tableWatchedAnime (${WatchedAnimeField.id} $idType,${WatchedAnimeField.name} $textType,${WatchedAnimeField.kind} $textType,${WatchedAnimeField.sent} varchar(1))''');
    await db.execute('''CREATE TABLE parentalControl (id $idType,password varchar(20),openTime varchar(10),closeTime varchar(10),blockedCategories Text,blockedDays varchar(20))''');
    await db.execute('''CREATE TABLE blockedAnime (id $idType,title $varcharType)''');
    await db.execute('''CREATE TABLE blockedDays (id $idType,blockedDay varchar(10))''');
    await db.execute('''CREATE TABLE ruleDay (id $idType,weekDay varchar(2),duration varchar(6),episodeCount varchar(3),active varchar(1))''');
    await db.execute('''CREATE TABLE allowedDays (id $idType,allowedDay varchar(10))''');
  }

  Future<bool> insertUser(User user) async {
    final db = await instance.database;
    final id = await db.insert(tableUser, user.toJson());
    return id.toString().isNotEmpty ? true : false;
  }

  Future<bool> insertSwitch(bool themeValue,bool storageValue) async {
    final db = await instance.database;

    List<bool> list = await readSwitch();
    if(list.isEmpty){
      final res = await db.insert('switchTable', {'darkMood': themeValue ? 1.toString() : 0.toString(),'storage': storageValue ? 1.toString() : 0.toString()});
      return res.toString().isNotEmpty ? true : false;
    }
    return false;

  }

  Future<List<bool>> readSwitch() async {
    final db = await instance.database;

    final maps = await db.query(
      'switchTable',
      columns: ['darkMood','storage'],
      where: 'id = ?',
      whereArgs: ['1'],
    );

    if (maps.isNotEmpty) {
      bool bool1 = (maps.first['darkMood'] as int) == 1 ? true : false;
      bool bool2 = (maps.first['storage'] as int) == 1 ? true : false;
      return [bool1,bool2];
    } else {
      return [];
    }

  }





  Future<int> updateTheme(bool themeValue ) async {
    final db = await instance.database;

    return db.update(
      'switchTable',
      {'darkMood': themeValue ? 1.toString() : 0.toString()},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<int> updateStorage(bool storageValue ) async {
    final db = await instance.database;

    return db.update(
      'switchTable',
      {'storage': storageValue ? 1.toString() : 0.toString()},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<bool> insertRule(DurationRule rule) async {
    final db = await instance.database;


    final res = await db.insert('ruleDay', {'weekDay': rule.weekDay,'duration':rule.durationUsage,'episodeCount':rule.epNum,'active':rule.active ? "1" : "0"});
    return res.toString().isNotEmpty ? true : false;

  }

  Future<List<DurationRule>> readRule() async {
    final db = await instance.database;

    final res =  await db.query(
      'ruleDay',
      orderBy: 'weekDay'
    );
    List<DurationRule> list = res.map((e) => DurationRule(e["weekDay"].toString(), e["duration"].toString(), e["episodeCount"].toString(), e["active"].toString() == "1" ? true : false)).toList();
    return list;
  }

  Future<int> removeRule(String  date) async {
    final db = await instance.database;

    return await db.delete(
      'ruleDay',
      where: 'weekDay = ?',
      whereArgs: [date],
    );
  }

  Future<bool> updateRule(DurationRule rule) async {
    final db = await instance.database;


    final res = await db.update(
      'ruleDay',
      {'weekDay': rule.weekDay,'duration':rule.durationUsage,'episodeCount':rule.epNum,'active':rule.active ? "1" : "0"},
      where: 'weekDay = ?',
      whereArgs: [rule.weekDay]
    );
    return res.toString().isNotEmpty ? true : false;

  }

  Future<int> updateParentalControlPassword(String password) async {
    final db = await instance.database;


    return await db.update(
        'parentalControl',
        {'password': password.trim(),},
        where: 'id = ?',
        whereArgs: ['1']
    );

  }

  Future<bool> insertParentalControl(String password) async {
    final db = await instance.database;

    final m = await readParentalControl();
    if(m["password"].isEmpty){
      final res = await db.insert('parentalControl', {'password': password});
      return res.toString().isNotEmpty ? true : false;
    }
    return false;

  }

  Future<Map<String,dynamic>> readParentalControl() async {
    final db = await instance.database;

    final map = await db.query(
      'parentalControl',

    );
    print(map);

    if (map.isNotEmpty) {
      final m = map.first;
      return m;
    } else {
      final v = {
        "password":""
      };
      return v;
    }

  }

  Future<int> setOpeningTime(String t) async {
    final db = await instance.database;

    return db.update(
      'parentalControl',
      {'openTime': t},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<int> setClosingTime(String t) async {
    final db = await instance.database;

    return db.update(
      'parentalControl',
      {'closeTime': t},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<int> setBlockedCategories(String t) async {
    final db = await instance.database;

    return db.update(
      'parentalControl',
      {'blockedCategories': t},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<int> setBlockedDays(String t) async {
    final db = await instance.database;

    return db.update(
      'parentalControl',
      {'blockedDays': t},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<int> setDuration(String t) async {
    final db = await instance.database;

    return db.update(
      'parentalControl',
      {'duration': t},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<int> setEpisodesCount(String t) async {
    final db = await instance.database;

    return db.update(
      'parentalControl',
      {'episodesCount': t},
      where: 'id = ?',
      whereArgs: ['1'],
    );
  }

  Future<bool> insertBlockedAnime(String title) async {
    final db = await instance.database;
    List<String> blockedAimes = [];
    blockedAimes = List.from(await readBlockedAnime());
    if(!blockedAimes.contains(title)){
      final res = await db.insert('blockedAnime', {'title': title});
      return res.toString().isNotEmpty ? true : false;
    }else{
      return false;
    }
  }

  Future<List<String>> readBlockedAnime() async {
    final db = await instance.database;

    final res =  await db.query(
      'blockedAnime',
    );
    List<String> list = res.map((e) => e["title"].toString()).toList();
    return list;

  }

  Future<int> unBlockAnime(String  title) async {
    final db = await instance.database;

    return await db.delete(
      'blockedAnime',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Future<int> updateBlockedAnime(String t) async {
  //   final db = await instance.database;
  //
  //   return db.update(
  //     'blockedAnime',
  //     {'title': t},
  //     where: 'id = ?',
  //     whereArgs: ['1'],
  //   );
  // }

  Future<bool> insertBlockedDays(String date) async {
    final db = await instance.database;

    final res = await db.insert('blockedDays', {'blockedDay': date});
    return res.toString().isNotEmpty ? true : false;
  }

  Future<List<String>> readBlockedDays() async {
    final db = await instance.database;
    final res = await db.query(
      'blockedDays',
    );
    List<String> list = res.map((e) => e["blockedDay"].toString()).toList();
    return list;
  }

  Future<bool> checkBlockDay(String date) async{
    final db = await instance.database;
    final res = await db.query(
      'blockedDays',
      where: 'blockedDay = ?',
      whereArgs: [date],
    );
    return res.isNotEmpty ? true : false;
  }

  Future<int> unBlockDate(String  date) async {
    final db = await instance.database;

    return await db.delete(
      'blockedDays',
      where: 'blockedDay = ?',
      whereArgs: [date],
    );
  }

  Future<int> deleteBlockedDays(List<String>  dates) async {
    final db = await instance.database;

    return await db.delete(
      'blockedDays',
      where: 'blockedDay IN (${List.filled(dates.length, '?').join(',')})',
      whereArgs: dates,
    );
  }

  // Future<int> updateBlockedDays(String t) async {
  //   final db = await instance.database;
  //
  //   return db.update(
  //     'blockedDays',
  //     {'title': t},
  //     where: 'id = ?',
  //     whereArgs: ['1'],
  //   );
  // }

  Future<bool> insertAllowedDays(String day) async {
    final db = await instance.database;

    final res = await db.insert('allowedDays', {'allowedDay': day});
    return res.toString().isNotEmpty ? true : false;
  }

  Future<List<String>> readAllowedDays() async {
    final db = await instance.database;
    final res = await db.query(
      'allowedDays',
    );
    List<String> list = res.map((e) => e["allowedDay"].toString()).toList();
    return list;
  }

  Future<bool> checkAllowDay(String date)async{
    final db = await instance.database;
    final res = await db.query(
      'allowedDays',
      where: 'allowedDay = ?',
      whereArgs: [date]
    );
    return res.isNotEmpty ? true : false;
  }

  Future<int> deleteAllowedDay(List<String>  dates) async {
    final db = await instance.database;

    return await db.delete(
      'allowedDays',
      where: 'allowedDay IN (${List.filled(dates.length, '?').join(',')})',
      whereArgs: dates,
    );
  }

  Future<User> readUSer(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableUser,
      columns: UserFields.values,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }



  Future<List<User>> readAllUsers() async {
    final db = await instance.database;

    final orderBy = '${UserFields.time} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableUser, orderBy: orderBy);

    return result.map((json) => User.fromJson(json)).toList();
  }

  Future<int> update(String newEmail,String oldEmail) async {
    final db = await instance.database;

    return db.rawUpdate('''
    UPDATE $tableUser 
    SET email = ?
    WHERE email = ?
    ''',
        [newEmail,oldEmail]);
  }

  Future clearTableUser() async {
    final db = await instance.database;

    await db.rawQuery('DELETE FROM $tableUser');
  }


  Future<bool> insertWatchedEpisode(WatchedEpisode watchedAnime) async {
    final db = await instance.database;

    final id = await db.insert(tableWatchedEpisode, watchedAnime.toJson());
    return id.toString().isNotEmpty ? true : false;
  }

  Future<WatchedEpisode> readWatchedEpisode(String name,String num) async {
    final db = await instance.database;

    final maps = await db.query(
      tableWatchedEpisode,
      columns: WatchedEpisodeField.values,
      where: '${WatchedEpisodeField.name} = ? and ${WatchedEpisodeField.num} = ?',
      whereArgs: [name,num],
    );

    if (maps.isNotEmpty) {
      return WatchedEpisode.fromJson(maps.first);
    } else {
      return WatchedEpisode(name: "", num: 0, time: 0);
    }
  }

  Future<List<WatchedEpisode>> readAllWatchedEpisode() async {
    final db = await instance.database;

    final orderBy = '${UserFields.time} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableWatchedEpisode, orderBy: orderBy,where: '${WatchedEpisodeField.time} = ?',whereArgs: ["5"]);

    return result.map((json) => WatchedEpisode.fromJson(json)).toList();
  }

  Future<int> updateWatchedEpisode(String name,String num) async {
    final db = await instance.database;

    final res = await readWatchedEpisode(name, num);
    WatchedEpisode anime = res;
    if(anime.time != 5){
      await db.rawUpdate("Update $tableWatchedEpisode SET ${WatchedEpisodeField.time} = ${WatchedEpisodeField.time} + 1 Where ${WatchedEpisodeField.name} LIKE '$name' AND ${WatchedEpisodeField.num} = $num");
    }
    print("time" + res.time.toString());
    return anime.time + 1 >= 5 ? 1 : 0;


  }

  Future<bool> insertWatchedAnime(WatchedAnime watchedAnime) async {
    final db = await instance.database;
    print("..........................//////////////////////");
    final id = await db.insert(tableWatchedAnime, watchedAnime.toJson());
    return id.toString().isNotEmpty ? true : false;
  }

  Future<WatchedAnime> readWatchedAnime(String name) async {
    final db = await instance.database;

    final maps = await db.query(
      tableWatchedAnime,
      columns: WatchedAnimeField.values,
      where: '${WatchedAnimeField.name} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return WatchedAnime.fromJson(maps.first);
    } else {
      return WatchedAnime(name: "", kind: "",sent: "");
    }
  }

  Future<List<WatchedAnime>> readUnSentWatchedAnime() async {
    final db = await instance.database;

    final maps = await db.query(
      tableWatchedAnime,
      columns: WatchedAnimeField.values,
      where: '${WatchedAnimeField.sent} = ?',
      whereArgs: ["0"],
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => WatchedAnime.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<WatchedAnime>> readAllWatchedAnime() async {
    final db = await instance.database;


    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.rawQuery("SELECT * FROM ${tableWatchedAnime}");

    return result.map((json) => WatchedAnime.fromJson(json)).toList();
  }

  Future<int> updateWatchedAnime(WatchedAnime watchedAnime) async {
    final db = await instance.database;

    return db.update(
      tableWatchedAnime,
      watchedAnime.toJson(),
      where: '${WatchedAnimeField.name} = ?',
      whereArgs: [watchedAnime.name],
    );

  }


  // Future<int> delete(int id) async {
  //   final db = await instance.database;
  //
  //   return await db.delete(
  //     tableUser,
  //     where: '${UserFields.id} = ?',
  //     whereArgs: [id],
  //   );
  // }



  Future<bool> insertHomeAnime(List<Anime> animes) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');
    await db.delete(tableHomeAnime);
    Batch batch = db.batch();
    animes.forEach((element) {
      batch.insert(tableHomeAnime,element.toJson2());
    });

    final res =  await batch.commit();
    //final id = await db.insert(tableHomeAnime, anime.toJson2());
    print(res.toString());
    return res.isNotEmpty ? true : false;
  }

  Future<List<Anime>> readAllHomeAnimes() async {
    final db = await instance.database;

    final orderBy = '${AnimeField.id} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableHomeAnime, orderBy: orderBy);

    return result.map((json) => Anime.fromJson2(json)).toList();
  }

  Future<int> updateHomeAnime(Anime anime) async {
    final db = await instance.database;

    return db.update(
      tableHomeAnime,
      anime.toJson(),
      where: '${AnimeField.name} = ?',
      whereArgs: [anime.name],
    );
  }

  Future<int> deleteHomeAnime(String  name) async {
    final db = await instance.database;

    return await db.delete(
      tableHomeAnime,
      where: '${AnimeField.name} = ?',
      whereArgs: [name],
    );
  }



  Future<bool> insertAnimeToList(Anime anime) async {
    final db = await instance.database;



    final res =  await db.insert(tableListAnime, anime.toMap());


    //final id = await db.insert(tableHomeAnime, anime.toJson2());
    return res.toString().isNotEmpty ? true : false;
  }

  Future<bool> insertListAnime(List<Anime> animes) async {
    final db = await instance.database;
    print(animes.length);
    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final res = await readListAnime();
      List<String> f = [];
      List<String> s  = [];
      animes.forEach((element) { f.add(element.name);});
      res.forEach((element) { s.add(element.name);});
      f.sort();
      s.sort();

      if(IterableEquality().equals(s,f)){
        print(IterableEquality().equals(s,f));
        print(f.length + s.length);
        print("Done");
          return true;
      }else{
        await db.delete(tableListAnime);
        Batch batch = db.batch();
        animes.forEach((element) {
          batch.insert(tableListAnime,element.toMap());
        });

        final res1 =  await batch.commit();
        //final id = await db.insert(tableHomeAnime, anime.toJson2());
        print(res1.toString());
        print("Done1");

        return res1.isNotEmpty ? true : false;
      }


  }

  Future<List<Anime>> readListAnime() async {
    final db = await instance.database;

    final orderBy = '${AnimeField.id} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableListAnime, orderBy: orderBy);

    return result.map((json) => Anime.fromJson1(json)).toList();
  }

  Future<int> deleteListAnime(String  name) async {
    final db = await instance.database;

    return await db.delete(
      tableListAnime,
      where: '${AnimeField.name} = ? ',
      whereArgs: [name],
    );
  }

  Future<bool> insertAnime(List<Anime> animes) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');
    Batch batch = db.batch();
    animes.forEach((element) {
      batch.insert(tableAnime, element.toJson());
    });
    final res =  await batch.commit();
    //final id = await db.insert(tableHomeAnime, anime.toJson2());
    return res.isNotEmpty ? true : false;
  }



  Future<List<Anime>> readAllAnimesForSearch(String kind,int index,String search) async {
    final db = await instance.database;

    final orderBy = '${AnimeField.id} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    if(kind == "All"){
      final result = await db.rawQuery("SELECT * from $tableAnime where name like '%$search%' LIMIT $index , 10");
      return result.map((json) => Anime.fromJson1(json)).toList();
    }else{
      final result = await db.rawQuery("SELECT * from $tableAnime where name like '%$search%' and kind like '%$kind%' LIMIT $index , 10");
      return result.map((json) => Anime.fromJson1(json)).toList();
    }

  }

  Future<int> readCountOfAnime() async {
    final db = await instance.database;

    final orderBy = '${AnimeField.id} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    int? result =  Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableAnime'));

    if(result != null){
      return result;
    }
    return 0 ;
  }

  Future<int> updateAnime(Anime anime) async {
    final db = await instance.database;

    return db.update(
      tableAnime,
      anime.toJson(),
      where: '${AnimeField.name} = ?',
      whereArgs: [anime.name],
    );
  }

  Future clearAnimeTable() async {
    final db = await instance.database;

    await db.rawQuery('DELETE FROM $tableAnime');

  }

  void insertInTrackingTable() async {
    final db = await instance.database;

    final now = DateTime.now();
    final date  = now.toString().replaceRange(10, null, "");
    final timeStamp  = now.toString().replaceRange(0, 11, "");
    print(date);
    print("date"+(await readFromTrackingTable(date))["date"]);
    print(DateFormat('MMMM').format(now).substring(0,3));
    if((await readFromTrackingTable(date))["date"].isEmpty){
      print("..............,,,,,,,,,,,,,,,,...........");
      await db.insert("trackingTable", {
        "date" : date ,
        "firstOpen" : timeStamp,
        "lastOpen" : timeStamp,
        "period" : 1,
        "episodeNum" : 0
      });
    }else{
      updateLastOpen();
    }
  }

  Future<void> insertInTrackingTable2(List<List<dynamic>> list) async {
    final db = await instance.database;

      if((await readFromTrackingTable1()) > 300){
        return;
      }

      Batch batch = db.batch();
      list.forEach((element) {
        batch.insert("trackingTable", {
          "date" : element[0] ,
          "firstOpen" : element[1],
          "lastOpen" : element[2],
          "period" : element[3].toString(),
          "episodeNum" : element[4].toString()
        });
      });

      await batch.commit();
      print("Done...............................");

  }


  Future<void> insertInTrackingTable1(String date,String fOpen,String lOpen,int period,int epNum) async {
    final db = await instance.database;


    if((await readFromTrackingTable(date))["date"].isEmpty){
      await db.insert("trackingTable", {
        "date" : date ,
        "firstOpen" : fOpen,
        "lastOpen" : lOpen,
        "period" : period,
        "episodeNum" : epNum
      });
    }else{
      updateLastOpen();
    }
  }

  Future<int> updateLastOpen() async {
    final db = await instance.database;
    final now = DateTime.now();
    final date  = now.toString().replaceRange(10, null, "");
    final timeStamp  = now.toString().replaceRange(0, 11, "");
    return db.update(
      "trackingTable",
      {"lastOpen" : timeStamp},
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<void> updatePeriod() async {
    final db = await instance.database;
    final now = DateTime.now();
    final date  = now.toString().replaceRange(10, null, "");
    await db.rawUpdate("Update trackingTable SET period = period + 1 Where date LIKE '$date' ");

  }

  void updateEpisodeNum() async {
    final db = await instance.database;
    final now = DateTime.now();
    final date  = now.toString().replaceRange(10, null, "");
    await db.rawUpdate("Update trackingTable SET episodeNum = episodeNum + 1 Where date LIKE '$date' ");

  }

  Future<Map<String,dynamic>> readFromTrackingTable(String date) async {
    final db = await instance.database;

    final result = await db.rawQuery("SELECT * from trackingTable where date LIKE '$date'");
    print(result);
    return result.isNotEmpty ? result.first : {
      "date":""
    };
  }

  Future<int> readFromTrackingTable1() async {
    final db = await instance.database;

    final result = await db.rawQuery("SELECT * FROM trackingTable ");
    print(result.toString());
    return result.length;
  }

  Future<bool> checkMonthlyInfo() async {
    final db = await instance.database;
    final now = DateTime.now();
    int month = now.month;

    final result = await db.rawQuery("SELECT * from trackingTable where date NOT LIKE '%-${month}-%'");
    if(result.isNotEmpty)
      return true;
    return false;
  }

  Future<bool> checkYearlyInfo() async {
    final db = await instance.database;
    final now = DateTime.now();
    int year = now.year;

    final result = await db.rawQuery("SELECT * from trackingTable where date NOT LIKE '${year}-%'");
    if(result.isNotEmpty)
      return true;
    return false;
  }

  Future<List<String>> checkYearsInfoAvailability(int year) async {
    final db = await instance.database;
    List<String> list  = [];
    list.add(year.toString());
    for(int i = 1;i<10;i++){
      final result = await db.rawQuery("SELECT *  from trackingTable where date LIKE '${year-i}-%'");
      print("Result" + i.toString());
      print(result);
      if(result.isNotEmpty)
        list.add((year - i).toString());
    }
    print(list);
    return list;
  }

  Future<Map<String,int>> getMonthData(int year,int month) async{
    final db = await instance.database;
    String month1 = month.toString();
    if(month < 10)
      month1 = "0"+month.toString();

    final result = await db.rawQuery("SELECT * from trackingTable where date  LIKE '${year}-${month1}-%'");
    double hours = 0;
    int episodes = 0;
    result.forEach((element) {
      hours += (element["period"] as int)/60;
      episodes += element["episodeNum"] as int;
    });

    return ({
      "period":hours.round(),
      "episodeNum":episodes
    });
  }

  Future<List<Map<String,dynamic>>> readLast7RowsFromTrackingTable(int rowsNum) async {
    final db = await instance.database;
    List<Map<String,dynamic>> list = [];
    final result = await db.rawQuery("SELECT * FROM trackingTable ORDER BY id DESC LIMIT $rowsNum , 7");
    print(result.toString());
    result.forEach((element) {
      list.add({
        "date":element["date"],
        "firstOpen":element["firstOpen"],
        "lastOpen":element["lastOpen"],
        "period":element["period"],
        "episodeNum":element["episodeNum"],
      });
    });

    return list;
  }

  Future clearTrackingTable() async {
    final db = await instance.database;

    await db.rawQuery('DELETE FROM trackingTable');

  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}