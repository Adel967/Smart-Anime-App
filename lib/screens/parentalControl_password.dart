import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/screens/duration_management_screen.dart';
import 'package:netflixbro/screens/management_screen.dart';
import 'package:netflixbro/screens/time_management_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';

class SetParentalControlPassword extends StatefulWidget {
  final int flag;
  final int routeFlag;
  final  Function? fun;
   fun1(){}
  const SetParentalControlPassword({Key? key, required this.flag, this.routeFlag = 2, this.fun }) : super(key: key);

  @override
  State<SetParentalControlPassword> createState() => _SetParentalControlPasswordState();
}

class _SetParentalControlPasswordState extends State<SetParentalControlPassword> {
  TextEditingController password = TextEditingController();
  bool isLoading = false;

  buildToast(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,style: TextStyle(fontSize: 16),),
      backgroundColor: Color(0xFFB63159),
    ));
  }

  submit()async{
    if(widget.flag == 0){
      if(password.text.trim().length < 4 || password.text.trim().length > 20){
        buildToast("Password should be between 4 to 20 character");
      }else{
        setState(() {
          isLoading = true;
        });
        final res =  await Services.createParentalControl(password.text.trim());
        if(!res){
          setState(() {
            isLoading = false;
          });
          buildToast("There is a problem, try again later!");
        }else{
          await SQLiteHelper.instance.insertParentalControl(password.text.trim());
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ManagementScreen()));
        }
      }
    }else if(widget.flag == 1){
      setState(() {
        isLoading = true;
      });
      final pc = await SQLiteHelper.instance.readParentalControl();
      if(pc["password"] == password.text.trim()){
        if(widget.routeFlag == 0){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TimeManagementScreen())).then((value) => widget.fun!());
        }else if(widget.routeFlag == 1){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DurationManagementScreen())).then((value) => widget.fun!());
        }else{
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ManagementScreen()));
        }
      }else{
        buildToast("Incorrect password!");
      }
      setState(() {
        isLoading = false;
      });
    }else{
      if(password.text.trim().length < 4 || password.text.trim().length > 20){
        buildToast("Password should be between 4 to 20 character");
      }else{
        setState(() {
          isLoading = true;
        });
        final parentalControl = await SQLiteHelper.instance.readParentalControl();
        final blockedAnimes = await SQLiteHelper.instance.readBlockedAnime();
        final rules = await SQLiteHelper.instance.readRule();

        List<String> rule = [];
        rules.forEach((element) {
          String r = "${element.weekDay}.${element.durationUsage.trim()}.${element.epNum}.${element.active}";
          rule.add(r);
        });

        final res =  await Services.updateParentalControl(password.text.trim(), parentalControl["openTime"], parentalControl["closeTime"], parentalControl["blockedCategories"], blockedAnimes.join(","), rule.join(","));

        if(!res){
          setState(() {
            isLoading = false;
          });
          buildToast("There is a problem, try again later!");
        }else{
          await SQLiteHelper.instance.updateParentalControlPassword(password.text.trim());
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ManagementScreen()));
        }
     }
   }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(
        color: Colors.red,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0,left: 20,right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Parental Control",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.w600
                  ),
                ),
                Text(
                  "Password",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: password,
                  style: TextStyle(
                      color: Colors.white
                  ),
                  textInputAction: TextInputAction.go,
                  obscureText: true,
                  cursorColor: Color(0xFFEF3340),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFB63159)),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFB63159)),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(
                          color: Color(0xFF963B7B),
                          fontSize: 20
                      ),
                      helperStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 15
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.lock,color: Color(0xFFC22D4C),size: 30,),
                      )
                  ),
                ),
                SizedBox(height: 30,),
                GestureDetector(
                  onTap: () => submit(),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                            colors: [Color(0xFF963B7B),Color(0xFF9D3873),Color(0xFFA5366B),Color(0xFFAA3465),Color(0xFFB63159),Color(0xFFBF2D4F),Color(0xFFA92A4B),Color(0xFFC22D4C)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                        )
                    ),
                    child: Text(
                      widget.flag == 1 ? 'Login' : 'Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



