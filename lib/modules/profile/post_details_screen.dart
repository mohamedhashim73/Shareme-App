import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../layouts/commentsViewScreen/commentsViewScreen.dart';
import '../../layouts/homeLayoutScreen/home_layout_screen.dart';
import '../../layouts/layoutCubit/layoutCubit.dart';
import '../../layouts/layoutCubit/layoutStates.dart';
import '../../layouts/likesViewScreen/likesViewScreen.dart';
import '../../shared/components/components.dart';
import '../edit_post/edit_post_screen.dart';

// خلي بالك في حاجه لازم اعدلها بخصوص ظهور عدد الكومنتات اما افتح بوست بتاعي عشن عدلت علي صفحه الكومنتات واستعملت حاجه تانيه بدل setState
class PostDetailsScreen extends StatelessWidget{
  // هنا محتاج اجيب postsID بس للبوستات بتاعتي عشان ابعت ID اما استدعي state ده عشان لو عاوز اعمل update or delete for post
  // هستدعيها اما اشغط علي صوره البوست في صفحه البروفايل بتاعي
  String postID;  // as it not saved with post data on fireStore so i will get when i call this state from PostsID that use in usersPostsData
  PostDataModel model;  // to get post data to be able to update it throw its id and the maker of it
  int commentsNumber ;

  PostDetailsScreen({super.key,required this.model,required this.postID,required this.commentsNumber});

  final captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state)
        {
          if( state is AddCommentSuccessState )
            {
              commentsNumber = commentsNumber + 1 ;
            }
        },
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: const Text("Post"),titleSpacing: 0,
              leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios), onTap: (){Navigator.pop(context);}),
            ),
            body: model.userID == null ?
            const Center(child: CircularProgressIndicator(color: mainColor,),) :
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: buildPostItem(context: context,model: model,state: state,cubit: cubit),
            )
          );
        }
    );
  }

  Widget buildPostItem({required BuildContext context,required PostDataModel model,required LayoutStates state ,required LayoutCubit cubit}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
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
                  child : model.userImage != null ? Image.network(cubit.userData!.image.toString(),fit: BoxFit.cover,) : const Text("")
              ),
              const SizedBox(width: 15,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cubit.userData!.userName.toString(),style: const TextStyle(fontSize: 16),),
                  const SizedBox(height: 2,),
                  Text(model.postDate.toString(),style: Theme.of(context).textTheme.caption,),
                ],
              ),
              const Spacer(),
              GestureDetector(
                  child: Icon(Icons.more_vert,color: blackColor.withOpacity(0.5),size: 25,),
                  onTap: ()
                  {
                    showMenu(
                        context: context,
                        elevation: 1,
                        position: const RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),
                        items:
                        [
                          PopupMenuItem(
                              onTap: () {},
                              child: GestureDetector(
                                child: const Text('update post'),
                                onTap: ()
                                {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EditPostScreen(model: model,postID: postID,)));
                                },
                              )
                          ),
                          PopupMenuItem(
                            onTap: ()
                            {
                              cubit.deletePost(postMakerID: model.userID!, postID: postID);
                            },
                            child: const Text('delete post'),
                          ),
                        ]
                    );
                  },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: model.postCaption != null ? Text(model.postCaption!,style: const TextStyle(fontSize: 18),) : const Text(''),
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
            alignment: AlignmentDirectional.topStart,
            child: InkWell(
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context){return CommentsScreen(postID: postID, postMakerID: model.userID!);}));
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
                    GestureDetector(
                      onTap:()
                      {
                      },
                      child: const Icon(Icons.favorite,color: Colors.grey,size: 22),
                    ),
                    const SizedBox(width: 7,),
                    Text("likes",style: Theme.of(context).textTheme.caption),
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
                        backgroundImage: NetworkImage(LayoutCubit.getCubit(context).userData!.image!),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                        child: InkWell(
                          onTap: ()
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (context){return CommentsScreen(postID: postID, postMakerID: model.userID!);}));
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
