import 'package:json_schema/json_schema.dart';

import '../tool.dart';
import 'chat_message.dart';
import 'chat_model_options.dart';
import 'chat_result.dart';

/// Chat model base class.
abstract class ChatModel<TOptions extends ChatModelOptions> {
  /// Creates a new chat model instance.
  ChatModel({
    required this.name,
    required this.defaultOptions,
    this.tools,
    this.temperature,
  });

  /// The default options for the chat model.
  final TOptions defaultOptions;

  /// The model name to use.
  final String name;

  /// The tools the model may call.
  final List<Tool>? tools;

  /// The temperature for the model.
  final double? temperature;

  /// Streaming method that returns Message objects.
  ///
  /// This method should call the underlying LLM API and return a stream
  /// of responses.
  ///
  /// [messages] is the list of messages to send to the model.
  ///
  /// [options] is an optional set of options that can be used to configure
  /// the model.
  ///
  /// [outputSchema] is an optional schema that can be used to validate
  /// the output of the model.
  Stream<ChatResult<ChatMessage>> sendStream(
    List<ChatMessage> messages, {
    TOptions? options,
    JsonSchema? outputSchema,
  });

  /// Disposes the chat model.
  void dispose();
}
