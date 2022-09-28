class UserDataModel{
  String? name;
  String? userName;
  String? bio;
  String? image;
  String? email;
  String? uid;
  UserDataModel({this.email,this.name,this.uid,this.userName,this.image,this.bio});
  // NamedConstructor => I will used it when i get Data from firestore and save it on this model
  UserDataModel.fromJson(Map<String,dynamic> json){
    name = json['name'];
    userName = json['userName'];
    bio = json['bio'];
    image = json['image'];
    email = json['email'];
    uid = json['uid'];
  }
  // TOJson  => I will used it when i want to  send data to cloud firestore ( Fields )
  Map<String,dynamic> toJson(){
    return {
      'name' : name,
      'userName' : userName,
      'bio' : bio,
      'image' : image,
      'email' : email,
      'uid' : uid,
    };
  }
}