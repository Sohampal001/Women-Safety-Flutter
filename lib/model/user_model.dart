class UserModel {
  String? name;
  String? phone;
  String? id;
  String? childEmail;
  String? parentEmail;
  String? type;
  double? latitude;
  double? longitude;

  UserModel({
    this.childEmail, this.name, this.parentEmail, this.phone,
    this.id, this.type, this.latitude, this.longitude
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'id': id,
    'childEmail': childEmail,
    'parentEmail': parentEmail,
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
  };
}
