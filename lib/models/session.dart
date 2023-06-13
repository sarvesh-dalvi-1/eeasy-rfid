class SessionModel {
  SessionModel({
    required this.status,
    required this.data,
    required this.message,
  });
  late final bool status;
  late final Data data;
  late final String message;
  
  SessionModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    data = Data.fromJson(json['data']);
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['data'] = data.toJson();
    _data['message'] = message;
    return _data;
  }
}

class Data {
  Data({
    required this.sessionId,
  });
  late final String sessionId;
  
  Data.fromJson(Map<String, dynamic> json){
    sessionId = json['session_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['session_id'] = sessionId;
    return _data;
  }
}