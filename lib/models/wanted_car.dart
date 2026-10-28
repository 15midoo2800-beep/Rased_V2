
import 'package:isar/isar.dart';

part 'wanted_car.g.dart'; // سيتم توليد هذا الملف لاحقاً عبر build_runner

@collection
class WantedCar {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.hash) // الفهرسة اللحظية O(1) للبحث الخارق
  late String digits;

  late String letters;
  late String type;
  late String owner;
  late String shassis;
}
