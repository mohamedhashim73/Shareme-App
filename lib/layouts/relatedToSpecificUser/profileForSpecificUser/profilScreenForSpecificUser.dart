import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/relatedToSpecificUser/cubit/states_specificUser.dart';
import 'package:social_app/layouts/relatedToSpecificUser/profileForSpecificUser/postDetailsScreenForSpecificUser.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/modules/storyItem/storyShownScreen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../../models/storyModel.dart';
import '../cubit/cubit_specificUser.dart';

class ProfileScreenForSpecificUser extends StatelessWidget{
  String specificUserID;
  ProfileScreenForSpecificUser({super.key,required this.specificUserID});
  Widget build(BuildContext context) {
    return Builder(
        builder: (context){
          SpecificUserCubit.getCubit(context)..getMyData(specificUserID: specificUserID)..getStoriesForSpecificUser(specificUserID)..getPostsForSpecificUser(specificUserID: specificUserID);
          return BlocConsumer<SpecificUserCubit,SpecificUserStates>(
              listener: (context,state)
              {
                if( state is ErrorDuringOpenWebsiteUrlForSpecificUserState )
                {
                  showDefaultSnackBar(message: "make sure that this link is right", context: context, color: Colors.red);
                }
              },
              builder: (context,state){
                final cubit = SpecificUserCubit.getCubit(context);
                return cubit.specificUserData == null ?
                const Center(child:  CircularProgressIndicator(color: mainColor,)) :
                Scaffold(
                  appBar: AppBar(
                    leading: const SizedBox(width: 0,),
                    leadingWidth: 0,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children:
                      [
                        Text(cubit.specificUserData!.userName!),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_drop_down_sharp)
                      ],
                    ),
                  ),
                  body: cubit.specificUserData != null ?
                      Column(
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
                                        child: Image(image: NetworkImage(cubit.specificUserData!.image.toString()),fit: BoxFit.cover,),),
                                    ),
                                    Expanded(child: defaultUserInfo(title: 'Posts', number: '${cubit.postsDataForSpecificUser.length}', onTap: () {  }),),
                                    Expanded(child: defaultUserInfo(title: 'Followers', number: '0', onTap: () {  })),
                                    Expanded(child: defaultUserInfo(title: 'Following', number: '0', onTap: () {  }),)
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Text(cubit.specificUserData!.userName.toString(),style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),),
                                const SizedBox(height: 2.5),
                                defaultTextButton(title: Text(cubit.specificUserData!.bio!,overflow: TextOverflow.ellipsis,maxLines: 3,style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14)), onTap: (){}),
                                const SizedBox(height: 2.5),
                                if( cubit.specificUserData!.websiteUrl! != "" )
                                  Container(
                                    margin:const EdgeInsets.only(bottom: 3),
                                    child: defaultTextButton(
                                        title: Text(cubit.specificUserData!.websiteUrl!,overflow: TextOverflow.ellipsis,maxLines: 3,style: Theme.of(context).textTheme.caption!.copyWith(color:Colors.blue,fontSize: 14)),
                                        onTap: ()
                                        {
                                          cubit.openWebsiteUrl(websiteUrl: cubit.specificUserData!.websiteUrl!);
                                        }
                                    ),
                                  ),
                                const SizedBox(height: 9.5),
                                // Related to Archived Story in Profile
                                if( cubit.storiesForSpecificUser.isNotEmpty )
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 90,
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:
                                            [
                                              Expanded(
                                                child: GridView.builder(
                                                  itemCount: cubit.storiesForSpecificUser.length,
                                                  scrollDirection: Axis.horizontal,
                                                  // shrinkWrap: true,
                                                  physics: const BouncingScrollPhysics(),
                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:1,mainAxisSpacing: 0,childAspectRatio: 1.1),
                                                  itemBuilder: (context,i){
                                                    return buildArchivedStory(context: context, model: cubit.storiesForSpecificUser[i],cubit: cubit);
                                                  },
                                                ),
                                              ),
                                            ]
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                    ],
                                  ),
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
                          cubit.specificUserData != null ?
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:12.0),
                                child: GridView.builder(
                                    itemCount: cubit.postsDataForSpecificUser.length,
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 0.8,mainAxisSpacing: 5,crossAxisSpacing: 5),
                                    itemBuilder: (context,i){
                                      return GestureDetector(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)
                                            {
                                              return PostDetailsScreenForSpecificUser(model: cubit.postsDataForSpecificUser[i],postID: cubit.postsIDForSpecificUser[i],commentsNumber: cubit.commentsNumberForSpecificUser[i] ?? 0,);
                                            }));
                                          },
                                          child: buildPostsImagesShown(model: cubit.postsDataForSpecificUser[i],context: context));
                                    }),
                              ))
                              : const Expanded(
                              child: Center(child: Text("No posts yet"),)
                          ),
                        ],
                      ) :
                      const Center(child: CupertinoActivityIndicator(),)
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

  Widget buildArchivedStory({required BuildContext context,required StoryDataModel model,required SpecificUserCubit cubit}){
    return Container(
      margin: const EdgeInsets.only(right: 12.5),
      child: InkWell(
        onTap:()
        {
          // open the story in separated screen (( لو هعمل بروفايل لشخص تاني هبقي اباصي المودل تبعه ))
          Navigator.push(context, MaterialPageRoute(builder: (context)=>StoryShownScreen(storyModel: model,userModel: cubit.specificUserData!)));
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
            Text(model.storyTitle.toString(),style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,),
          ],
        ),
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
