import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:social_app/modules/sign_screens/cubit/signStates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/shared/network/local/cacheHelper.dart';

import '../../../shared/components/constants.dart';

class SignCubit extends Cubit<SignStates>{
  SignCubit() : super(InitialSignState());
  // method to get cubit from state that call it
  static SignCubit get(BuildContext context)=>BlocProvider.of(context);

  // Method to Create User throw FirebaseAuth
  void createUser({required String email,required String password,required String name,required String userName}){
    emit(CreateUserLoadingState());
    // createUserWithEmailAndPassword return UserCredential (( Future type ))
    FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((val){
      emit(CreateUserSuccessState());
      print("User created successfully with ID => ${val.user!.uid}");
      CacheHelper.saveCacheData(key: 'uid', val: val.user!.uid);    // to save User ID on Cache to go to home directly second time
      saveUserData(name: name,userName: userName, email: email, uid: val.user!.uid);      // save UserData on Cloud FireStore
    }).catchError((e){
      print(e.toString());
      emit(CreateUserErrorState(e.toString()));
    });
  }

  UserDataModel? userLoginData;
  // Method to save UserData on cloud fireStore
  void saveUserData({required String name,required String userName,required String email,required String uid}){
    emit(SaveUserDataLoadingState());
    UserDataModel model = UserDataModel(name: name,userName:userName,email: email,uid: uid,image: defaultUserImage,bio: "write your bio ...");
    FirebaseFirestore.instance.collection('users').doc(uid).set(model.toJson()).then((value){
      emit(SaveUserDataSuccessState());
    }).catchError((e)=>emit(SaveUserDataErrorState(e)));
  }

  // Method to Sign In to App using Email & Password that stored on Cloud fireStore
  void userLogin({required String email,required String password}){
    emit(UserLoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value){
      emit(UserLoginSuccessState());
      CacheHelper.saveCacheData(key: 'uid', val: value.user!.uid);
    }).catchError((onError)=>emit(UserLoginErrorState(onError.toString())));
  }

}