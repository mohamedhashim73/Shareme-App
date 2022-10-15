class PostDataModel{
  String? userName;
  String? userID;
  String? userImage;
  String? postDate;
  String? postCaption;
  String? postImage;
  // i will put postLink

  PostDataModel(this.userName,this.userID,this.userImage,this.postCaption,this.postDate,this.postImage);

  // Named Constructor to get Post Data from FireStore
  PostDataModel.fromJson({required Map<String,dynamic> json}){
    userImage = json['userImage'];
    userID = json['userID'];
    userName = json['userName'];
    postImage = json['postImage'];
    postDate = json['postDate'];
    postCaption = json['postCaption'];
  }

  // TOJson used it when i will sent data to fireStore
  Map<String,dynamic> toJson(){
    return {
      'userName' : userName,
      'userID' : userID,
      'userImage' : userImage,
      'postCaption' : postCaption,
      'postDate' : postDate,
      'postImage' : postImage,
    };
  }
}