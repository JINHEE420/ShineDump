import 'dart:math';

/// Calculate between two locations in meter
double haversine(double lat1, double lon1, double lat2, double lon2) {
  // distance between latitudes and longitudes
  double dLat = radians(lat2 - lat1);
  double dLon = radians(lon2 - lon1);
  // convert to radiansVDH
  lat1 = radians(lat1);
  lat2 = radians(lat2); // apply formulae
  var a = pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);
  double rad = 6371;
  double c = 2 * asin(sqrt(a));
  return rad * c * 1000;
}

double radians(double degrees) {
  return degrees * pi / 180;
}
