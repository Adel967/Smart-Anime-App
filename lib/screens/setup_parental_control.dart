import 'package:flutter/material.dart';
import 'package:netflixbro/screens/parentalControl_password.dart';

class SetUpParentalControl extends StatelessWidget {
  const SetUpParentalControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.family_restroom,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(height: 15,),
              const Text(
                "Set Up Parental\nControls",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                ),
              ),
              const SizedBox(height: 25,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.watch_later,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Text(
                      "Keep an eye on screen time and set limits as needed",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: Text(
                      "Add restrictions on content,like categories and specific titles",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 21
                      ),
                      maxLines: 4,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(

                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SetParentalControlPassword(flag: 0,))),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFFEB1555),
                    ),
                      child: const Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15
                          ),
                        ),
                      ),
                  ),
                ),
               ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
