import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/models/commentModel.dart';
import 'package:social_app/models/likeDataModel.dart';
import 'package:social_app/models/messgaeDataModel.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:social_app/modules/home/homeScreen.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/modules/search/searchScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'dart:io';
import 'package:social_app/shared/network/local/cacheHelper.dart';
import '../../modules/chat/chatScreen.dart';
import 'layoutStates.dart';

class LayoutCubit extends Cubit<LayoutStates>{
  LayoutCubit() : super(InitialLayoutState());
  // Method to get object from this cubit in the state
  static LayoutCubit getCubit(BuildContext context)=> BlocProvider.of(context);

  // Method for changeBottomNavIndex
  int bottomNavIndex = 0;
  void changeBottomNavIndex(int index){
    bottomNavIndex = index;
    emit(ChangeBottomNavIndexState());
  }

  List<Widget> layoutWidgets = [ const HomeScreen(), const SearchScreen(), const ChatScreen(), ProfileScreen(),];

  /*
    1) get My Data to show in Profile screen and use it in other screens
  */
  UserDataModel? userData;
  void getMyData(){
    FirebaseFirestore.instance.collection("users").doc(userID??CacheHelper.getCacheData(key: 'uid')).get().then((value){
      userData = UserDataModel.fromJson(value.data()!);
      print("User Id after adding to Model is ${userData!.userName}");
      emit(GetUserDataSuccessState());
    });
  }

  // ***************************************************************************

  /*
    2) get Data for all users to show on chat screen
  */

  List<UserDataModel> usersData = [];
  List<String> usersID = [];
  void getUsersData(){
    if( usersData.isEmpty )
    {
      FirebaseFirestore.instance.collection('users').snapshots().listen((value){
      usersData = [];
      usersID = [];
      value.docs.forEach((element) {
        print(element.id);
        if( userData?.userID != element.id)
        {
          usersID.add(element.id);
          usersData.add(UserDataModel.fromJson(element.data()));
        }
        emit(GetUsersDataSuccessState());
      });
    });
    }
  }

  bool profileImageChosen = true ;   // this for show images or videos on Profile Screen as User's Tap

  // ***************************************************************************

  /*
    3) set my data || update it also either by name,email,password or update my image
  */

  File? userImageFile;
  final userImagePicker = ImagePicker();
  Future<void> getProfileImage() async{
    emit(GetProfileImageLoadingState());
    final pickedImage = await userImagePicker.getImage(source: ImageSource.gallery);
    if(pickedImage != null)
    {
      userImageFile = File(pickedImage.path);
      emit(ChosenImageSuccessfullyState());
    }
    else
    {
      emit(ChosenImageErrorState());
    }
  }

  void updateUserDataWithoutImage({required String email,required String bio,required String userName,String? image}){
    emit(UpdateUserDataWithoutImageLoadingState());
    final model = UserDataModel(image: image?? userData!.image,email: email,bio: bio,userName: userName,userID: userData!.userID);
    FirebaseFirestore.instance.collection('users').doc(userData!.userID)
    .update(model.toJson())
    .then((value){
      getMyData();  // هنا مش عارف المشكله بتاعه اما ارفع الداتا اللي كان مكتوب داخل textFormField بيتغير وبيأخد الحاجه القديمه عما يخرج من صفحه update
      emit(UpdateUserDataWithoutImageSuccessState());
    }).catchError((e)=>emit(UpdateUserDataWithoutImageErrorState()));
  }

  void updateUserDataWithImage({required String email,required String bio,required String userName}){
    emit(UpdateUserDataWithImageLoadingState());
    firebase_storage.FirebaseStorage.instance.ref()
        .child("users/${Uri.file(userImageFile!.path).pathSegments.last}")
        .putFile(userImageFile!)
        .then((val){
          val.ref.getDownloadURL().then((imageUrl){
            // upload Update for userData to FireStore
            updateUserDataWithoutImage(email: email, bio: bio, userName: userName,image: imageUrl);
          }).catchError((onError)=>emit(UploadUserImageErrorState()));
        }).catchError((error){emit(UpdateUserDataWithImageErrorState());});
  }

  // made this function as if i change profile photo but canceled update imageProfileUrl will show on EditProfileScreen as i canceled update and i use profileImageUrl to be shown not userData!.image
  void canceledUpdateUserData(){
    emit(CanceledUpdateUserDataState());
  }

  /*
    4) create posts with image or without || delete post from fireStore
  */

  File? postImageFile;
  final postImagePicker = ImagePicker();
  void getPostImage() async{
    final pickedPostImage = await postImagePicker.getImage(source: ImageSource.gallery);
    if( pickedPostImage != null )
      {
        postImageFile = File(pickedPostImage.path);
        emit(ChosenPostImageSuccessfullyState());
      }
    else
    {
      emit(ChosenPostImageErrorState());
    }
  }

  void createPostWithoutImage({required String postCaption,String? postImage}){
    emit(UploadPostWithoutImageLoadingState()); // loading
    final model = PostDataModel(userData!.userName, userData!.userID, userData!.image,postCaption,timeNow.toString(),postImage?? "");
    FirebaseFirestore.instance.collection('users').doc(userData!.userID).collection('posts')
        .add(model.toJson()).then((value){
      emit(UploadPostWithoutImageSuccessState()); // success
    }).catchError((error){print(error.toString());emit(UploadPostWithoutImageErrorState());});
  }

  void createPostWithImage({required String postCaption}){
    emit(UploadPostWithImageLoadingState());   // loading
    firebase_storage.FirebaseStorage.instance.ref()
    .child("posts/${Uri.file(postImageFile!.path).pathSegments.last}")
    .putFile(postImageFile!)
    .then((value){
      value.ref.getDownloadURL().then((imageUrl){
        print("New post image added $imageUrl");
        // here upload post totally to FireStore with Image
        createPostWithoutImage(postCaption: postCaption,postImage: imageUrl);
      }).catchError((e){
        print("Error during upload post Image => ${e.toString()}");
        emit(UploadImageForPostErrorState());  // error during upload postImage not totally Post
      });
    })
    .catchError((onError){
      emit(UploadPostWithImageErrorState());  // error during upload Posts totally
    });
  }

  void updatePost({required String postMakerID,required String postID,required String postMakerName,required String postMakerImage,required String postCaption,required String postDate,required String postImage}){
    emit(UpdatePostLoadingState());
    final model = PostDataModel(postMakerName, postMakerID, postMakerImage, postCaption, postDate, postImage);
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).update(model.toJson()).then((value)
    {
      getUsersPosts();   // it is possible to not call it if i use real time when i get posts for users as in this case will listen for changes
      emit(UpdatePostSuccessfullyState());
    }).catchError((e)=>emit(UpdatePostErrorState()));
  }

  void deletePost({required String postMakerID,required String postID}){
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).delete().then((value){
      getUsersPosts();
      // يفترض يحصل تحديث ف البوستات لان مستعمل real time
      emit(DeletePostSuccessfullyState());
    }).catchError((e)=>emit(DeletePostErrorState()));
  }

  void canceledImageForPost(){
    postImageFile = null;
    emit(CanceledImageForPostState());
  }

  // ***************************************************************************

  /*
    5) get my posts to show on my Profile Screen
  */

  List<PostDataModel> userPostsData = [];    // as i send data as PostDataModel to FireStore
  List<String> myPostsID = [];
  void getMyPosts(){
    emit(GetUserPostsLoadingState());
    FirebaseFirestore.instance.collection('users').doc(CacheHelper.getCacheData(key: 'uid')??userData!.userID).collection('posts').snapshots()
        .listen((value){
      userPostsData = [];
      myPostsID = [];
      value.docs.forEach((element){
        print("Your ID for your posts are ${element.id}");
        myPostsID.add(element.id);
        userPostsData.add(PostDataModel.fromJson(json: element.data()));
        emit(GetUserPostsSuccessState());
      });
    });
  }

  // ***************************************************************************

  /*
    6) get all posts for all users to show on Home Screen
  */
  List<PostDataModel> usersPostsData = [];
  List<String> postsID = [];
  List<int> commentsNumber = [];  // use this var only to show the number of posts but if i want to display all comments i will use getComments() method for specific post using its ID and postMakerID
  void getUsersPosts(){
    print("Start get posts for all users before listen to data");
    FirebaseFirestore.instance.collection('users').snapshots().listen((value){
      print("Start listen to get posts for all users **************************");
      commentsNumber = [];
      usersPostsData = [];
      postsID = [];
      value.docs.forEach((element){
        element.reference.collection('posts').get().then((val){
          val.docs.forEach((postData){  // postData => post ذات نفسه
            postData.reference.collection('comments').get().then((val){
              commentsNumber.add(val.docs.length);
              postsID.add(postData.id);   // store posts ID to use it when i add a comment
              usersPostsData.add(PostDataModel.fromJson(json: postData.data()));
              print("get posts for first time #######################");
            });
          });
        });
      });
      emit(GetUsersPostsSuccessState(usersPostsData.length));
    });
  }

  // ***************************************************************************

  /*
    7) add a like to a post || remove it
  */

  void addLike({required String postID,required bool isLike}){
    final model = LikeDataModel(userData!.image,userData!.userID,userData!.userName,DateTime.now().toString(),isLike);
    FirebaseFirestore.instance.collection('users').get().then((value){
      value.docs.forEach((element) {
        element.reference.collection('posts').doc(postID).collection('likes').doc(userData!.userID).set(model.toJson()).then((value){
          emit(AddLikeSuccessfullyState());   // add like successfully
        });
      });
    }).catchError((error)=>emit(AddLikeErrorState())); // error during add a comment to specific post
  }

  void removeLike({required String postID}){
    FirebaseFirestore.instance.collection('users').get().then((value){
      value.docs.forEach((element) {
        element.reference.collection('posts').doc(postID).collection('likes').doc(userData!.userID).delete().then((val){
          emit(RemoveLikeSuccessfullyState());   // add like successfully
        });
      });
    }).catchError((error)=>emit(RemoveLikeErrorState())); // error during add a comment to specific post
  }

  // get likes for specific post throw its id and show it in separated screen
  List<LikeDataModel> likesData = [];
  void getLikes({required String postMakerID,required String postID}){
    emit(GetLikesLoadingState());
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').snapshots().listen((value){
      likesData = [];
      value.docs.forEach((element){
        print("isLike status is ${element.data()['isLike']}\n");
        print("isLike status is ${element.data()['dateTime']}");
        if( element.data()['isLike'] == true )
        {
          likesData.add(LikeDataModel.fromJson(json: element.data()));
        }
      });
      emit(GetLikesSuccessfullyState());
    });
  }

  // ***************************************************************************

  /*
    8) add a comment to a post || remove it || get comments for specific post using its ID
  */

  void addComment({required String comment,required String postID}){
    final model = CommentDataModel(comment, userData!.userID, userData!.image, userData!.userName,timeNow, postID);
    FirebaseFirestore.instance.collection('users').get().then((value){
      value.docs.forEach((element) {
        element.reference.collection('posts').doc(postID).collection('comments').doc(userData!.userID).set(model.toJson()).then((value){
        });
        emit(AddCommentSuccessState());
      });
    });
  }

  List<CommentDataModel> comments = [];
  void getComments({required String postMakerID,required String postID}){
    emit(GetCommentsLoadingState());
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('comments').snapshots().listen((value){
      comments = [];
      value.docs.forEach((element){
        comments.add(CommentDataModel.fromJson(json: element.data()));
      });
      emit(GetCommentsSuccessState());
    });
  }

  // ***************************************************************************

  /*
    9) send a message to specific user using his ID || get all messages between me and specific user
  */
  void sendMessage({required String message,required String messageReceiverID}){
    // there is no need for loading state and error also
    final model = MessageDataModel(message,DateTime.now().toString(),messageReceiverID,userData!.userID);
    // saved message on my collection
    FirebaseFirestore.instance.collection('users').doc(userData!.userID).collection('chats').doc(messageReceiverID).collection('messages').add(model.toJson()).then((value){
      emit(SendMessageSuccessState());
    });
    // saved message on receiver collection also
    FirebaseFirestore.instance.collection('users').doc(messageReceiverID).collection('chats').doc(userData!.userID).collection('messages').add(model.toJson()).then((value){
      emit(SendMessageSuccessState());
    });
  }

  List<MessageDataModel> messages = [];
  void getMessages({required String messageReceiverID}) {
    print("start get message ************************ messages are ${messages}");
    emit(GetMessageLoadingState());
    FirebaseFirestore.instance.collection('users').doc(userData!.userID).collection('chats').doc(messageReceiverID).collection('messages')
        .orderBy('messageDateTime')
        .snapshots()
        .listen((val)
         {
           print("start listen to getting message as a real time ########################## messages are $messages");
           messages = [];
           val.docs.forEach((element) {
             messages.add(MessageDataModel.fromJson(json: element.data()));
           });
         });
    emit(GetMessageSuccessState());
  }

  // ***************************************************************************
  /*
    10) delete a person from App completely (( optional ))
  */
  void deleteUser({required String personID}){
    FirebaseFirestore.instance.collection('users').doc(personID).delete().then((value){
      emit(DeletePersonSuccessfullyState());
    }).catchError((error)=>emit(DeletePersonErrorState()));
  }
}
