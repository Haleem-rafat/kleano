class ContactDataModel {
  final String contactTitle;
  final List<String> emails;
  final List<String> phoneNumbers;
  final String whatsAppNumber;
  final String facebookLink;
  final String instagramLink;
  final String twitterLink;
  final String youtubeLink;
  final String linkedinLink;
  final String tiktokLink;
  final String webSiteLink;

  ContactDataModel({
    required this.contactTitle,
    required this.emails,
    required this.phoneNumbers,
    required this.whatsAppNumber,
    required this.facebookLink,
    required this.instagramLink,
    required this.twitterLink,
    required this.youtubeLink,
    required this.linkedinLink,
    required this.tiktokLink,
    required this.webSiteLink,
  });

  factory ContactDataModel.fromJson(Map<String, dynamic> json) {
    return ContactDataModel(
      contactTitle: json['data']['contactTitle'],
      emails: List<String>.from(json['data']['emails']),
      phoneNumbers: List<String>.from(json['data']['phoneNumbers']),
      whatsAppNumber: json['data']['whatsAppNumber'],
      facebookLink: json['data']['facebookLink'],
      instagramLink: json['data']['instagramLink'],
      twitterLink: json['data']['twitterLink'],
      youtubeLink: json['data']['youtubeLink'],
      linkedinLink: json['data']['linkedinLink'],
      tiktokLink: json['data']['tiktokLink'],
      webSiteLink: json['data']['website'],
    );
  }
}
