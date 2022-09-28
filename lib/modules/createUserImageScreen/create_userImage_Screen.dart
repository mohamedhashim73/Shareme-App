import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/layoutCubit.dart';
import 'package:social_app/layouts/cubit/layoutStates.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/network/local/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';

class CreateUserImageScreen extends StatelessWidget {
  const CreateUserImageScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
      listener:(context,state){},
      builder:(context,state){
        LayoutCubit cubit = LayoutCubit.getCubit(context);
        return Scaffold(
          appBar: AppBar(toolbarHeight: 40,leadingWidth: 0,leading: const Text(""),),
          body: cubit.userData == null ?
          const Center(child: CupertinoActivityIndicator(color: mainColor,)) :
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children:
              [
                Expanded(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Welcome ${cubit.userData?.name.toString()}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                            const SizedBox(height: 40,),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Container(
                                  height: 125,
                                  width: 125,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: const BoxDecoration(shape: BoxShape.circle,color: mainColor),
                                ),
                                Stack(
                                  alignment: AlignmentDirectional.topStart,
                                  children: [
                                    Container(
                                        height: 120,
                                        width: 120,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: whiteColor,
                                        ),
                                        child: cubit.userImageFile != null ?
                                        Image(image: FileImage(cubit.userImageFile!)) :
                                        const Text(""),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        cubit.getProfileImage();
                                        },
                                      child: const CircleAvatar(maxRadius: 15,child: Icon(Icons.photo_camera,size: 20,),),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 30,),
                            defaultButton(
                                onTap: (){cubit.getProfileImage();},
                                contentWidget: const Text("Upload Image",style: TextStyle(color: whiteColor,fontSize: 16.5),),
                                roundedRectangleBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Center(child: Text("You're all set",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.5,color: Colors.grey),)),
                          SizedBox(height: 2.5,),
                          Center(child: Text("Take a minute to upload your photo.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.5,color: Colors.grey),)),
                          SizedBox(height: 25,),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: AlignmentDirectional.topEnd,
                  child: defaultTextButton(title: const Text("Next",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold,fontSize: 18),), onTap: (){
                    CacheHelper.saveCacheData(key: 'passedChosenImage', val: true).then((value){
                      cubit.updateUserDataWithImage(name: cubit.userData!.name!,userName: cubit.userData!.userName!,bio: cubit.userData!.bio!,email: cubit.userData!.email!);
                      Navigator.pushReplacementNamed(context,'homeLayoutScreen');});
                  }),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
