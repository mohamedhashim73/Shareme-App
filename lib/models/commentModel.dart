class CommentDataModel{
  String? comment;
  String? commentMakerID;
  String? commentMakerName;
  String? commentMakerImage;
  String? dateTime;
  String? postID;
  // Constructor
  CommentDataModel(this.comment,this.commentMakerID,this.commentMakerImage,this.commentMakerName,this.dateTime,this.postID);

  CommentDataModel.fromJson({required Map<String,dynamic> json}){
    comment = json['comment'];
    commentMakerID = json['commentMakerID'];
    commentMakerName = json['commentMakerName'];
    commentMakerImage = json['commentMakerImage'];
    postID = json['postID'];
  }

  Map<String,dynamic> toJson(){
    return {
      'comment' : comment,
      'commentMakerID' : commentMakerID,
      'commentMakerName' : commentMakerName,
      'commentMakerImage' : commentMakerImage,
      'postID' : postID,
    };
  }
}