class StoryDataModel{
  String? userName;
  String? userID;
  String? storyImage;
  String? storyDate;
  String? storyTitle;
  // i will put postLink

  StoryDataModel(this.userName,this.userID,this.storyImage,this.storyTitle,this.storyDate);

  // Named Constructor to get Post Data from FireStore
  StoryDataModel.fromJson({required Map<String,dynamic> json}){
    storyDate = json['storyDate'];
    userID = json['userID'];
    userName = json['userName'];
    storyImage = json['storyImage'];
    storyTitle = json['storyTitle'];
  }

  // TOJson used it when i will sent data to fireStore
  Map<String,dynamic> toJson(){
    return {
      'userName' : userName,
      'userID' : userID,
      'storyImage' : storyImage,
      'storyTitle' : storyTitle,
      'storyDate' : storyDate,
    };
  }
}