class Tcontact{
  int? _id;
  String? _number;
  String? _name;

  Tcontact(this._number,this._name);
  Tcontact.withId(this._id,this._number,this._name);

  int get id => _id!;
  String get number => _number!;
  String get name => _name!;

  @override
  String toString(){
    return 'Contact:{id: $_id,name: $_name,number: $_number}';
  }
  
  set number(String newNumber) => this._number=newNumber;
  set name(String newName) => this._number=newName;

  Map<String,dynamic> toMap(){
    var map=new Map<String,dynamic>();
    map['id']=this._id;
    map['number']=this._number;
    map['name']=this._name;

    return map;
  }

  Tcontact.fromMapObject(Map<String,dynamic>map){
    this._id=map['id'];
    this._number=map['number'];
    this._name=map['name'];
  }
  



}