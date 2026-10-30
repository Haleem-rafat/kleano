class BaseModelSocketStatus {
  bool? success;
  String? sId;
  String? status;
  String? time;
  int? duration;

  BaseModelSocketStatus({
    this.success,
    this.sId,
    this.status,
    this.time,
    this.duration,
  });

  BaseModelSocketStatus.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    sId = json['_id'];
    status = json['status'];
    time = json['time'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['_id'] = sId;
    data['status'] = status;
    data['time'] = time;
    data['duration'] = duration;
    return data;
  }
}
