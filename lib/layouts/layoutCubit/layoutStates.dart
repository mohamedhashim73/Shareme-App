abstract class LayoutStates{}

class InitialLayoutState extends LayoutStates{}

class ChangeBottomNavIndex extends LayoutStates{}

class GetUserDataLoadingState extends LayoutStates{}

class GetUserDataSuccessState extends LayoutStates{}

class GetUserDataErrorState extends LayoutStates{}

class GetAllUsersDataLoadingState extends LayoutStates{}

class GetAllUsersDataSuccessState extends LayoutStates{}

class GetAllUsersDataErrorState extends LayoutStates{}

class GetProfileImageLoadingState extends LayoutStates{}

class GetProfileImageSuccessState extends LayoutStates{}

class GetProfileImageErrorState extends LayoutStates{}

class UpdateUserDataWithoutImageLoadingState extends LayoutStates{}

class UpdateUserDataWithoutImageSuccessState extends LayoutStates{}

class UpdateUserDataWithoutImageErrorState extends LayoutStates{}

class UpdateUserDataWithImageLoadingState extends LayoutStates{}

class UpdateUserDataWithImageErrorState extends LayoutStates{}

class UploadUserImageErrorState extends LayoutStates{}

class CanceledUpdateUserDataState extends LayoutStates{}

class ChosenImageSuccessfullyState extends LayoutStates{}

class ChosenImageErrorState extends LayoutStates{}

// for Create new post
class ChosenPostImageSuccessfullyState extends LayoutStates{}

class ChosenPostImageErrorState extends LayoutStates{}

class UploadPostWithoutImageLoadingState extends LayoutStates{}

class UploadPostWithoutImageSuccessState extends LayoutStates{}

class UploadPostWithoutImageErrorState extends LayoutStates{}

class UploadPostWithImageLoadingState extends LayoutStates{}

class UploadPostWithImageErrorState extends LayoutStates{}

class UploadImageForPostErrorState extends LayoutStates{}

class CanceledImageForPostState extends LayoutStates{}

// for specific user
class GetPostsDataForSpecificUserLoadingState extends LayoutStates{}

class GetPostsDataForSpecificUserSuccessState extends LayoutStates{}

class GetPostsDataForSpecificUserErrorState extends LayoutStates{}

 // for all users
class GetPostsDataForAllUsersLoadingState extends LayoutStates{}

class GetPostsDataForAllUsersSuccessState extends LayoutStates{
  final int usersPostsLength;
  GetPostsDataForAllUsersSuccessState(this.usersPostsLength);
}

class GetPostsDataForAllUsersErrorState extends LayoutStates{}

