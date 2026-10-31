class BannerModel {
  String? id;
  String? title;
  String? description;
  String? imageLink;
  String? imageLinkAr;
  bool? isActive;
  String? externalLink;
  String? resource;
  String? resourceId;

  BannerModel({
    this.id,
    this.title,
    this.description,
    this.imageLink,
    this.imageLinkAr,
    this.isActive,
    this.externalLink,
    this.resource,
    this.resourceId,
  });

  BannerModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    description = json['description'];
    imageLink = json['imageLink'];
    imageLinkAr = json['imageLinkAr'];
    isActive = json['isActive'];
    externalLink = json['externalUrl'];
    resource = json['resource'];
    resourceId = json['resourceId'];
  }
}
