import 'package:flutter/material.dart';
import 'package:netflixbro/screens/logIn_screen.dart';
import 'package:netflixbro/widgets/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentIndex = 0;
  late PageController _pageController;
  int index1 = 0;
  List<OnboardModel> screens = <OnboardModel>[
    OnboardModel(
      img: 'assets/images/onboarding1.png',
      text: "Watch everywhere",
      desc:
      "Stream unlimited films and TV programmes on your phone, tablet, laptop and TV without paying more",
      bg: Colors.white,
      button: Color(0xFF4756DF),
    ),
    OnboardModel(
      img: 'assets/images/onboarding3.png',
      text: "No connection",
      desc:
      "You can search for any anime even if there isn't Internet connection",
      bg: Color(0xFF4756DF),
      button: Colors.white,
    ),
    OnboardModel(
      img: 'assets/images/onboarding2.png',
      text: "Full inbox",
      desc:
      "We will inform you of everything new about anime and our app",
      bg: Colors.white,
      button: Color(0xFF4756DF),
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _storeOnboardInfo() async {
    print("Shared pref called");
    int isViewed = 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    WidgetsFlutterBinding.ensureInitialized();
    await prefs.setInt('onBoard', isViewed);
    print(prefs.getInt('onBoard'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        actions: [
          TextButton(
            onPressed: () {
              _storeOnboardInfo();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text(
              "Skip",
              style: TextStyle(
                color: Color(0xFF963B7B),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0,right: 20,bottom: 20),
        child: Column(
          children: [
            Container(
              height: size.height * 0.7,
              child: PageView.builder(
                  itemCount: screens.length,
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          screens[index].img,
                          width: size.width * 0.9,
                          height: size.height * 0.3,
                        ),
                        SizedBox(height: 40,),
                        Text(
                          screens[index].text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0xFFB63159),
                          ),
                        ),
                        SizedBox(height: 30,),
                        Text(
                          screens[index].desc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Montserrat',
                            color: Color(0xFF963B7B),
                          ),
                        ),

                      ],
                    );
                  }),
            ),
            Container(
              height: size.height*0.15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 10.0,
                    margin: EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: screens.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 3.0),
                                width: currentIndex == index ? 25 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: currentIndex == index
                                      ? Colors.red
                                      : Color(0xFF963B7B),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ]);
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () async {
                        if (index1 == screens.length - 1) {
                          await _storeOnboardInfo();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        }
                        setState(() {
                          index1++;
                        });
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.bounceIn,
                        );
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFFEF3340),),
                              textAlign: TextAlign.end,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(
                              Icons.arrow_forward_sharp,
                              color: Color(0xFFEF3340),
                              size: 25,
                            )
                          ]),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}