import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/modules/profile/post_details_screen.dart';
import 'package:social_app/modules/sign_screens/signScreens/login.dart';
import 'package:social_app/modules/storyItem/storyShownScreen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/network/local/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../models/storyModel.dart';
import '../storyItem/createStory.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  Widget build(BuildContext context) {
    return Builder(
      builder: (context){
        LayoutCubit.getCubit(context)..getMyData()..getMyStories(userID)..getMyPosts();
        return BlocConsumer<LayoutCubit,LayoutStates>(
            listener: (context,state) {
              if( state is ErrorDuringOpenWebsiteUrlState )
                {
                  showDefaultSnackBar(message: "make sure that this link is right", context: context, color: Colors.red);
                }
            },
            builder: (context,state){
              final cubit = LayoutCubit.getCubit(context);
              return cubit.userData == null || cubit.storiesData == null ?
                const Center(child:  CircularProgressIndicator(color: mainColor,)) :
                Scaffold(
                    appBar: AppBar(
                      leading: const SizedBox(width: 0,),
                      leadingWidth: 0,
                      title: defaultTextButton(
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children:
                            [
                              Text(cubit.userData!.userName!),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_drop_down_sharp)
                            ],
                          ),
                          onTap: ()
                          {
                            final snackBar = SnackBar(
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))),
                              elevation: 0,
                              content: SizedBox(
                                height: 80,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                  [
                                    Text(cubit.userData!.userName.toString(),style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),textAlign: TextAlign.center,),
                                    const SizedBox(height: 15,),
                                    defaultTextButton(
                                        title: const Text("login with another account !",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),textAlign: TextAlign.center,),
                                        onTap: ()
                                        {
                                          // delete userID that saved on Cache and go to Sign in
                                          CacheHelper.deleteCacheData(key: 'uid').then((value){
                                            if( value == true )
                                              {
                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                                              }
                                          });
                                        }
                                    ),
                                  ],
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.black26.withOpacity(0.8),
                              duration: const Duration(seconds: 1),);
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                      ),
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height:70,
                                      width: 70,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(color: blackColor.withOpacity(0.5))),
                                      child: Image(image: NetworkImage(cubit.userData!.image.toString()),fit: BoxFit.cover,),),
                                  ),
                                  Expanded(child: defaultUserInfo(title: 'Posts', number: '${cubit.userPostsData.length}', onTap: () {  }),),
                                  Expanded(child: defaultUserInfo(title: 'Followers', number: '0', onTap: () {  })),
                                  Expanded(child: defaultUserInfo(title: 'Following', number: '0', onTap: () {  }),)
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Text(cubit.userData!.userName.toString(),style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),),
                              const SizedBox(height: 2.5),
                              defaultTextButton(title: Text(cubit.userData!.bio!,overflow: TextOverflow.ellipsis,maxLines: 3,style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14)), onTap: (){}),
                              const SizedBox(height: 3,),
                              if( cubit.userData!.websiteUrl! != "" )
                                Container(
                                  margin:const EdgeInsets.only(bottom: 3),
                                  child: defaultTextButton(
                                      title: Text(cubit.userData!.websiteUrl!,overflow: TextOverflow.ellipsis,maxLines: 3,style: Theme.of(context).textTheme.caption!.copyWith(color:Colors.blue,fontSize: 14)),
                                      onTap: ()
                                      {
                                        cubit.openWebsiteUrl(websiteUrl: cubit.userData!.websiteUrl!);
                                      }
                                  ),
                                ),
                              const SizedBox(height: 3,),
                              Row(
                                children: [
                                  Expanded(
                                      child: OutlinedButton(
                                          onPressed: ()
                                          {
                                            Navigator.pushNamed(context, 'editProfileScreen');
                                          },
                                          child: const Text("Edit profile",style:TextStyle(fontSize: 16.5)))),
                                  const SizedBox(width: 5,),
                                  OutlinedButton(
                                      onPressed: ()
                                      {
                                        if( cubit.storiesData.length < 3 )
                                        {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateStoryScreen()));
                                        }
                                        else
                                        {
                                          showDefaultSnackBar(message: "sorry, only 3 stories allowed for you", context: context, color: Colors.red);
                                        }
                                      },
                                      child: const Icon(Icons.image,size: 19,)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.5),
                              // Related to Archived Story in Profile
                              if( cubit.storiesData.isEmpty )
                                Align(
                                  alignment: AlignmentDirectional.topStart,
                                  child: InkWell(
                                    onTap:()
                                    {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateStoryScreen()));
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 65,
                                            width: 65,
                                            alignment: Alignment.center,
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(color: blackColor.withOpacity(0.5))),
                                            child: const Icon(Icons.add)),
                                        const SizedBox(height: 10,),
                                        Text("add story",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 12),),
                                      ],
                                    ),
                                  ),
                                ),
                              if( cubit.storiesData.isNotEmpty )
                                SizedBox(
                                  height: 90,
                                  // width: double.infinity,
                                  child: GridView.builder(
                                    itemCount: cubit.storiesData.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:1,mainAxisSpacing: 0,childAspectRatio: 1.1),
                                    itemBuilder: (context,i){
                                      return buildArchivedStory(context: context, model: cubit.storiesData[i]);
                                    },
                                  ),
                                ),
                              const SizedBox(height: 10,),
                              Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                  [
                                    Expanded(
                                      child: Column(
                                        children:
                                        [
                                          Icon(Icons.image,color: blackColor.withOpacity(0.5),size: 24,),
                                          const Divider(thickness: 2),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children:
                                        [
                                          Icon(Icons.video_collection_rounded,color: blackColor.withOpacity(0.5),size: 24,),
                                          const Divider(thickness: 2,color: Colors.transparent,),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                        cubit.userData != null && cubit.likesPostsData != null ?
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:12.0,vertical: 0),
                                child: GridView.builder(
                                          itemCount: cubit.userPostsData.length,
                                          physics: const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 0.8,mainAxisSpacing: 5,crossAxisSpacing: 5),
                                          itemBuilder: (context,i){
                                            return GestureDetector(
                                                onTap: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (context)
                                                  {
                                                    return PostDetailsScreen(model: cubit.userPostsData[i],postID: cubit.myPostsID[i],commentsNumber: cubit.myCommentsNumber[i] ?? 0,);
                                                  }));
                                                },
                                                child: buildPostsImagesShown(model: cubit.userPostsData[i],context: context));
                                          }),
                              )) :
                            const CupertinoActivityIndicator(),
                      ],
                    ),
                );
            }
        );
      }
    );
  }
  // This widget for 3 Expanded Text ( Following - Followers - Posts ) with numbers
  Widget defaultUserInfo({required String title,required String number,required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(number,style: const TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(height: 2.5,),
          Text(title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: blackColor.withOpacity(0.8)),),
        ],
      ),
    );
  }

  Widget buildArchivedStory({required BuildContext context,required StoryDataModel model}){
    return InkWell(
      onTap:()
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>StoryShownScreen(storyModel: model, userModel: LayoutCubit.getCubit(context).userData!)));
      },
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(color: blackColor.withOpacity(0.5))),
            child: Image(image: NetworkImage(model.storyImage.toString()),fit: BoxFit.cover,),),
          const SizedBox(height: 10,),
          Text(model.storyTitle.toString(),style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,),
        ],
      ),
    );
  }

  Widget buildPostsImagesShown({required PostDataModel model,required BuildContext context}){
    return model.postImage != ''?
    Image.network(model.postImage!,fit: BoxFit.cover,) :
    Container(
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
      color: Colors.grey.withOpacity(0.2),
      padding: const EdgeInsets.all(5),
      child: Text(model.postCaption!,style: Theme.of(context).textTheme.caption!.copyWith(color: blackColor,fontSize: 13.5),textAlign: TextAlign.center,),
    )
    ;
  }

}
