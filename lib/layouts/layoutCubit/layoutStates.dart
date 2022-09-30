abstract class LayoutStates{}

class InitialLayoutState extends LayoutStates{}

class ChangeBottomNavIndex extends LayoutStates{}

class GetUserDataLoadingState extends LayoutStates{}

class GetUserDataSuccessState extends LayoutStates{}

class GetUserDataErrorState extends LayoutStates{}

class GetUsersDataLoadingState extends LayoutStates{}

class GetUsersDataSuccessState extends LayoutStates{}

class GetUsersDataErrorState extends LayoutStates{}

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
class GetUserPostsLoadingState extends LayoutStates{}

class GetUserPostsSuccessState extends LayoutStates{}

 // for all users
class GetUsersPostsLoadingState extends LayoutStates{}

class GetUsersPostsSuccessState extends LayoutStates{
  final int usersPostsLength;
  GetUsersPostsSuccessState(this.usersPostsLength);
}

class GetUsersPostsErrorState extends LayoutStates{}

