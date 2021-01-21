import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/Onboarding/OnboardingModel.dart';
import 'package:kookers/Pages/Onboarding/OnboardingPage.dart';
import 'package:kookers/Pages/PhoneAuth/PhoneAuthPage.dart';
import 'package:kookers/Widgets/CircleDot.dart';


class OnBoardingPager extends StatefulWidget {
    @override
  _OnboardingPagerState createState() => _OnboardingPagerState();
}



class _OnboardingPagerState extends State<OnBoardingPager> {
  PageController _pageController;
  int currentPageValue = 0;
  int previousPageValue = 0;
  double _moveBar = 0.0;

  final onboardingPageTypeTwo = OnboardingPage();

  final List<Widget> introWidgetsList = [
    OnboardingPage(data:
     OnboardingModel(
       description: "Kookers vous connecte avec des chefs autour de vous",
       placeHolder: "assets/onboarding/Chef-pana.png",
       title: "Payer",
      )
     ),

    OnboardingPage(data:
     OnboardingModel(
       description: "Envoyer de l'argent instantanément et gratuitement à travers les frontières.",
       placeHolder: "assets/onboarding/Messaging_fun-pana.png",
       title: "Commandez",
      )
     ),

     OnboardingPage(data:
      OnboardingModel(
        description: "Retirer votre argent sur votre compte en banque ou dans l'une de nos agences partenaire.",
        placeHolder: "assets/onboarding/Pedestrian_crossing-pana-2.png",
        title: "Retirez",
        )
      ),

      OnboardingPage(data:
      OnboardingModel(
        description: "Retirer votre argent sur votre compte en banque ou dans l'une de nos agences partenaire.",
        placeHolder: "assets/onboarding/Eating_healthy_food-pana.png",
        title: "Dégustez",
        )
      )
  ];


    @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPageValue);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
          PageView.builder(
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
            return introWidgetsList[index];
          },
          onPageChanged: (int page) {
            animatePage(page);
          },
          itemCount: introWidgetsList.length,
          controller: _pageController,
          ),

          Stack(
            alignment: AlignmentDirectional.topStart,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                      Row(
                        children: <Widget>[
                          for (int i = 0; i < introWidgetsList.length; i++)
                            if (i == currentPageValue) ...[
                              CircleDotWidget(
                                isActive: true,
                                color: Colors.black,
                                borderColor:  Colors.black,
                              )
                            ] else
                              CircleDotWidget(
                                isActive: false,
                                color: Colors.white,
                                borderColor: Colors.black,
                              ),
                        ],
                      ),


                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, CupertinoPageRoute(builder: (context) => PhoneAuthPage()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            shadows: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(
                                0.0, // Move to right 10  horizontally
                                4.0, // Move to bottom 5 Vertically
                              ),
                            )
                          ],
                          color: Colors.red,
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.black, width: 2))
                          ),
                          child: Icon(CupertinoIcons.arrow_right, color: Colors.white,),
                        )
                      )
                  ],
                )
              )
            ]
          )

      ]
    );
  }




  void animatePage(int page) {
    currentPageValue = page;

    if (previousPageValue == 0) {
      previousPageValue = currentPageValue;
      _moveBar = _moveBar + 0.14;
    } else {
      if (previousPageValue < currentPageValue) {
        previousPageValue = currentPageValue;
        _moveBar = _moveBar + 0.14;
      } else {
        previousPageValue = currentPageValue;
        _moveBar = _moveBar - 0.14;
      }
    }

    setState(() {});
  }


}