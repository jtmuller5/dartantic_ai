import '../agent/agent_impl.dart';
import 'language_model.dart';

abstract class ModelConfig {
  String get displayName;

  LanguageModel<ModelConfig> languageModelFor(Agent agent);
}
