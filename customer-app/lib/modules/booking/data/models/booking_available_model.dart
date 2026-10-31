class CalenderAvailableModel {
  final DateTime date;
  final List<TimeSlot> timeSlots;
  final bool isActive;

  CalenderAvailableModel({
    required this.date,
    required this.timeSlots,
    required this.isActive,
  });

  factory CalenderAvailableModel.fromJson(Map<String, dynamic> json) {
    return CalenderAvailableModel(
      date: DateTime.parse(json['date']),
      timeSlots: (json['timeSlots'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(TimeSlot.fromJson)
          .toList(),
      isActive: json['isActive'],
    );
  }
}

class TimeSlot {
  final DateTime availableTime;
  final bool isActive;
  final int availableBikersCount;

  TimeSlot({
    required this.availableTime,
    required this.isActive,
    this.availableBikersCount = 0,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      availableTime: DateTime.parse(json['availableTime']),
      isActive: json['isActive'],
      availableBikersCount: json['availableBikersCount'] ?? 0,
    );
  }
}
