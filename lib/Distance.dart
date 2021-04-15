import 'dart:ffi';

class Distance {
  Float distance;
  String unit;

  Distance(this.distance, this.unit);

  factory Distance.fromJson(dynamic json) {
    return Distance(json['distance'], json['unit']);
  }
}
