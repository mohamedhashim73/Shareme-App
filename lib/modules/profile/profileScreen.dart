import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/modules/profile/post_details_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/colors.dart';

class ProfileScreen extends StatelessWidget {
  bool? leadingIconExist = false;  // made this to make a leading icon available only if I open this screen after adding a post
  ProfileScreen({super.key, this.leadingIconExist});
  Widget build(BuildContext context) {
    return Builder(
      builder: (context){
        LayoutCubit.getCubit(context)..getMyData()..getMyPosts();
        return BlocConsumer<LayoutCubit,LayoutStates>(
            listener: (context,state){},
            builder: (context,state){
              final cubit = LayoutCubit.getCubit(context);
              return cubit.userData == null ?
                const Center(child:  CircularProgressIndicator(color: mainColor,)) :
                Scaffold(
                    appBar: AppBar(
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
                            // here should show bottomNavigationBar contain userName or login with another account
                          }
                      ),
                    ),
                    body: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                          [
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
                            const SizedBox(height:5,),
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
                                OutlinedButton(onPressed: (){}, child: const Icon(Icons.edit,size: 19,)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // Related to Archived Story in Profile
                            Row(
                                children: [
                                  ...buildArchivedStory(context: context), // as it is a list of Container
                                  InkWell(
                                    onTap:(){},
                                    child: Column(
                                      children: [
                                        const CircleAvatar(backgroundColor:blackColor,minRadius:30,child: Icon(Icons.add,color: whiteColor,),),
                                        const SizedBox(height: 10,),
                                        Text("add story",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 13),),
                                      ],
                                    ),
                                  ),
                                ]
                            ),
                            const SizedBox(height: 15,),
                            // Divide rest page for Images & Videos to show
                            Row(
                              children: [
                                buildShowSelectedItems(cubit: cubit, iconShown: Icons.image, isImage: true,onTap: (){}),
                                buildShowSelectedItems(cubit: cubit, iconShown: Icons.video_settings, isImage: false,onTap: (){}),
                              ],
                            ),
                            cubit.profileImageChosen?
                            // Put All Images for User :
                            GridView.builder(
                                itemCount: cubit.userPostsData.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 0.8,mainAxisSpacing: 3,crossAxisSpacing: 3),
                                itemBuilder: (context,i){
                                  return GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)
                                        {
                                          return PostDetailsScreen(model: cubit.userPostsData[i],postID: cubit.myPostsID[i],);
                                        }));
                                      },
                                      child: buildPostsImagesShown(model: cubit.userPostsData[i],context: context));
                                }
                            ) :
                            // Put All Videos for User
                            GridView.builder(
                                itemCount: cubit.userPostsData.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 0.8,mainAxisSpacing: 3,crossAxisSpacing: 3),
                                itemBuilder: (context,i){
                                  return GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)
                                      {
                                        return PostDetailsScreen(model: cubit.userPostsData[i],postID: cubit.myPostsID[i],);
                                      }));
                                    },
                                      child: buildPostsImagesShown(model: cubit.userPostsData[i],context: context));
                                }
                            )
                          ],
                        ),
                      ),
                    )
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

  List<Container> buildArchivedStory({required BuildContext context}){
    return List.generate(3, (index){
      return Container(
        margin: const EdgeInsets.only(right: 12.5),
        child: InkWell(
          onTap:(){},
          child: Column(
            children: [
              CircleAvatar(minRadius:30,backgroundColor: Colors.green.withOpacity(0.5),),
              const SizedBox(height: 10,),
              Text("FCI Tanta",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 13),),
            ],
          ),
        ),
      );
    });
  }

  // for chosen show Images posts or Videos only
  Widget buildShowSelectedItems({required LayoutCubit cubit,required IconData iconShown,required bool isImage,required Function() onTap}){
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            const Icon(Icons.image),
            isImage ?
            cubit.profileImageChosen ? const Divider(color: blackColor,thickness: 2,) : const Text("") :
            !cubit.profileImageChosen ? const Divider(color: blackColor,thickness: 2,) : const Text(""),
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
