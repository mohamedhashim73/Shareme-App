import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/layouts/cubit/layoutStates.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:social_app/modules/home/homeScreen.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/modules/search/searchScreen.dart';
import 'package:social_app/modules/settings/settingsScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'dart:io';
import 'package:social_app/shared/network/local/cacheHelper.dart';

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
    SettingsScreen(),
    ProfileScreen(),
  ];

  // Method to get UserData when User open LayoutScreen
  UserDataModel? userData;       // first made an object from UserDataModel to use it on the App
  void getUserData(){
    emit(GetUserDataLoadingState());
    FirebaseFirestore.instance.collection("users").doc(userID?? CacheHelper.getCacheData(key: 'uid')).get().then((value){
      userData = UserDataModel.fromJson(value.data()!);
      print("User Id after adding to Model is ${userData!.name}");
      emit(GetUserDataSuccessState());
    }).catchError((e){
      print("Error during Getting User data is ${e.toString()}");
      emit(GetUserDataErrorState());
    });
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

  void updateUserDataWithoutImage({required String name,required String email,required String bio,required String userName,String? image}){
    emit(UpdateUserDataWithoutImageLoadingState());
    final model = UserDataModel(name: name,image: image?? userData!.image,email: email,bio: bio,userName: userName,uid: userData!.uid);
    FirebaseFirestore.instance.collection('users').doc(userData!.uid)
    .update(model.toJson())
    .then((value){
      getUserData();
      emit(UpdateUserDataWithoutImageSuccessState());
    }).catchError((e)=>emit(UpdateUserDataWithoutImageErrorState()));
  }

  void updateUserDataWithImage({required String name,required String email,required String bio,required String userName}){
    emit(UpdateUserDataWithImageLoadingState());
    firebase_storage.FirebaseStorage.instance.ref().child("users/${Uri.file(userImageFile!.path).pathSegments.last}")
    .putFile(userImageFile!)
    .then((val){
      val.ref.getDownloadURL().then((imageUrl){
        // upload Update for userData to FireStore
        updateUserDataWithoutImage(name: name, email: email, bio: bio, userName: userName,image: imageUrl);
      }).catchError((onError)=>emit(UploadUserImageErrorState()));
    })
    .catchError((error){emit(UpdateUserDataWithImageErrorState());});
  }

  // made this function as if i change profile photo but canceled update imageProfileUrl will show on EditProfileScreen as i canceled update and i use profileImageUrl to be shown not userData!.image
  void canceledUpdateUserData(){
    emit(CanceledUpdateUserDataState());
  }

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

  // methods for create new posts

  void createPostWithoutImage({required String postCaption,String? postImage}){
    emit(UploadPostWithoutImageLoadingState()); // loading
    final model = PostDataModel(userData!.userName, userData!.uid, userData!.image,postCaption,timeNow.toString(),postImage?? "");
    FirebaseFirestore.instance.collection('posts')
        .add(model.toJson()).then((value){
      // here must write getPostsData as if there is an update
      getUserPostsData();   // as there is update on Posts
      emit(UploadPostWithoutImageSuccessState()); // success
    }).catchError((error){
      print(error.toString());
      emit(UploadPostWithoutImageErrorState());  // error
    });
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

  List<PostDataModel> posts = [];    // as i send data as PostDataModel to FireStore
  void getUserPostsData(){
    posts = [];
    emit(GetUserPostsDataLoadingState());
    FirebaseFirestore.instance.collection('posts')
    .get()
    .then((value){
      value.docs.forEach((element) {
        // loop for each doc with its id (( post ))
        posts.add(PostDataModel.fromJson(json: element.data()));
      });
      emit(GetUserDataSuccessState());
    })
    .catchError((error)=>emit(GetUserPostsDataErrorState()));
  }
}