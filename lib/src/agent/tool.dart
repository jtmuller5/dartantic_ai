typedef ToolCallHandler =
    Future<Map<String, Object?>?> Function(Map<String, Object?> input);

class Tool {
  Tool({
    required this.name,
    required this.onCall,
    this.description,
    this.inputType,
  });

  final String name;
  final String? description;
  final Map<String, dynamic>? inputType;
  final ToolCallHandler onCall;
}
