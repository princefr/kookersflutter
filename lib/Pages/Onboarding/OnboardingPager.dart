import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignPage.dart';
import 'package:kookers/Pages/Onboarding/OnboardingModel.dart';
import 'package:kookers/Pages/Onboarding/OnboardingPage.dart';
import 'package:kookers/Widgets/CircleDot.dart';
import 'package:get/get.dart';


class OnBoardingPager extends StatefulWidget {
    @override
  _OnboardingPagerState createState() => _OnboardingPagerState();
}


// https://storyset.com/pana


class _OnboardingPagerState extends State<OnBoardingPager> {
  PageController _pageController = PageController(initialPage: 0);
  int currentPageValue = 0;
  int previousPageValue = 0;
  double _moveBar = 0.0;

  final onboardingPageTypeTwo = OnboardingPage();

  final List<Widget> introWidgetsList = [
    OnboardingPage(data:
     OnboardingModel(
       description: "Kookers  connecte chefs amateurs et gourmands souhaitant faire des découvertes culinaires.",
       placeHolder: "assets/onboarding/Sush_cook-pana.png",
       title: "Concept",
      )
     ),

    OnboardingPage(data:
     OnboardingModel(
       description: "Commandez  les plats ou dessert en fonction de vos préférences culinaires et de votre géolocalisation.",
       placeHolder: "assets/onboarding/Messaging_fun-pana.png",
       title: "Commandez",
      )
     ),

     OnboardingPage(data:
      OnboardingModel(
        description: "Votre chef ou nos partenaires achiminent votre commande directement devant votre porte.",
        placeHolder: "assets/onboarding/Take_Away-pana.png",
        title: "Faites vous livrer",
        )
      ),

      OnboardingPage(data:
      OnboardingModel(
        description: "Dégustez votre plat ou votre dessert en toute tranquillité.",
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
                          Get.to(BeforeSignPage(from: "onboarding",));
                        },
                        child: Container(
                          key: Key("OnBording_pass"),
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