import 'dart:convert';

List<Anime> contentFromJson(String str) => List<Anime>.from(json.decode(str).map((x) => Anime.fromJson(x)));
List<Anime> contentFromJsonList(dynamic str) => List<Anime>.from(str.map((x) => Anime.fromJsonList(x)));
List<Anime> contentFromJsonComing(String str) => List<Anime>.from(json.decode(str).map((x) => Anime.fromJsonComing(x)));
List<Anime> contentFromJson1(String str) => List<Anime>.from(json.decode(str).map((x) => Anime.fromJson1(x)));
List<Anime> myListFromJson(String str) => List<Anime>.from(json.decode(str).map((x) => Anime.myListFromJson(x)));
Anime animeFromJson(String str) => json.decode(str).map((x) => Anime.fromJson(x));

final String tableHomeAnime = 'homeAnime';
final String tableListAnime = 'listAnime';


class HomeAnimeField {
  static final List<String> values = [
    /// Add all fields
    main,trending,myList
  ];

  static final String main = 'main';
  static final String trending = 'trending';
  static final String myList = 'myList';
}

final String tableAnime = 'anime';

class AnimeField {
  static final List<String> values = [
    /// Add all fields
    id,name,imageUrl,titleUrl,description,episodesNum,evaluation,kind,released,country
  ];

  static final String id = 'id';
  static final String name = 'name';
  static final String imageUrl = 'imageUrl';
  static final String titleUrl = 'titleUrl';
  static final String description = 'description';
  static final String episodesNum = 'episodesNum';
  static final String evaluation = 'evaluation';
  static final String kind = 'kind';
  static final String released = 'released';
  static final String country = 'country';
}



class Anime {
   Anime({
    this.name='',
    this.imageUrl='',
    this.titleUrl='',
    this.description='',
    this.episodesNum='',
    this.evaluation='',
    this.kind='',
    this.released='',
    this.country='',
    this.main = '0',
    this.trending = '0',
    this.myList = '0',

  });

   String name;
   String imageUrl;
   String titleUrl;
   String description;
   String episodesNum;
   String evaluation;
   String kind;
   String released;
   String country;
   String main;
   String trending;
   String myList;


  Anime.clone(Anime anime)
   : this.name = anime.name,
     this.imageUrl = anime.imageUrl,
     this.titleUrl = anime.titleUrl,
     this.description = anime.description,
     this.evaluation = anime.evaluation,
     this.kind = anime.kind,
     this.released = anime.released,
     this.episodesNum = anime.episodesNum,
     this.main = anime.main,
     this.trending = anime.trending,
     this.myList = anime.myList,
     this.country = anime.country;


  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
    name: json["name"],
    imageUrl: json["imageUrl"],
    titleUrl: json["titleUrl"] ?? "",
    description: json["description"],
    episodesNum: json["episodes"],
    evaluation: json["evaluation"],
    kind: json["kind"],
    released: json["released"],
    country: json["country"],
    main: json["main_anime"],
    trending: json["trending"]
  );

   factory Anime.fromJsonList(Map<String, dynamic> json) => Anime(
       name: json["name"],
       imageUrl: json["imageUrl"],
       titleUrl: json["titleUrl"] ?? "",
       description: json["description"],
       episodesNum: json["episodes"],
       evaluation: json["evaluation"],
       kind: json["kind"],
       released: json["released"],
       country: json["country"],
   );

   factory Anime.fromJsonComing(Map<String, dynamic> json) => Anime(
       name: json["name"],
       imageUrl: json["imageUrl"],
       description: json["description"],
       released: json["released"],
       country: json["country"],

   );

  factory Anime.myListFromJson(Map<String, dynamic> json) => Anime(
      name: json["name"],
      imageUrl: json["imageUrl"],
      titleUrl: json["titleUrl"],
      description: json["description"],
      episodesNum: json["episodes"],
      evaluation: json["evaluation"],
      kind: json["kind"],
      released: json["released"],
      country: json["country"],
      myList: '1',
      trending: '3'
  );

  static Anime fromJson1(Map<String, Object?> json) => Anime(
    name: json[AnimeField.name] as String,
    imageUrl: json[AnimeField.imageUrl] as String,
    titleUrl: json[AnimeField.titleUrl] as String,
    description: json[AnimeField.description] as String,
    episodesNum: json[AnimeField.episodesNum] as String,
    evaluation: json[AnimeField.evaluation] as String,
    kind: json[AnimeField.kind] as String,
    released: json[AnimeField.released] as String,
    country: json[AnimeField.country] as String,
  );

  Map<String, Object?> toJson() => {
    AnimeField.name: name,
    AnimeField.imageUrl: imageUrl,
    AnimeField.titleUrl: titleUrl,
    AnimeField.description: description,
    AnimeField.episodesNum: episodesNum,
    AnimeField.evaluation: evaluation,
    AnimeField.kind: kind,
    AnimeField.released: released,
    AnimeField.country: country,

  };

  static Anime fromJson2(Map<String, Object?> json) => Anime(
    name: json[AnimeField.name] as String,
    imageUrl: json[AnimeField.imageUrl] as String,
    titleUrl: json[AnimeField.titleUrl] as String,
    description: json[AnimeField.description] as String,
    episodesNum: json[AnimeField.episodesNum] as String,
    evaluation: json[AnimeField.evaluation] as String,
    kind: json[AnimeField.kind] as String,
    released: json[AnimeField.released] as String,
    country: json[AnimeField.country] as String,
    main: json[HomeAnimeField.main] as String,
    trending: json[HomeAnimeField.trending] as String,
    myList: json[HomeAnimeField.myList] as String,
  );

  Map<String, Object?> toJson2() => {
    AnimeField.name: name,
    AnimeField.imageUrl: imageUrl,
    AnimeField.titleUrl: titleUrl,
    AnimeField.description: description,
    AnimeField.episodesNum: episodesNum,
    AnimeField.evaluation: evaluation,
    AnimeField.kind: kind,
    AnimeField.released: released,
    AnimeField.country: country,
    HomeAnimeField.main: main,
    HomeAnimeField.trending: trending,
    HomeAnimeField.myList: myList,
  };

   Map<String, Object?> toMap() => {
     AnimeField.name: name,
     AnimeField.imageUrl: imageUrl,
     AnimeField.titleUrl: titleUrl,
     AnimeField.description: description,
     AnimeField.episodesNum: episodesNum,
     AnimeField.evaluation: evaluation,
     AnimeField.kind: kind,
     AnimeField.released: released,
     AnimeField.country: country,
   };

}
