class ChatModel {
  final String message;
  final DateTime time;
  ChatModel({required this.message, required this.time});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      message: json['message'],
      time: DateTime.parse(json['time']),
    );
  }
}
