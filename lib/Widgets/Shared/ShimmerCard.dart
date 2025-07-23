import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShimmerCard extends StatelessWidget {
  final double height;
  final double width;
  final Widget? child;

  const ShimmerCard({
    Key? key,
    this.height = 200,
    this.width = double.infinity,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: child,
    );
  }
}

class FoodItemShimmer extends StatelessWidget {
  const FoodItemShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 210,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Stack(
                children: [
                  ShimmerCard(
                    height: 135,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "5 KM",
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        CupertinoIcons.heart,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerCard(
                    height: 20,
                    width: 150,
                    child: Center(
                      child: Text(
                        "Nougatine au lardon",
                        style: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  ShimmerCard(
                    height: 20,
                    width: 60,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 13,
                            color: Colors.yellow[900],
                          ),
                          SizedBox(width: 5),
                          Text("4.7"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerCard(
                    height: 20,
                    width: 80,
                    child: Center(
                      child: Text(
                        "15 €",
                        style: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItemShimmer extends StatelessWidget {
  const OrderItemShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
        child: InkWell(
          child: ListTile(
            autofocus: false,
            leading: ShimmerCard(height: 350, width: 100),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerCard(
                    height: 20,
                    width: 120,
                    child: Text(
                      "Loading...",
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(height: 5),
                  ShimmerCard(
                    height: 15,
                    width: 100,
                    child: Text(
                      "Loading...",
                      style: GoogleFonts.montserrat(fontSize: 13),
                    ),
                  ),
                  SizedBox(height: 5),
                  ShimmerCard(
                    height: 15,
                    width: 80,
                    child: Text(
                      "Status",
                      style: GoogleFonts.montserrat(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            trailing: ShimmerCard(
              height: 20,
              width: 50,
              child: Text("15€"),
            ),
          ),
        ),
      ),
    );
  }
}