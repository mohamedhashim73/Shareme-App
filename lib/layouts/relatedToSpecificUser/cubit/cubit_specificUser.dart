import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/relatedToSpecificUser/cubit/states_specificUser.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/commentModel.dart';
import '../../../models/likeDataModel.dart';
import '../../../models/post_Data_Model.dart';
import '../../../models/storyModel.dart';
import '../../../shared/components/constants.dart';

class SpecificUserCubit extends Cubit<SpecificUserStates>{
  SpecificUserCubit() : super(InitialSpecificUserState());
  static SpecificUserCubit getCubit(BuildContext context)=>BlocProvider.of(context);

  // get specificUserData to show on his profile screen
  UserDataModel? specificUserData;
  void getMyData({required String specificUserID}){
    FirebaseFirestore.instance.collection("users").doc(specificUserID).get().then((value){
      specificUserData = UserDataModel.fromJson(value.data()!);
      emit(GetSpecificUserDataSuccessState());
    });
  }

  // get specificUserPostsData to show it on his profile
  List<PostDataModel> postsDataForSpecificUser = [];    // as i send data as PostDataModel to FireStore
  List<String> postsIDForSpecificUser = [];
  List<int> commentsNumberForSpecificUser = [];  // عشان اعرض عدد comments علي كل بوست في صفحه profile screen بتاعتي
  void getPostsForSpecificUser({required String specificUserID}){
    postsDataForSpecificUser = [];
    postsIDForSpecificUser = [];
    commentsNumberForSpecificUser = [];
    emit(GetPostsForSpecificUserLoadingState());
    FirebaseFirestore.instance.collection('users').doc(specificUserID).collection('posts').get().then((value){
      value.docs.forEach((element){
        element.reference.collection('comments').get().then((value){
          commentsNumberForSpecificUser.add(value.docs.length);
          postsIDForSpecificUser.add(element.id);
          postsDataForSpecificUser.add(PostDataModel.fromJson(json: element.data()));
          emit(GetPostsForSpecificUserSuccessState());  // عشان مع كل بوست يجيبيه يعمل ريفرش لل UI
        });
      });
    });
  }

  // get archived stories for specific user
  List<StoryDataModel> storiesForSpecificUser = [];
  void getStoriesForSpecificUser(String? specificUserID){
    storiesForSpecificUser = [];
    emit(GetArchivedStoriesForSpecificUserLoadingState());
    FirebaseFirestore.instance.collection('users').doc(specificUserID).collection('archivedStories').get().then((value){
      value.docs.forEach((element) {
        storiesForSpecificUser.add(StoryDataModel.fromJson(json: element.data()));
        emit(GetArchivedStoriesForSpecificUserSuccessState());
      });
      emit(GetArchivedStoriesForSpecificUserErrorState());
    });
  }

  // get likes for specific user on his posts
  bool likeStatusOnSpecificPostForSpecificUser = false ;
  void getLikeStatusSpecificPostForSpecificUser({required String postMakerID,required String postID})
  {
    likeStatusOnSpecificPostForSpecificUser = false ;
    emit(GetLikeStatusOnPostForSpecificUserLoadingState());
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').get().then((value){
      if( value.size > 0 ){
        value.docs.forEach((element) {
          if( element.data()['likeMakerID'] == userID )    // هنا بجيب الحاله تبعي بمعني انا عامل لايك ع بوست الشخص ده ولا لاء
          {
            likeStatusOnSpecificPostForSpecificUser = true ;
            emit(GetLikeStatusOnPostForSpecificUserSuccessState());
          }
          else
          {
            likeStatusOnSpecificPostForSpecificUser = false ;
            emit(GetLikeStatusOnPostForSpecificUserSuccessState());
          }
        });
      }
      else
      {
        likeStatusOnSpecificPostForSpecificUser = false ;
        emit(GetLikeStatusOnPostForSpecificUserSuccessState());
      }
    });
    emit(GetLikeStatusOnPostForSpecificUserSuccessState());
  }

  // add a like
  void addLike({required String postID,required BuildContext context,required String postMakerID}){
    final model = LikeDataModel(LayoutCubit.getCubit(context).userData!.image,LayoutCubit.getCubit(context).userData!.userID,LayoutCubit.getCubit(context).userData!.userName,DateTime.now().toString(),true);
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').doc(LayoutCubit.getCubit(context).userData!.userID).set(model.toJson()).then((value){
      // add a like successfully on his post هنا انا خزنت الداتا ده ف likes عنده هو مش عندي
    });
    emit(AddLikeSuccessfullyFromSpecificUserState());
  }

  void removeLike({required String postID,required BuildContext context,required String postMakerID}){
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').doc(LayoutCubit.getCubit(context).userData!.userID).delete().then((value){
      // add a like successfully on his post هنا انا خزنت الداتا ده ف likes عنده هو مش عندي
    });
    emit(RemoveLikeSuccessfullyFromSpecificUserState());
  }

  // empty the posts for specific user ده عشان لو عملت لايك او حاجه ع البوست بتاع الشخص اللي انا دخلت ع البروفايل بتاعه ميحصلش تكرار
  void emptyUsersPostsDataAndCallMethodForSpecificUser() async {
    await Future.delayed(const Duration(milliseconds: 1)).then((value){
      postsDataForSpecificUser = [];
    });
    getPostsForSpecificUser(specificUserID: specificUserData!.userID!);
  }

  void openWebsiteUrl({required String websiteUrl}) async{
    final url = Uri.parse(websiteUrl);
    if( await canLaunchUrl(url) && websiteUrl != "" )
    {
      await launchUrl(url);
    }
    else
    {
      emit(ErrorDuringOpenWebsiteUrlForSpecificUserState());
    }
  }
}