import 'package:json_annotation/json_annotation.dart';
import 'package:soti_schema/annotations.dart';

part 'loc_time_temp.g.dart';

@SotiSchema()
@JsonSerializable()
class LocTimeTemp {
  LocTimeTemp({required this.location, required this.time, required this.temp});

  /// The location to get the temperature in (e.g. "New York, NY")
  final String location;

  /// The time in the given time zone
  final DateTime time;

  /// The temperature in degrees Fahrenheit
  final double temp;

  static LocTimeTemp fromJson(Map<String, dynamic> json) =>
      _$LocTimeTempFromJson(json);

  Map<String, dynamic> toJson() => _$LocTimeTempToJson(this);

  @jsonSchema
  static Map<String, dynamic> get schemaMap => _$LocTimeTempSchemaMap;
}

@SotiSchema()
@JsonSerializable()
class ListOfLocTimeTemps {
  ListOfLocTimeTemps({required this.locations});

  /// A list of locations with their current time and temperature
  final List<LocTimeTemp> locations;

  static ListOfLocTimeTemps fromJson(Map<String, dynamic> json) =>
      _$ListOfLocTimeTempsFromJson(json);

  Map<String, dynamic> toJson() => _$ListOfLocTimeTempsToJson(this);

  @jsonSchema
  static Map<String, dynamic> get schemaMap => _$ListOfLocTimeTempsSchemaMap;
}
