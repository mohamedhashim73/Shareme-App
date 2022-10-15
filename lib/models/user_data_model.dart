class UserDataModel{
  String? userName;
  String? bio;
  String? image;
  String? email;
  String? userID;
  UserDataModel({this.email,this.userID,this.userName,this.image,this.bio});
  // NamedConstructor => I will used it when i get Data from fireStore and save it on this model
  UserDataModel.fromJson(Map<String,dynamic> json){
    userName = json['userName'];
    bio = json['bio'];
    image = json['image'];
    email = json['email'];
    userID = json['uid'];
  }
  // TOJson  => I will used it when i want to  send data to cloud firestore ( Fields )
  Map<String,dynamic> toJson(){
    return {
      'userName' : userName,
      'bio' : bio,
      'image' : image,
      'email' : email,
      'uid' : userID,
    };
  }
}