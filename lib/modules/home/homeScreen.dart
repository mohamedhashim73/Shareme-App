import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/commentsViewScreen/commentsViewScreen.dart';
import 'package:social_app/layouts/homeLayoutScreen/home_layout_screen.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/layouts/likesViewScreen/likesViewScreen.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/modules/edit_post/edit_post_screen.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../shared/components/components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        LayoutCubit.getCubit(context)..getMyData()..getUsersPosts();
        return BlocConsumer<LayoutCubit,LayoutStates>(
            listener: (context,state)
            {
              // it was only when i upload post successfully state
              if( state is UploadPostWithoutImageSuccessState || state is DeletePostSuccessfullyState || state is UpdatePostSuccessfullyState) LayoutCubit.getCubit(context)..getMyData()..getUsersPosts();
            },
            builder: (context,state){
              final cubit = LayoutCubit.getCubit(context);
              return Scaffold(
                backgroundColor: whiteColor,
                appBar: AppBar(leading: const Text(""),leadingWidth: 0,title: const Text("Feed"),toolbarHeight: 45,),
                body: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                          child: Row(
                            children:
                            [
                              GestureDetector(
                                onTap: ()
                                {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: cubit.userData != null ? NetworkImage(cubit.userData!.image!) : null,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.pushNamed(context, 'createPostScreen');
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),border: Border.all(color: Colors.grey.withOpacity(0.5))
                                      ),
                                      child: Text("What's on your mind ?",style: TextStyle(color: blackColor.withOpacity(0.7)),),
                                    ),
                                  )
                              ),
                              const SizedBox(width: 7.5,),
                              GestureDetector(
                                  onTap: (){
                                    Navigator.pushNamed(context, 'createPostScreen');
                                  },
                                  child: const Icon(Icons.image,color: mainColor,size: 30,))
                            ],
                          ),
                        ),
                        cubit.userData != null && cubit.likesPostsData != null ?
                              Expanded(
                                child: ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  // shrinkWrap: true,
                                  itemBuilder: (context,index){
                                    return buildPostItem(
                                        context: context,
                                        cubit: cubit,
                                        model: cubit.usersPostsData[index],
                                        index: index,
                                        state: state,
                                    );
                                  },
                                  separatorBuilder: (context,i){
                                    return const Divider(thickness: 1,height: 3,);
                                  },
                                  itemCount: cubit.usersPostsData.length,
                                ),
                              ) :
                              const Center(child: CupertinoActivityIndicator(color: mainColor),),
                      ],
                    ),
                  ),
              );
            }
        );
      }
    );
  }

  Widget buildPostItem({required BuildContext context,required PostDataModel model,required LayoutCubit cubit,required int index,required LayoutStates state}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10,right: 5,top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  CircleAvatar(
                    radius: 21.5,
                    backgroundColor: blackColor.withOpacity(0.5),
                  ),
                  CircleAvatar(
                    radius: 20,
                    // did yhe condition down as if I update my date will show with update as I sent data with post with the last data for me like my image for example
                    backgroundImage: NetworkImage(cubit.userData!.userID == cubit.usersPostsData[index].userID ? cubit.userData!.image!: model.userImage!),
                  ),
                ],
              ),
              const SizedBox(width: 13,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // did yhe condition down as if I update my date will show with update as I sent data with post with the last data for me like my image for example
                  Text(cubit.userData!.userID == cubit.usersPostsData[index].userID ? cubit.userData!.userName!: model.userName!,style: const TextStyle(fontSize: 16),),
                  const SizedBox(height: 2,),
                  Text(model.postDate!,style: Theme.of(context).textTheme.caption,),
                ],
              ),
              const Spacer(),
              GestureDetector(
                child: Icon(Icons.more_vert,color: blackColor.withOpacity(0.5),size: 25,),
                onTap: ()
                {
                  // meaning that if the postMakerID not equal my ID so I don't have a permission to do this
                  if ( cubit.usersPostsData[index].userID == cubit.userData!.userID )
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
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EditPostScreen(model: model,postID: cubit.postsID[index],)));
                              },
                            )
                          ),
                          PopupMenuItem(
                            onTap: ()
                            {
                              cubit.deletePost(postMakerID: cubit.usersPostsData[index].userID!, postID: cubit.postsID[index]);
                            },
                            child: const Text('delete post'),
                          ),
                          PopupMenuItem(
                            onTap: ()
                            {
                              cubit.deleteUser(personID: cubit.usersPostsData[index].userID!,);
                            },
                            child: const Text('delete User'),
                          ),
                        ]
                    );
                  }
                },
              ),
            ],
          ),
        ),
        if( model.postCaption != '' )
          const SizedBox(height: 10,),
        if( model.postCaption != '' )
          Container(
            color: model.postImage == '' ? Colors.white.withOpacity(0.2) : whiteColor,
            padding : const EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
            child: Text(model.postCaption!,style: model.postImage == '' ? const TextStyle(fontWeight: FontWeight.w400,fontSize: 18.5) : const TextStyle(fontSize: 17)),
          ),
        if( model.postImage != '' )   // as if image not exist postImage on fireStore will have '' value
          const SizedBox(height: 10,),
        if( model.postImage != '' )
          Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1),width: 1),bottom: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1))
            ),
            child: Image.network(model.postImage!),
          ),
        const SizedBox(height: 12.5,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              /*
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: InkWell(
                      onTap: ()
                      {

                        Navigator.push(context, MaterialPageRoute(builder: (context){return LikesViewScreen(postID: cubit.postsID[index], postMakerID: model.userID!);}));
                      },
                      child: cubit.likesNumber[index] != null ?
                      Text("${cubit.likesNumber[index]} likes",style: Theme.of(context).textTheme.caption,) :
                      Text("0 likes",style: Theme.of(context).textTheme.caption,),
                  ),
                ),
              ),
               */
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: InkWell(
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context){return CommentsScreen(postID: cubit.postsID[index], postMakerID: model.userID!,postIndex: index,);}));
                      },
                      child: cubit.commentsNumber[index] != null ?
                      Text("${cubit.commentsNumber[index]} comments",style: Theme.of(context).textTheme.caption,) :
                      Text("0 comments",style: Theme.of(context).textTheme.caption,),
                    /*
                    child: cubit.commentsNumber[index] != null ?
                      Text("${state is AddCommentSuccessState ? cubit.commentsNumber[index]+1 : cubit.commentsNumber[index]} comments",style: Theme.of(context).textTheme.caption,) :
                      Text("0 comments",style: Theme.of(context).textTheme.caption,),
                     */
                  ),
                ),
              ),
            ],
          )
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
                      child: StatefulBuilder(
                        builder: (context,setstate){
                          return GestureDetector(
                              onTap:()
                              {
                                setstate((){
                                  if( cubit.likesPostsData[index] == true )
                                  {
                                    cubit.removeLike(postID: cubit.postsID[index]);
                                    cubit.likesPostsData[index] = false ;
                                  }
                                  else
                                  {
                                    cubit.addLike(postID: cubit.postsID[index]);
                                    cubit.likesPostsData[index] = true ;   // لأن انا بلعب علي لو قيمتها لا تساوي صفر يبقي كده في قيمه
                                  }
                                });
                              },
                              // عملت لا يساوي صفر عشان انا قلت لو id مش نفسه بتاعي خزن صفر طب لو بتاعي هخزن الداتا بتاعت likePostData في List عشان اعرضها في صفحه اللايكات
                              child: Icon(Icons.favorite,color: cubit.likesPostsData[index] == false || cubit.likesPostsData[index] == null ? Colors.grey : Colors.red,size: 22)
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 7),
                    GestureDetector(
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LikesViewScreen(postID: cubit.postsID[index], postMakerID: cubit.usersPostsData[index].userID!)));
                      },
                        child: Text("like",style: Theme.of(context).textTheme.caption)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap:()
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context){return CommentsScreen(postID: cubit.postsID[index], postMakerID: model.userID!,postIndex: index,);}));
                        },child: const Icon(Icons.messenger_outline,color: Colors.grey,size: 22,)),
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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(cubit.userData!.image!),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                        child: InkWell(
                          onTap: ()
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (context){return CommentsScreen(postID: cubit.postsID[index], postMakerID: model.userID!,postIndex: index,);}));
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
