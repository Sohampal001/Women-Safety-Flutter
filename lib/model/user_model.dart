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
  String? photoUrl; // Add this line

  UserModel({
<<<<<<< HEAD
    this.childEmail, this.name, this.parentEmail, this.phone,
    this.id, this.type, this.latitude, this.longitude,this.gender
=======
    this.childEmail,
    this.name,
    this.parentEmail,
    this.phone,
    this.id,
    this.type,
    this.latitude,
    this.longitude,
    this.gender,
    this.photoUrl, // Add this line
>>>>>>> 0b9df7fb2e90263554d551c6eb2cbcdc59ef46e6
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
