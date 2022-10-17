import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:social_app/models/commentModel.dart';
import 'package:social_app/models/likeDataModel.dart';
import 'package:social_app/models/messgaeDataModel.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/models/storyModel.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:social_app/modules/home/homeScreen.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/modules/search/searchScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'dart:io';
import 'package:social_app/shared/network/local/cacheHelper.dart';
import 'package:url_launcher/url_launcher.dart';
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

  List<Widget> layoutWidgets = [ const HomeScreen(), SearchScreen(), const ChatScreen(), ProfileScreen(),];

  /*
    1) get My Data to show in Profile screen and use it in other screens
  */
  UserDataModel? userData;
  void getMyData(){
    FirebaseFirestore.instance.collection("users").doc(userID??CacheHelper.getCacheData(key: 'uid')).get().then((value){
      userData = UserDataModel.fromJson(value.data()!);
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

  void updateUserDataWithoutImage({required String email,required String bio,required String userName,String? image,required String websiteUrl}){
    emit(UpdateUserDataWithoutImageLoadingState());
    final model = UserDataModel(image: image?? userData!.image,email: email,bio: bio,userName: userName,userID: userData!.userID,websiteUrl: websiteUrl);
    FirebaseFirestore.instance.collection('users').doc(userData!.userID)
    .update(model.toJson())
    .then((value){
      getMyData();  // هنا مش عارف المشكله بتاعه اما ارفع الداتا اللي كان مكتوب داخل textFormField بيتغير وبيأخد الحاجه القديمه عما يخرج من صفحه update
      emit(UpdateUserDataWithoutImageSuccessState());
    }).catchError((e)=>emit(UpdateUserDataWithoutImageErrorState()));
  }

  void updateUserDataWithImage({required String email,required String bio,required String userName,required String websiteUrl}){
    emit(UpdateUserDataWithImageLoadingState());
    firebase_storage.FirebaseStorage.instance.ref()
        .child("users/${Uri.file(userImageFile!.path).pathSegments.last}")
        .putFile(userImageFile!)
        .then((val){
          val.ref.getDownloadURL().then((imageUrl){
            // upload Update for userData to FireStore
            updateUserDataWithoutImage(email: email, bio: bio, userName: userName,image: imageUrl,websiteUrl: websiteUrl);
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
      getUsersPosts();
      emit(UploadPostWithoutImageSuccessState()); // success
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
    }).catchError((onError) {emit(UploadPostWithImageErrorState());});
  }

  void updatePost({required String postMakerID,required String postID,required String postMakerName,required String postMakerImage,required String postCaption,required String postDate,required String postImage}){
    emit(UpdatePostLoadingState());
    final model = PostDataModel(postMakerName, postMakerID, postMakerImage, postCaption, postDate, postImage);
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).update(model.toJson()).then((value)
    {
      getUsersPosts();
      emit(UpdatePostSuccessfullyState());
    });
  }

  void deletePost({required String postMakerID,required String postID}){
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).delete().then((value){
      getUsersPosts();
      emit(DeletePostSuccessfullyState());
    });
  }

  // this method to open website link that exist under the bio in profile Screen
  void openWebsiteUrl({required String websiteUrl}) async{
    final url = Uri.parse(websiteUrl);
    if( await canLaunchUrl(url) && websiteUrl != "" )
    {
      await launchUrl(url);
    }
    else
    {
      emit(ErrorDuringOpenWebsiteUrlState());
    }
  }

  // this method for make usersPostsData empty to call UserPostsData method to get posts without any duplicate => uses after create post || delete || update post
  void emptyUsersPostsDataAndCallMethod() async {
    await Future.delayed(const Duration(milliseconds: 1)).then((value){
      usersPostsData = [];
    });
    getUsersPosts();
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
  List<int> myCommentsNumber = [];  // عشان اعرض عدد comments علي كل بوست في صفحه profile screen بتاعتي
  void getMyPosts(){
    userPostsData.clear();
    myPostsID.clear();
    myCommentsNumber.clear();
    emit(GetUserPostsLoadingState());
    FirebaseFirestore.instance.collection('users').doc(userData!.userID!).collection('posts').get().then((value){
          value.docs.forEach((element){
            element.reference.collection('comments').get().then((value){
              myCommentsNumber.add(value.docs.length);
              myPostsID.add(element.id);
              userPostsData.add(PostDataModel.fromJson(json: element.data()));
              emit(GetUserPostsSuccessState());
            });
          });
        });
  }

  // ***************************************************************************

  /*
    6) get all posts for all users to show on Home Screen
  */

  List<PostDataModel> usersPostsData = [];
  List<String> postsID = [];
  List<bool> likesPostsData = [];
  List<int> commentsNumber = [];  // عشان اعرض عدد comments علي كل بوست في صفحه homeScreen
  void getUsersPosts(){
      commentsNumber.clear();
      usersPostsData.clear();
      postsID.clear();
      likesPostsData.clear();
      emit(GetUsersPostsLoadingState());
      FirebaseFirestore.instance.collection('users').get().then((value){
        value.docs.forEach((element){
          element.reference.collection('posts').get().then((event){
            event.docs.forEach((postData){
              postData.reference.collection('comments').get().then((val){
                postData.reference.collection('likes').doc(userData!.userID!).get().then((value){
                  if( value.exists )
                    {
                      likesPostsData.add(true);
                      commentsNumber.add(val.docs.length);
                      postsID.add(postData.id);   // store posts ID to use it when I add a comment || get comments for specific post
                      usersPostsData.add(PostDataModel.fromJson(json: postData.data()));
                      emit(GetUsersPostsSuccessState(usersPostsData.length));
                    }
                  else
                    {
                      likesPostsData.add(false);
                      commentsNumber.add(val.docs.length);
                      postsID.add(postData.id);   // store posts ID to use it when I add a comment || get comments for specific post
                      usersPostsData.add(PostDataModel.fromJson(json: postData.data()));
                      emit(GetUsersPostsSuccessState(usersPostsData.length));
                    }
                });
              });
            });
          });
        });
      });
  }

  // ***************************************************************************

  /*
    7) add a like to a post || remove it
  */

  void addLike({required String postID,required String postMakerID}){
    final model = LikeDataModel(userData!.image,userData!.userID,userData!.userName,DateTime.now().toString(),true);
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').doc(userData!.userID).set(model.toJson()).then((value){
      // add a like successfully on his post هنا انا خزنت الداتا ده ف likes عنده هو مش عندي
    });
    emit(AddLikeSuccessfullyState());
  }

  void removeLike({required String postID,required String postMakerID}){
    FirebaseFirestore.instance.collection('users').get().then((value){
      FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').doc(userData!.userID).delete().then((value){
        // delete a like successfully from his fireStore
      });
      emit(RemoveLikeSuccessfullyState());
    });
  }

  // get likes Data to display it on LikesViewScreen
  List<LikeDataModel> likesData = [];
  void getLikes({required String postMakerID,required String postID}){
    emit(GetLikesLoadingState());
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').snapshots().listen((value){
      likesData = [];
      value.docs.forEach((element){
        if( element.data()['isLike'] == true )
        {
          likesData.add(LikeDataModel.fromJson(json: element.data()));
        }
      });
      emit(GetLikesSuccessfullyState());
    });
  }

  // this method to get likeStatus for me on a specific post especially when I open postDetailsScreen
  // بمعني ان الداله ده عاملها اما اضغط علي بوست في صفحه البروفايل ويفتح البوست لوحده هقدر اعرف م خلال الداله ده اذا كنت عامل لايك او لاء
  bool likeStatusForMeOnSpecificPost = false ;
  void getLikeStatusForMeOnSpecificPost({required String postMakerID,required String postID})
  {
    likeStatusForMeOnSpecificPost = false ;
    emit(GetLikeStatusForMeOnSpecificPostLoadingState());
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('likes').get().then((value){
      if( value.size > 0 ){
        value.docs.forEach((element) {
          if( element.data()['likeMakerID'] == userData!.userID )
          {
            likeStatusForMeOnSpecificPost = true ;
            emit(GetLikeStatusForMeOnSpecificPostSuccessState());
          }
          else
          {
            likeStatusForMeOnSpecificPost = false ;
            emit(GetLikeStatusForMeOnSpecificPostSuccessState());
          }
        });
      }
      else
      {
        likeStatusForMeOnSpecificPost = false ;
        emit(GetLikeStatusForMeOnSpecificPostSuccessState());
      }
    });
    emit(GetLikeStatusForMeOnSpecificPostSuccessState());
  }
  // ***************************************************************************

  /*
    8) add a comment to a post || remove it || get comments for specific post using its ID
  */

  // add comment to specific post with its id
  void addComment({required String comment,required String postID,required String postMakerID}){
    final model = CommentDataModel(comment, userData!.userID, userData!.image, userData!.userName,DateTime.now().toString(), postID);
    FirebaseFirestore.instance.collection('users').doc(postMakerID).collection('posts').doc(postID).collection('comments').add(model.toJson()).then((value){
      // add a like successfully on his post هنا انا خزنت الداتا ده ف likes عنده هو مش عندي
    });
    emit(AddCommentSuccessState());
  }

  // use it when I open commentsScreen => show comments using this method.
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
    emit(GetMessageLoadingState());
    FirebaseFirestore.instance.collection('users').doc(userData!.userID).collection('chats').doc(messageReceiverID).collection('messages')
        .orderBy('messageDateTime')
        .snapshots()
        .listen((val)
         {
           messages.clear();
           val.docs.forEach((element) {
             messages.add(MessageDataModel.fromJson(json: element.data()));
           });
           // مهم جدا .....الفكره هنا ان كل اما يجيب مسدج بعمل refresh لل UI ف عشان كده ظهرت ع طول وده لازم اعملها في صفحه home screen
           emit(GetMessageSuccessState());
         });
  }

  // ***************************************************************************
  /*
    10) delete a person from App completely (( optional for me ))
  */
  void deleteUser({required String personID}){
    FirebaseFirestore.instance.collection('users').doc(personID).delete().then((value){
      emit(DeletePersonSuccessfullyState());
    }).catchError((error)=>emit(DeletePersonErrorState()));
  }
  
  // related to search screen (( search for user by his userName ))
  List<UserDataModel> searchData = [];
  void searchForUser({required String input}){
    searchData = [];
    emit(SearchForUserLoadingState());
    // arrayContain will get all userName that contain input which user will type on textFormField
    FirebaseFirestore.instance.collection('users').where('userName',whereIn: [input]).get().then((value){
      value.docs.forEach((element) {
        searchData.add(UserDataModel.fromJson(element.data()));
        emit(SearchForUserSuccessState());
      });
    });
  }

  /*
    11) add a story to archived stories || delete it
   */

   // method for adding a story
  File? storyImage;
  void getStoryImage() async {
    final storyPicked = await ImagePicker().getImage(source: ImageSource.gallery);
    if( storyPicked != null )
      {
        storyImage = File(storyPicked.path);
        print("chosen story image successfully");
        emit(StoryImageChosenSuccessState());
      }
    else
      {
        print("Error during get story Image for Archived stories");
        emit(StoryImageChosenErrorState());
      }
  }

  // method for create story on archived stories
  void createStory({required String storyTitle}){
    emit(CreateStoryLoadingState());
    if( storyImage != null )
    {
      firebase_storage.FirebaseStorage.instance.ref()
        .child("stories/${Uri.file(storyImage!.path).pathSegments.last}")
        .putFile(storyImage!)
        .then((val){
          val.ref.getDownloadURL().then((storyUrl){
            final model = StoryDataModel(userData!.userName, userData!.userID, storyUrl, storyTitle, Jiffy(DateTime.now().toString()).yMMMMd);
            // upload story data on fireStore
            FirebaseFirestore.instance.collection('users').doc(userData!.userID).collection('archivedStories').add(model.toJson()).then((value){
              // save data on List<storyDataModel> to display it on profile screen
              emit(CreateStorySuccessState());
            });
          });
    });
    }
  }

  void canceledImageForStory(){
    storyImage = null;
    emit(CanceledImageForPostState());
  }

  // method for get stories for user by his ID
  List<StoryDataModel> storiesData = [];
  void getMyStories(String? storiesMakerID){
    storiesData = [];
    emit(GetArchivedStoriesLoadingState());
    FirebaseFirestore.instance.collection('users').doc(storiesMakerID??userData!.userID).collection('archivedStories').get().then((value){
      value.docs.forEach((element) {
        storiesData.add(StoryDataModel.fromJson(json: element.data()));
        emit(GetArchivedStoriesSuccessState());
      });
      emit(GetArchivedStoriesSuccessState());
    });
  }

  // this var to identify if i open comment screen from home or from profile screen => very important
  bool openCommentsThrowPostDetailsScreen = false;
}
