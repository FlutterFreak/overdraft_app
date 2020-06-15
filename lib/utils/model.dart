import 'package:scoped_model/scoped_model.dart';

class OverdraftModel extends Model {
  double updatedValue = 100;

  double get getUpdated => updatedValue;

  void updateValue(double value) {
    updatedValue = value;

    notifyListeners();
  }
}
