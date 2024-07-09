import 'package:http/http.dart' as http;
import 'package:netflixbro/models/content_model.dart';
import 'package:netflixbro/models/episode.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'dart:convert';
import 'dart:io';

class Services{
  static const URL = "https://alkt123.000webhostapp.com/db.php";
  static const URL2 = "https://alkt123.000webhostapp.com/signup.php";
  static const URL3 = "https://alkt123.000webhostapp.com/sendotp.php";
  static const URL4 = "https://alkt123.000webhostapp.com/checkotp.php";
  static const URL5 = "https://alkt123.000webhostapp.com/login.php";
  static const URL6 = "https://alkt123.000webhostapp.com/manageList.php";
  static const URL7 = "https://alkt123.000webhostapp.com/manageEpisode.php";
  static const URL8 = "https://alkt123.000webhostapp.com/getDirectLink.php";
  static const URL9 = "https://alkt123.000webhostapp.com/resetEmail.php";
  static const URL10 = "https://alkt123.000webhostapp.com/resetPassword.php";
  static const URL11 = "https://alkt123.000webhostapp.com/search_manager.php";
  static const URL12 = "https://alkt123.000webhostapp.com/parentalControl.php";
  static const Get_Anime = "Get_Anime";
  static const Get_Anime1 = "Get_Anime1";
  static const Get_Main_Anime = "Get_Main_Anime";
  static const Get_Episodes = "Get_Episode";
  static const Get_Anime_Kind = "Get_Anime_Kind";
  static const Check_Email = "Check_Email";
  static const Check_OTP = "Check_OTP";
  static const Sign_Up = "Sign_Up";
  static const add_To_List = "addToList";
  static const remove_From_List = "removeFromList";
  static const get_List = "Get_List";
  static const watched = "Watched";
  static const Get_Coming_Anime = "Get_Coming_Anime";
  static const verifyInfo = "verifyInfo";
  static const saveInfo = "saveInfo";
  static const getAnimeByName = "Get_Anime_By_Name";
  static const Get_Info = "Get_Info";
  static const Follow_Anime = "Follow_Anime";
  static const Get_Follow_Anime = "Get_Follow_Anime";
  static const Get_Watched = "Get_Watched";


  static Future<List<Anime>> getAnimes() async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Get_Anime;
      map['action1'] =  "";
      map['num'] =  "";
      map['search'] =  "";
      final response = await http.post(Uri.parse(URL),body: map);
      print('Get Employees response is ${response.body}');
      if(response.statusCode == 200){
       // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        List<Anime> list = contentFromJson(response.body);
        print('Get Employees response is ${list.length}');
        return list;
      }else
        return List.empty();
    }catch(ex){
      return List.empty();
    }
  }

  static Future<List<List<Anime>>> getAnimes1() async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Get_Anime1;
      map['action1'] =  "";
      map['num'] =  "10";
      map['search'] =  "";
      final response = await http.post(Uri.parse(URL),body: map);
      print('Get Employees response is ${response.body}');
      print('Get Employees response is ${json.decode(response.body)[1]}');
      if(response.statusCode == 200){
        List<Anime> previews = contentFromJsonList(json.decode(response.body)[0]);
        List<Anime> main_anime = contentFromJsonList(json.decode(response.body)[1]);
        List<Anime> popularity = contentFromJsonList(json.decode(response.body)[2]);
        List<Anime> content_based = contentFromJsonList(json.decode(response.body)[3]);
        List<Anime> content_based_collaboration = contentFromJsonList(json.decode(response.body)[4]);
        List<List<Anime>> animeLists = [previews,main_anime,popularity,content_based,content_based_collaboration];
        return animeLists;
      }else
        return List.empty();
    }catch(ex){
      print(ex);
      return List.empty();
    }
  }

  static Future<List<Anime>> getList() async{
    try{
      print(NavScreen.email);
      var map = Map<String,dynamic>();
      map['action'] =  get_List;
      map['action1'] =  NavScreen.email;
      map['num'] =  "";
      map['search'] =  "";
      final response = await http.post(Uri.parse(URL),body: map);
      print('Get Employees response is ${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        List<Anime> list = myListFromJson(response.body);
        print('Get Employees response is ${list.length}');
        return list;
      }else
        return List.empty();
    }catch(ex){
      return List.empty();
    }
  }




  static Future<List<Episode>> getEpisodes(String name) async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Get_Episodes;
      map['name'] = name;
      map['num'] =  "";
      map['email'] =  "";
      final response = await http.post(Uri.parse(URL7),body: map);
      print('Get Employees response is ${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        List<Episode> list = episodeFromJson(response.body);
        print('Get Employees response is ${list.length}');
        return list;
      }else
        return List.empty();
    }catch(ex){
      return List.empty();
    }
  }

  static Future<Map<String,int>> getInfo(String name) async{
    Map<String,int> ma = {
      "episodes":0
    };


      var map = Map<String,dynamic>();
      map['action'] =  Get_Info;
      map['name'] = name;
      map['num'] =  "";
      map['email'] =  NavScreen.email;
      final response = await http.post(Uri.parse(URL7),body: map);
      print('Get Employees response is ${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        List<Map<String,dynamic>> l = [];
        l = List.from(
            json.decode(response.body).map((x) =>
             {
                "episodes":x['episodes'] == null ? "" : x['episodes'],
                "COUNT(*)":x['COUNT(*)'] == null ? "": x['COUNT(*)'],
              }

              ),
        );
        print(l);
        Map<String,int> m = {
          "episodes": int.parse(l[0]["episodes"]!),
          "watched_episodes": int.parse(l[1]["COUNT(*)"]!),
        };
        print(m);
        print('Get Employees response is ${l.length}');
        return m;
      }else
        return ma;

  }

  static Future<bool> watchedEpisode(String name,String num) async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  watched;
      map['name'] = name;
      map['num'] =  num;
      map['email'] =  NavScreen.email;
      final response = await http.post(Uri.parse(URL7),body: map);
      if(response.statusCode == 200){
        if(response.body == "Done")
          return true;
        else
          return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<List<Map<String,dynamic>>> getWatchedAnime(String date) async{
    List<Map<String,String>> l = [];
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Get_Watched;
      map['name'] = "";
      map['num'] =  date;
      map['email'] =  NavScreen.email;
      final response = await http.post(Uri.parse(URL7),body: map);
      print('Get Employees response is ${response.body}');

      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());

        if(response.body != "Error" && response.body != "dont execute"){
          print("x");
          final list = List<Map<String,dynamic>>.from(
            json.decode(response.body).map((x) =>
            {
              "name":x['name'],
              "num":x['num'] ,
            }

            ),

          );


          return list;
        } else
          return l;
      }else
        return l;
    }catch(ex){
      print(ex);
      return l;
    }

  }

  static fromJson(String text){
    return List<Map<String,String>>.from(
      json.decode(text).map((x) =>
      {
        "name":x['name'],
        "num":x['num'] ,
      }

      ),

    );
  }

  static Future<bool> followAnime(String name) async{
    try{
      var map = Map<String,dynamic>();
      final now = DateTime.now();
      final date  = now.toString().replaceRange(10, null, "");
      map['action'] =  Follow_Anime;
      map['name'] = name;
      map['num'] =  date;
      map['email'] =  NavScreen.email;
      final response = await http.post(Uri.parse(URL7),body: map);
      print('Get Employees response is ${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());

        if(response.body == "Done")
          return true;
        else
          return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<List<Map<String,dynamic>>> getFollowedAnime() async{
    List<Map<String,String>> l = [];

    try{
      var map = Map<String,dynamic>();
      final now = DateTime.now();
      map['action'] =  Get_Follow_Anime;
      map['name'] = "";
      map['num'] =  "";
      map['email'] =  NavScreen.email;
      final response = await http.post(Uri.parse(URL7),body: map);
      if(response.statusCode == 200){

        if(response.body != "Error"){
          final list = List<Map<String,dynamic>>.from(
            json.decode(response.body).map((x) =>
            {
              "name":x['name'],
              "date":x['date'],
            }
            ),
          );
          return list;
        } else
          return l;
      }else
        return l;
    }catch(ex){
      return l;
    }
  }

  static Future<List<Anime>> getAnimesByKind(String kind,int num,String search,int loadAmount) async{
    try{
      var map = Map<String,dynamic>();
      map['loadAmount'] =  loadAmount.toString();
      map['category'] =  kind;
      map['startPoint'] =  num.toString();
      map['title'] =  search;
      final response = await http.post(Uri.parse(URL11),body: map);
      print('Get Employees response is ................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        List<Anime> list = contentFromJson(response.body);
        print('Get Employees response is ........ ${list.length}');
        return list;
      }else
        return List.empty();
    }catch(ex){
      return List.empty();
    }
  }

  static Future<dynamic> getAnimesByName(String name) async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Get_Anime_Kind;
      map['action1'] =  "";
      map['num'] =  "";
      map['search'] =  name;
      final response = await http.post(Uri.parse(URL),body: map);
      print('Get Employees response is ................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        Anime anime = animeFromJson(response.body);
        return anime;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<List<Anime>> getComingSoonAnime(int num,String search) async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Get_Coming_Anime;
      map['action1'] =  "";
      map['num'] =  num.toString();
      map['search'] =  search;
      final response = await http.post(Uri.parse(URL),body: map);
      print('Get Employees response is ................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        List<Anime> list = contentFromJsonComing(response.body);
        print('Get Employees response is ........ ${list.length}');
        return list;
      }else
        return List.empty();
    }catch(ex){
      return List.empty();
    }
  }

  static Future<bool> checkEmail(String email) async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Check_Email;
      map['email'] =  email;
      map['password'] =  "";
      map['birthyear'] =  "";
      map['gender'] =  "";
      final response = await http.post(Uri.parse(URL2),body: map);
      print('Get Employees response is ................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        if(response.body == "Done")
          return true;
        return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<bool> signUp(String email,password,birthyear,gender) async{
    try{
      var map = Map<String,dynamic>();
      map['action'] =  Sign_Up;
      map['email'] =  email;
      map['password'] =  password;
      map['birthyear'] =  birthyear;
      map['gender'] =  gender;
      final response = await http.post(Uri.parse(URL2),body: map);
      print('Get Employees response is ................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        if(response.body == "Done")
          return true;
        return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<bool> sendotp(String email) async{
    print('Get Employees response is ................'+email);
    try{
      var map = Map<String,dynamic>();
      map['email'] =  email;
      final response = await http.post(Uri.parse(URL3),body: map);
      print('Get Employees response is ................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());

        if(response.body == "Done")
          return true;
        return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<String> checkOTP(String email,String code) async{
    print('Get Employees response is ................'+email);
    try{
      var map = Map<String,dynamic>();
      map['action'] = Check_OTP;
      map['email'] =  email;
      map['code'] =  code;
      final response = await http.post(Uri.parse(URL4),body: map);
      print('Get Employees response is is................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());


        return response.body;
      }else
        return "false";
    }catch(ex){
      return "false";
    }
  }

  static Future<bool> login(String email,String password) async{
    print('Get Employees response is ................'+email);
    print('Get Employees response is ................'+password);
    try{
      var map = Map<String,dynamic>();
      map['email'] =  email;
      map['password'] =  password;
      final response = await http.post(Uri.parse(URL5),body: map);
      print('Get Employees response is is................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        if(response.body == "Done")
          return true;
        return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<bool> addToList(String email,String animeName,bool add) async{
    print(email + animeName);
    try{
      var map = Map<String,dynamic>();
      map['email'] =  email;
      map['anime'] =  animeName;
      map['action'] = add ? add_To_List : remove_From_List;
      final response = await http.post(Uri.parse(URL6),body: map);
      print('Get Employees response is is................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        if(response.body == "Done")
          return true;
        return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }


  static Future<bool> getDirectLink() async{

    try{
      var map = Map<String,dynamic>();
      final response = await http.post(Uri.parse(URL8),body: map);
      print('Get Employees response is is................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        if(response.body == "Done")
          return true;
        return false;
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<String> verifyInformation(String newEmail,String oldEmail,String password) async{

    try{
      var map = Map<String,dynamic>();
      map['action'] = verifyInfo;
      map['newEmail'] = newEmail;
      map['oldEmail'] = oldEmail;
      map['password'] = password;

      final response = await http.post(Uri.parse(URL9),body: map);
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());

        return response.body;
      }else {
        return "There is a problem! try again later";
      }
    }catch(ex){
      return "There is a problem! try again later";
    }
  }

  static Future<String> saveInformation(String newEmail,String oldEmail) async{

    try{
      var map = Map<String,dynamic>();
      map['action'] = saveInfo;
      map['newEmail'] = newEmail;
      map['oldEmail'] = oldEmail;
      map['password'] = "";

      final response = await http.post(Uri.parse(URL9),body: map);
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        return response.body;
      }else {
        return "There is a problem! try again later";
      }
    }catch(ex){
      return "There is a problem! try again later";
    }
  }

  static Future<String> resetPassword(String newPassword,String email) async{

    try{
      var map = Map<String,dynamic>();
      map['newPassword'] = newPassword;
      map['email'] = email;


      final response = await http.post(Uri.parse(URL10),body: map);
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        return response.body;
      }else {
        return "There is a problem! try again later";
      }
    }catch(ex){
      return "There is a problem! try again later";
    }
  }

  static Future<bool> createParentalControl(String password) async{
    print("insert");
    print(NavScreen.email);
    try{
      var map = Map<String,dynamic>();
      map['action'] = "insert";
      map['email'] = NavScreen.email;
      map['password'] = password;
      map['openTime'] = "";
      map['closeTime'] = "";
      map['blockedCategories'] = "";
      map['blockedAnime'] = "";
      map['rules'] = "";

      final response = await http.post(Uri.parse(URL12),body: map);
      print('Get Employees response is is................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        if(response.body == "Done"){
          return true;
        }else{
          return false;
        }
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<bool> updateParentalControl(String password,String openTime,String closeTime,String blockedCategories,String blockedAnime,String rules) async{
    try{
      var map = Map<String,dynamic>();
      map['action'] = "update";
      map['email'] = NavScreen.email;
      map['password'] = password;
      map['openTime'] = openTime;
      map['closeTime'] = closeTime;
      map['blockedCategories'] = blockedCategories;
      map['blockedAnime'] = blockedAnime;
      map['rules'] = rules;

      final response = await http.post(Uri.parse(URL12),body: map);
      print('Get Employees response is is................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());
        if(response.body == "Done"){
          return true;
        }else{
          return false;
        }
      }else
        return false;
    }catch(ex){
      return false;
    }
  }

  static Future<Map<String,dynamic>> readParentalControl() async{

    try{
      var map = Map<String,dynamic>();
      map['action'] = "read";
      map['email'] = NavScreen.email;
      map['password'] = "";
      map['openTime'] = "";
      map['closeTime'] = "";
      map['blockedCategories'] = "";
      map['blockedAnime'] = "";
      map['rules'] = "";

      final response = await http.post(Uri.parse(URL12),body: map);
      print('Get Employees response is is................${response.body}');
      if(response.statusCode == 200){
        // print("..............//////////////////...................."+jsonDecode(response.body)[1].toString().isEmpty.toString());

          if(response.body != "Error" && response.body != "There is a problem! try again later"){
            return List<Map<String,dynamic>>.from(
                json.decode(response.body).map((x) => {
                  "password":x["password"],
                  "openTime":x["openTime"],
                  "closeTime":x["closeTime"],
                  "blockedCategories":x["blockedCategories"],
                  "blockedAnime":x["blockedAnime"],
                  "rules":x["rules"],
                })
            )[0];
          }else if(response.body == "Error"){
            return {
              "password":""
            };
          }else{
            return {
              "password":"There is a problem! try again later",
            };
          }

      }else {
          return {
            "password":"There is a problem! try again later",
          };
        }
    }catch(ex){
      return {
        "password":"There is a problem! try again later",
      };
    }
  }

  static Future<Map<String,String>> getAnimeByImage(File image)async{

      final request = http.MultipartRequest('POST',Uri.parse("https://api.trace.moe/search"));
      final pic = await http.MultipartFile.fromPath("image",image.path);
      request.files.add(pic);
      final response = await request.send();
      final data = await response.stream.bytesToString();
      print("Data from server:" + data.toString());
      if(response.statusCode == 200){
        final jsonData = json.decode(data);
        if(jsonData["error"].toString().isEmpty && jsonData["result"].isNotEmpty){
          String animeName = jsonData["result"][0]["filename"];
          String episodeNum = jsonData["result"][0]["episode"].toString();
          if(animeName.contains(" - ")){
            animeName = animeName.substring(0,animeName.indexOf(" - "));
          }

          animeName = animeName.substring(animeName.indexOf("]")+1,animeName.length);
          if(animeName.contains(episodeNum)){
            animeName = animeName.substring(0,animeName.indexOf(episodeNum));
            if(animeName[animeName.length-1] == "0"){
              animeName = animeName.substring(0,animeName.indexOf("0"));
            }
          }
          return {"name":animeName.trim(),"episode":episodeNum};
        }
        return {"name":""};
      }else {
        return {"name":""};
      }
    }


}