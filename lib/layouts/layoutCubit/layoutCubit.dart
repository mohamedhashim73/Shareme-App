import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
    emit(ChangeBottomNavIndex());
  }

  List<Widget> layoutWidgets = [
    HomeScreen(),
    SearchScreen(),
    Text(""),
    ChatScreen(),
    ProfileScreen(),
  ];

  // Method to get UserData when User open LayoutScreen
  UserDataModel? userData;       // first made an object from UserDataModel to use it on the App
  List<UserDataModel> usersData = [];
  List<String> usersID = [];
  void getUserData(){
    emit(GetUserDataLoadingState());
    FirebaseFirestore.instance.collection("users").doc(userID?? CacheHelper.getCacheData(key: 'uid')).get().then((value){
      userData = UserDataModel.fromJson(value.data()!);
      print("User Id after adding to Model is ${userData!.userName}");
      emit(GetUserDataSuccessState());
    }).catchError((e){
      print("Error during Getting User data is ${e.toString()}");
      emit(GetUserDataErrorState());
    });
  }

  // get all users data
  void getUsersData(){
    usersData = [];
    usersID = [];
    emit(GetUsersDataLoadingState());
    FirebaseFirestore.instance.collection('users').get()
    .then((value){
      value.docs.forEach((element) {
        print(element.id);
        if( userData!.userID != element.id)
        {
          usersID.add(element.id);
          usersData.add(UserDataModel.fromJson(element.data()));
        }
        emit(GetUsersDataSuccessState());
      });
    }).catchError((onError){emit(GetUsersDataErrorState());});
  }

  // *********** This logic related to Profile Image
  bool profileImageChosen = true ;   // this for show images or videos on Profile Screen as User's Tap

  // *********** This logic related to Upload Profile Image
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
      getUserData();
      emit(UpdateUserDataWithoutImageSuccessState());
    }).catchError((e)=>emit(UpdateUserDataWithoutImageErrorState()));
  }

  void updateUserDataWithImage({required String email,required String bio,required String userName}){
    emit(UpdateUserDataWithImageLoadingState());
    firebase_storage.FirebaseStorage.instance.ref().child("users/${Uri.file(userImageFile!.path).pathSegments.last}")
    .putFile(userImageFile!)
    .then((val){
      val.ref.getDownloadURL().then((imageUrl){
        // upload Update for userData to FireStore
        updateUserDataWithoutImage(email: email, bio: bio, userName: userName,image: imageUrl);
      }).catchError((onError)=>emit(UploadUserImageErrorState()));
    })
    .catchError((error){emit(UpdateUserDataWithImageErrorState());});
  }

  // made this function as if i change profile photo but canceled update imageProfileUrl will show on EditProfileScreen as i canceled update and i use profileImageUrl to be shown not userData!.image
  void canceledUpdateUserData(){
    emit(CanceledUpdateUserDataState());
  }

// methods for create new posts
  File? postImageFile;
  final postImagePicker = ImagePicker();
  void getPostImage() async{
    final pickedPostImage = await postImagePicker.getImage(source: ImageSource.gallery);
    if( pickedPostImage != null )
      {
        postImageFile = File(pickedPostImage.path);
        emit(ChosenPostImageSuccessfullyState());
      }
    else{
      emit(ChosenPostImageErrorState());
    }
  }

  void createPostWithoutImage({required String postCaption,String? postImage}){
    emit(UploadPostWithoutImageLoadingState()); // loading
    final model = PostDataModel(userData!.userName, userData!.userID, userData!.image,postCaption,timeNow.toString(),postImage?? "");
    FirebaseFirestore.instance.collection('users').doc(userData!.userID).collection('posts')
        .add(model.toJson()).then((value){
      getUserPosts();   // as there is update on Posts
      getUsersPosts();   // as there is an update for on person so I getUsersPosts
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

  void canceledImageForPost(){
    postImageFile = null;
    emit(CanceledImageForPostState());
  }

  // get posts for specific user to show on profile screen
  List<PostDataModel> userPostsData = [];    // as i send data as PostDataModel to FireStore
  void getUserPosts(){
    userPostsData = [];
    emit(GetUserPostsLoadingState());
    FirebaseFirestore.instance.collection('users').doc(CacheHelper.getCacheData(key: 'uid')??userData!.userID).collection('posts').snapshots()
    .listen((value){
      value.docs.forEach((element) {
        userPostsData.add(PostDataModel.fromJson(json: element.data()));
        emit(GetUserPostsSuccessState());
      });
    });
  }

  // get posts for all users to display on homeScreen
  List<PostDataModel> usersPostsData = [];    // as i send data as PostDataModel to FireStore
  void getUsersPosts(){
    usersPostsData = [];
    emit(GetUsersPostsLoadingState());
    FirebaseFirestore.instance.collection('users').get().then((value){
      value.docs.forEach((element) {
        element.reference.collection('posts').snapshots().listen((event){
          event.docs.forEach((val) {
            usersPostsData.add(PostDataModel.fromJson(json: val.data()));
          });
        });
        emit(GetUsersPostsSuccessState(usersPostsData.length));
      });
    }).catchError((error){print(error.toString());emit(GetUsersPostsErrorState());});
  }
}