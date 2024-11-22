class UserModel {
  String? name;
  String? phone;
  String? id;
  String? childEmail;
  String? parentEmail;
  String? type;
  String? gender;

  double? latitude;
  double? longitude;
  String? photoUrl;

  UserModel({
    this.childEmail,
    this.name,
    this.parentEmail,
    this.phone,
    this.id,
    this.type,
    this.latitude,
    this.longitude,
    this.gender,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'childEmail': childEmail,
        'parentEmail': parentEmail,
        'type': type,
        'gender': gender,
        'latitude': latitude,
        'longitude': longitude,
        'photoUrl': photoUrl, // Add this line
      };
}
