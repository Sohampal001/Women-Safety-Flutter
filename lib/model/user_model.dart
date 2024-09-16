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
    this.childEmail,
    this.name,
    this.parentEmail,
    this.phone,
    this.id,
    this.type,
    this.latitude,
    this.longitude,
    this.photoUrl, // Add this line
=======
    this.childEmail, this.name, this.parentEmail, this.phone,
    this.id, this.type, this.latitude, this.longitude,this.gender
>>>>>>> 1c71e3f5019b210b4356e4268c53e2dcad7ee3dc
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'id': id,
    'childEmail': childEmail,
    'parentEmail': parentEmail,
    'type': type,
    'gender':gender,
    'latitude': latitude,
    'longitude': longitude,
    'photoUrl': photoUrl, // Add this line
  };
}
