abstract class LayoutStates{}

class InitialLayoutState extends LayoutStates{}

class ChangeBottomNavIndexState extends LayoutStates{}

// for get my data

class GetUserDataLoadingState extends LayoutStates{}

class GetUserDataSuccessState extends LayoutStates{}

class GetUserDataErrorState extends LayoutStates{}

// for get users data to show in chat screen and search for a user using it

class GetUsersDataSuccessState extends LayoutStates{}

// for update my data either profileImage , name , email , bio , website link

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

// for Create new post || update post || delete post

class ChosenPostImageSuccessfullyState extends LayoutStates{}

class ChosenPostImageErrorState extends LayoutStates{}

class UploadPostWithoutImageLoadingState extends LayoutStates{}

class UploadPostWithoutImageSuccessState extends LayoutStates{}

class UploadPostWithoutImageErrorState extends LayoutStates{}

class UploadPostWithImageLoadingState extends LayoutStates{}

class UploadPostWithImageErrorState extends LayoutStates{}

class UpdatePostLoadingState extends LayoutStates{}

class UpdatePostSuccessfullyState extends LayoutStates{}

class UpdatePostErrorState extends LayoutStates{}

class DeletePostSuccessfullyState extends LayoutStates{}

class DeletePostErrorState extends LayoutStates{}

class UploadImageForPostErrorState extends LayoutStates{}

class CanceledImageForPostState extends LayoutStates{}

// for get my posts

class GetUserPostsLoadingState extends LayoutStates{}

class GetUserPostsSuccessState extends LayoutStates{}

 // for get All posts for all users

class GetUsersPostsLoadingState extends LayoutStates{}

class GetUsersPostsSuccessState extends LayoutStates{
  final int usersPostsLength;
  GetUsersPostsSuccessState(this.usersPostsLength);
}

class GetUsersPostsErrorState extends LayoutStates{}

// for add a comment and like on post || delete it

class AddLikeSuccessfullyState extends LayoutStates{}

class AddLikeErrorState extends LayoutStates{}

class RemoveLikeSuccessfullyState extends LayoutStates{}

class RemoveLikeErrorState extends LayoutStates{}

class GetLikeStatusForMeOnSpecificPostLoadingState extends LayoutStates{}

class GetLikeStatusForMeOnSpecificPostSuccessState extends LayoutStates{}

class GetLikesLoadingState extends LayoutStates{}

class GetLikesSuccessfullyState extends LayoutStates{}

class AddCommentSuccessState extends LayoutStates{}

class GetCommentsLoadingState extends LayoutStates{}

class GetCommentsSuccessState extends LayoutStates{}

// for send a message to specific user || get messages from specific user

class SendMessageSuccessState extends LayoutStates{}

class SendMessageLoadingState extends LayoutStates{}

class GetMessageSuccessState extends LayoutStates{}

class GetMessageLoadingState extends LayoutStates{}

// delete person from app completely || it's optional for me

class DeletePersonSuccessfullyState extends LayoutStates{}

class DeletePersonErrorState extends LayoutStates{}

// related to search screen

class SearchForUserLoadingState extends LayoutStates{}

class SearchForUserSuccessState extends LayoutStates{}

class SearchForUserErrorState extends LayoutStates{}

// related to archived story

class StoryImageChosenSuccessState extends LayoutStates{}

class StoryImageChosenErrorState extends LayoutStates{}

class CreateStorySuccessState extends LayoutStates{}

class CreateStoryLoadingState extends LayoutStates{}

class CanceledImageForStoryState extends LayoutStates{}

class GetArchivedStoriesLoadingState extends LayoutStates{}

class GetArchivedStoriesSuccessState extends LayoutStates{}

