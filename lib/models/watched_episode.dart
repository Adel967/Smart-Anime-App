
final String tableWatchedEpisode = 'watchedEpisode';


class WatchedEpisodeField {
  static final List<String> values = [
    /// Add all fields
    id,name,time,num,sent
  ];

  static final String id = 'id';
  static final String name = 'name';
  static final String time = 'time';
  static final String num = 'num';

  static final String sent = 'sent'; //sent to server?

}


class WatchedEpisode {
  final String name;

  final int num;
  final int time;
  final int sent;

  WatchedEpisode({required this.name,required this.num,required this.time,this.sent = 0});

  factory WatchedEpisode.fromJson(Map<String, dynamic> json) => WatchedEpisode(
    name: json[WatchedEpisodeField.name] as String,
    num: json[WatchedEpisodeField.num] as int,
    time: json[WatchedEpisodeField.time] as int,
    sent: json[WatchedEpisodeField.sent] as int,


  );

  Map<String, Object?> toJson() => {
    WatchedEpisodeField.name: name ,
    WatchedEpisodeField.num: num,
    WatchedEpisodeField.time: time,
    WatchedEpisodeField.sent: sent,


  };


}