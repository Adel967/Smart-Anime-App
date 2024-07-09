import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/screens/search_block_screen.dart';
import 'package:netflixbro/sqlite.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({Key? key}) : super(key: key);

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {

  List<bool> selectedKinds = [];
  List<String> kinds = [
    "Action",
    "Adventure",
    "Comedy",
    "Shounen",
    "Romance",
    "Horror",
    "Mystery",
    "Psychological"
  ];
  List<String> blockedAnimes = [];

  setBlockedCategories(int index)async{
    if(selectedKinds[index]){
      final res = await SQLiteHelper.instance.readParentalControl();
      String blockedCategories = res["blockedCategories"] == null ? "" : res["blockedCategories"];
      print(blockedCategories);
      List<String> b  = [];
      if(blockedCategories.isNotEmpty){
        b = List.from(blockedCategories.split(','));
      }
      b.add(kinds[index]);


      await SQLiteHelper.instance.setBlockedCategories(b.join(","));
    }else{
      final res = await SQLiteHelper.instance.readParentalControl();
      String blockedDays = res["blockedCategories"];
      List<String> b = (blockedDays.split(','));
      b.remove(kinds[index]);
      await SQLiteHelper.instance.setBlockedCategories(b.join(","));
    }
    saveParentalControlData();
  }

  getBlockedAnimes()async{
    blockedAnimes = List.from(await SQLiteHelper.instance.readBlockedAnime());
    final res = await SQLiteHelper.instance.readParentalControl();
    String blockedCategories = res["blockedCategories"] == null ? "" : res["blockedCategories"];
    print(",,,,,,,+++++++++++++"+blockedCategories);
    List<String> b  = [];
    if(blockedCategories.isNotEmpty){

      if(blockedCategories.isEmpty){
        b= [];
      }else{
        b = List.from(blockedCategories.split(','));
      }
    }

    kinds.forEach((element) {
      if(b.contains(element)){
        selectedKinds[kinds.indexOf(element)] = true;
      }
    });
    print(selectedKinds);
    setState(() {

    });
  }

  showAlertDialog(String title) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("YES",style: TextStyle(color: Colors.green),),
      onPressed: () {
        if(blockedAnimes.contains(title)){
          blockedAnimes.remove(title);
          SQLiteHelper.instance.unBlockAnime(title);
        }
        setState(() {

        });
        saveParentalControlData();
        Navigator.of(context).pop();
      },
    );

    Widget cancelButton = TextButton(
      child: Text( "Cancel" ,style: TextStyle(color: Colors.red),),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Text(
        blockedAnimes.contains(title) ? "Are you sure you want to unblock this anime ? " : "Are you sure you want to block this anime ?",
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    kinds.forEach((element) {
      selectedKinds.add(false);
    });
    getBlockedAnimes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0D22),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Blocked Categories",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w600
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 40,
            child: ListView.builder(
              key: PageStorageKey('kinds'),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: kinds.length,
              itemBuilder: (context,index){
                String kind = kinds[index];
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedKinds[index] = !selectedKinds[index];
                    setBlockedCategories(index);
                    setState(() {

                    });
                  }),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: selectedKinds[index] ? Color(0xFFE83D66) : Color(0xFF151E29),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Text(
                      kind,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10,),
          Divider(
            thickness: 0.7,
            indent: 10,
            endIndent: 10,
            color: Color(0xFFB63159),
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                flex: 1,
                  child: SizedBox.shrink()
              ),
              Expanded(
                flex: 5,
                child: Text(
                  "Blocked Animes",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchBlockScreen(blockedAnime: blockedAnimes,))).then((value) => getBlockedAnimes()),
                  icon: Icon(
                    Icons.add,
                    size: 30,
                  ),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Expanded(
            child: blockedAnimes.isEmpty ?
            Center(
              child: Text(
                "There is not any blocked anime!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              ),
            ) : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: blockedAnimes.length,
              itemBuilder: (context,index){
                return Container(
                  width: double.infinity,
                  height: 40,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      color: Color(0xFF1C1F32),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xFFEB1555),
                            blurRadius: 3,
                            offset: Offset(0.0,0.0)
                        )
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text(
                            blockedAnimes[index],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () {
                                  showAlertDialog(blockedAnimes[index]);
                                },
                                icon: Icon(
                                  blockedAnimes.contains(blockedAnimes[index]) ? Icons.lock_open : Icons.block,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
