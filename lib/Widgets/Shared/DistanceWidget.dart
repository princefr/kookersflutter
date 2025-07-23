import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Models/Location.dart';

class DistanceWidget extends StatelessWidget {
  final Location startLocation;
  final Location endLocation;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final double borderRadius;

  const DistanceWidget({
    Key? key,
    required this.startLocation,
    required this.endLocation,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(7.0),
    this.borderRadius = 15.0,
  }) : super(key: key);

  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    var earthRadius = 6378137.0;
    var dLat = _toRadians(endLatitude - startLatitude);
    var dLon = _toRadians(endLongitude - startLongitude);

    var a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(startLatitude)) *
            cos(_toRadians(endLatitude));
    var c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  String getDisplayDistance() {
    if (startLocation.latitude == null || startLocation.longitude == null ||
        endLocation.latitude == null || endLocation.longitude == null) {
      return "-- km";
    }
    
    final distanceInMeters = distanceBetween(
      startLocation.latitude!,
      startLocation.longitude!,
      endLocation.latitude!,
      endLocation.longitude!,
    );
    final distanceInKm = (distanceInMeters.floor() / 1000).round();
    return "$distanceInKm km";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      padding: padding,
      child: Text(
        getDisplayDistance(),
        style: GoogleFonts.montserrat(color: textColor),
      ),
    );
  }
}

class DistanceCalculator {
  static double? calculateDistance(Location start, Location end) {
    if (start.latitude == null || start.longitude == null ||
        end.latitude == null || end.longitude == null) {
      return null;
    }
    
    var earthRadius = 6378137.0;
    var dLat = _toRadians(end.latitude! - start.latitude!);
    var dLon = _toRadians(end.longitude! - start.longitude!);

    var a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(start.latitude!)) *
            cos(_toRadians(end.latitude!));
    var c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  static String formatDistance(double distanceInMeters) {
    final distanceInKm = (distanceInMeters.floor() / 1000).round();
    return "$distanceInKm km";
  }
}