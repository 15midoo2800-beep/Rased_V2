import 'package:isar/isar.dart';

part 'wanted_car.g.dart';

@collection
class WantedCar {
  Id id = Isar.autoIncrement;

  @Index()
  late String digitsOnly;

  String? plateNumber;
  String? note;
  DateTime? createdAt;
}
