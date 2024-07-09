final String tableWatchedAnime = 'watchedAnime';

class WatchedAnimeField {
  static final List<String> values = [
    id,name,kind,sent
  ];
  static final String id = 'id';
  static final String name = 'name';
  static final String kind = 'kind';
  static final String sent = 'sent';
}

class WatchedAnime {
  final String name;
  final String kind;
   String sent;

  WatchedAnime({required this.name,required this.kind,required this.sent});

  factory WatchedAnime.fromJson(Map<String, dynamic> json) => WatchedAnime(
    name: json[WatchedAnimeField.name] as String,
    kind: json[WatchedAnimeField.kind] as String,
    sent: json[WatchedAnimeField.sent] as String,
  );

  Map<String, Object?> toJson() => {
    WatchedAnimeField.name: name,
    WatchedAnimeField.kind: kind,
    WatchedAnimeField.sent: sent,
  };
}