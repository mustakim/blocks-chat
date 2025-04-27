class DashboardModel {
  final String msg;

  const DashboardModel({required this.msg});

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        msg: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
      };
}

class ChatParams {
  String content;

  ChatParams({
    required this.content,
  });
}

class ChatResponseModel {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<Choice> choices;

  ChatResponseModel({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
  });

  ChatResponseModel copyWith({
    required String? id,
    required String? object,
    required int? created,
    required String? model,
    required List<Choice>? choices,
  }) =>
      ChatResponseModel(
        id: id ?? this.id,
        object: object ?? this.object,
        created: created ?? this.created,
        model: model ?? this.model,
        choices: choices ?? this.choices,
      );

  factory ChatResponseModel.fromJson(
    Map<String, dynamic> json,
    Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ChatResponseModel(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: List<Choice>.from(
        json["choices"].map((x) => Choice.fromJson(x)),
      ),
    );
  }
}

class Choice {
  final int index;
  final Map<String, dynamic> message;

  Choice({
    required this.index,
    required this.message,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'],
      message: json['message'],
    );
  }
}
