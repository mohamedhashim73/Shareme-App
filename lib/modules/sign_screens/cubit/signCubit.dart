import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:social_app/modules/sign_screens/cubit/signStates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/shared/network/local/cacheHelper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignCubit extends Cubit<SignStates>{
  SignCubit() : super(InitialSignState());
  // method to get cubit from state that call it
  static SignCubit get(BuildContext context)=>BlocProvider.of(context);

  File? userImageFile;
  final pickerImage = ImagePicker();
  Future<void> getUserImageFile() async{
    final pickedImage = await pickerImage.getImage(source: ImageSource.gallery);
    if(pickedImage != null)
    {
      userImageFile = File(pickedImage.path);
      emit(ChosenUserImageSuccessfullyState());
    }
    else
    {
      emit(ChosenUserImageErrorState());
    }
  }

  // Method to Create User throw FirebaseAuth
  void createUser({required String email,required String password,required String userName,required String bio}){
    emit(CreateUserLoadingState());
    // createUserWithEmailAndPassword return UserCredential (( Future type ))
    FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((val){
      emit(CreateUserSuccessState());
      print("User created successfully with ID => ${val.user!.uid}");
      CacheHelper.saveCacheData(key: 'uid', val: val.user!.uid);    // to save User ID on Cache to go to home directly second time
      saveUserData(userName: userName, email: email, uid: val.user!.uid,bio: bio);      // save UserData on Cloud FireStore
    }).catchError((e){
      print(e.toString());
      emit(CreateUserErrorState(e.toString()));
    });
  }

  UserDataModel? userLoginData;
  // Method to save UserData on cloud fireStore
  void saveUserData({required String userName,required String email,required String uid,required String bio}){
    emit(SaveUserDataLoadingState());
    FirebaseStorage.instance.ref()
    .child("users/${Uri.file(userImageFile!.path).pathSegments.last}")
    .putFile(userImageFile!)
    .then((val){
      val.ref.getDownloadURL().then((imageUrl){
        print(imageUrl);
        UserDataModel model = UserDataModel(userName:userName,email: email,userID: uid,image: imageUrl,bio: bio,websiteUrl: "");
        FirebaseFirestore.instance.collection('users').doc(uid).set(model.toJson()).then((value){
          emit(SaveUserDataSuccessState());
        });
      });
    }).catchError((error){emit(SaveUserDataErrorState(error));});
  }

  // Method to Sign In to App using Email & Password that stored on Cloud fireStore
  void userLogin({required String email,required String password}){
    emit(UserLoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value){
      CacheHelper.saveCacheData(key: 'uid', val: value.user!.uid);
      emit(UserLoginSuccessState());
    }).catchError((onError)=>emit(UserLoginErrorState(onError.toString())));
  }

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    // userCredential mean data for user that i sign in with it
    UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
    CacheHelper.saveCacheData(key: 'uid', val: user.user!.uid);    // to save User ID on Cache to go to home directly second time
    UserDataModel model = UserDataModel(userName:user.user!.displayName,email: user.user!.email,userID: user.user!.uid,image: user.user!.photoURL,bio: "type your bio here",websiteUrl: "");
    FirebaseFirestore.instance.collection('users').doc(user.user!.uid).set(model.toJson()).then((value){
      emit(UserLoginSuccessState());
    });
  }
}