import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/relatedToSpecificUser/cubit/cubit_specificUser.dart';
import 'package:social_app/layouts/relatedToSpecificUser/cubit/states_specificUser.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../../shared/components/components.dart';
import '../../commentsViewScreen/commentsViewScreen.dart';
import '../../likesViewScreen/likesViewScreen.dart';

// خلي بالك في حاجه لازم اعدلها بخصوص ظهور عدد الكومنتات اما افتح بوست بتاعي عشن عدلت علي صفحه الكومنتات واستعملت حاجه تانيه بدل setState
class PostDetailsScreenForSpecificUser extends StatelessWidget{
  String postID;  // as it not saved with post data on fireStore so i will get when i call this state from PostsID that use in usersPostsData
  PostDataModel model;  // to get post data to be able to update it throw its id and the maker of it
  int commentsNumber ;
  PostDetailsScreenForSpecificUser({super.key,required this.model,required this.postID,required this.commentsNumber});

  final captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          SpecificUserCubit.getCubit(context).getLikeStatusSpecificPostForSpecificUser(postMakerID: model.userID!, postID: postID);  // عشان اجيب اذا كنت عامل لايك او لاء
          return BlocConsumer<SpecificUserCubit,SpecificUserStates>(
              listener: (context,state){},
              builder: (context,state){
                final cubit = SpecificUserCubit.getCubit(context);
                return Scaffold(
                    backgroundColor: whiteColor,
                    appBar: AppBar(
                      title: const Text("Post"),titleSpacing: 0,
                      leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios), onTap: (){Navigator.pop(context);}),
                    ),
                    body: model.userID == null || state is GetLikeStatusOnPostForSpecificUserLoadingState ?
                    const Center(child: CircularProgressIndicator(color: mainColor,),) :
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: buildPostItem(context: context,model: model,state: state,cubit: cubit),
                    )
                );
              }
          );
        }
    );
  }

  Widget buildPostItem({required BuildContext context,required PostDataModel model,required SpecificUserStates state ,required SpecificUserCubit cubit}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10,right: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  clipBehavior: Clip.hardEdge,
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.5))
                  ),
                  child : model.userImage != null ? Image.network(cubit.specificUserData!.image.toString(),fit: BoxFit.cover,) : const Text("")
              ),
              const SizedBox(width: 15,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cubit.specificUserData!.userName.toString(),style: const TextStyle(fontSize: 16),),
                  const SizedBox(height: 2,),
                  Text(model.postDate.toString(),style: Theme.of(context).textTheme.caption,),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: model.postCaption != null ? Text(model.postCaption!,style: const TextStyle(fontSize: 18,height: 1.4),) : const Text(''),
        ),
        if( model.postImage != '' )      // as if there is no image for a post , postImage that on post field on fireStore contain '' and this instead of imageUrl
          const SizedBox(height: 10,),
        if( model.postImage != '' )      // لو مش هعمل الاوبشن بتاع حذف صوره البوست ف مش بحاجه لل stack
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1),bottom: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1))
            ),
            child: Image.network(model.postImage!,fit: BoxFit.cover),
            // Image.network(cubit.postImageUrl!,fit: BoxFit.fitHeight,height: 250),
          ),
        const SizedBox(height: 12.5,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: InkWell(
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context){return CommentsScreen(postID: postID, postMakerID: model.userID!,comeFromHomeScreenNotPostDetailsScreen: false,);}));
              },
              child: commentsNumber != null ?
              // عملت حوار add comment success عشان اما يضيف كومنت يحصل ريفرش لل UI بحيث يظهر انه زاد واحد
              Text("$commentsNumber comments",style: Theme.of(context).textTheme.caption,) :
              Text("0 comments",style: Theme.of(context).textTheme.caption,),
            ),
          ),
        ),
        buildDividerItem(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      // مستعمل stateFulBuilder عشان لو حصل تعديل علي قيمه likeStatus يعمل refresh لل favoriteIcon فقط
                      child: StatefulBuilder(
                        builder: (context,setState){
                          return GestureDetector(
                            onTap:()
                            {
                              setState((){
                                if( cubit.likeStatusOnSpecificPostForSpecificUser == true )
                                {
                                  cubit.removeLike(postID: postID,context: context,postMakerID: model.userID!);
                                  cubit.likeStatusOnSpecificPostForSpecificUser = false ;
                                  LayoutCubit.getCubit(context).usersPostsData.clear();
                                  LayoutCubit.getCubit(context).getUsersPosts();
                                }
                                else
                                {
                                  cubit.addLike(postID: postID,context: context,postMakerID: model.userID!);
                                  cubit.likeStatusOnSpecificPostForSpecificUser = true ;   // لأن انا بلعب علي لو قيمتها لا تساوي صفر يبقي كده في قيمه
                                  LayoutCubit.getCubit(context).usersPostsData.clear();
                                  LayoutCubit.getCubit(context).getUsersPosts();
                                }
                              });
                            },
                            // عملت لا يساوي صفر عشان انا قلت لو id مش نفسه بتاعي خزن صفر طب لو بتاعي هخزن الداتا بتاعت likePostData في List عشان اعرضها في صفحه اللايكات
                            child: Icon(Icons.favorite,color: cubit.likeStatusOnSpecificPostForSpecificUser == false ? Colors.grey : Colors.red,size: 22),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 7,),
                    GestureDetector(
                        onTap: ()
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>LikesViewScreen(postID: postID, postMakerID: model.userID!)));
                        },
                        child: Text("like",style: Theme.of(context).textTheme.caption)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(onTap:(){},child: const Icon(Icons.messenger_outline,color: Colors.grey,size: 22,)),
                    const SizedBox(width: 7,),
                    Text("comments",style: Theme.of(context).textTheme.caption),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(onTap:(){},child: const Icon(Icons.send,color: Colors.grey,size: 22,)),
                    const SizedBox(width: 7,),
                    Text("share",style: Theme.of(context).textTheme.caption,),
                  ],
                ),
              )
            ],
          ),
        ),
        buildDividerItem(),
        const SizedBox(height: 7.5),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
              [
                Row(
                  children:
                  [
                    InkWell(
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(SpecificUserCubit.getCubit(context).specificUserData!.image!),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                        child: InkWell(
                          onTap: ()
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (context){return CommentsScreen(postID: postID, postMakerID: model.userID!,comeFromHomeScreenNotPostDetailsScreen: false,);}));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey.withOpacity(0.5))
                            ),
                            child: Text("Add a new comment....",style: Theme.of(context).textTheme.caption,),
                          ),
                        )
                    )
                  ],
                )
              ],
            )
        ),
        const SizedBox(height: 12.0,),
      ],
    );
  }
}
