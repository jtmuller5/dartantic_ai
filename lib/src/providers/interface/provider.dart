import '../../models/interface/model.dart';
import '../../models/interface/model_settings.dart';

abstract class Provider {
  String get displayName;

  Model createModel(ModelSettings settings);

  @override
  String toString() => displayName;
}
