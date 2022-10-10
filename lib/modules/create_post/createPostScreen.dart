import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../layouts/homeLayoutScreen/home_layout_screen.dart';
import '../../layouts/layoutCubit/layoutCubit.dart';
import '../../layouts/layoutCubit/layoutStates.dart';
import '../../shared/components/components.dart';

class CreatePostScreen extends StatelessWidget {
  final captionController = TextEditingController();
  CreatePostScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state)
        {
          if( state is UploadPostWithoutImageSuccessState )
          {
            showDefaultSnackBar(message: "Post Uploaded successfully!", context: context, color: Colors.grey);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfileScreen(leadingIconExist: true,)));
            // Navigator.pop(context);
            LayoutCubit.getCubit(context).postImageFile = null ;
          }
        },
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: const Text("New Post"),titleSpacing: 0,
              leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios), onTap: (){Navigator.pop(context);}),
              actions:
              [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: state is UploadPostWithoutImageLoadingState || state is UploadPostWithImageLoadingState ?
                  const CupertinoActivityIndicator(color: mainColor) :
                  InkWell(
                    child: const Icon(Icons.done,color: mainColor,size: 25,),
                    onTap: ()
                    {
                      if( cubit.postImageFile != null )
                      {
                        cubit.createPostWithImage(postCaption: captionController.text);
                      }
                      else
                      {
                        cubit.createPostWithoutImage(postCaption: captionController.text);
                      }
                    },
                  ),
                )
              ],
            ),
            body: cubit.userData == null ?
            const Center(child: CircularProgressIndicator(color: mainColor,),) :
            buildPostItem(context: context, cubit: cubit),
          );
        }
    );
  }

  Widget buildPostItem({required BuildContext context,dynamic model,required LayoutCubit cubit}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 5,top: 10),
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
                          child : cubit.userData?.image != null? Image.network(cubit.userData!.image!,fit: BoxFit.cover,) : const Text("")
                      ),
                      const SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cubit.userData!.userName!,style: const TextStyle(fontSize: 16),),
                          const SizedBox(height: 2,),
                          Text(timeNow,style: Theme.of(context).textTheme.caption,),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(child: Icon(Icons.more_vert,color: blackColor.withOpacity(0.5),size: 25,),onTap: (){},),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    maxLines: 2,
                    controller: captionController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "type your caption here...",
                        hintStyle: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14)
                    ),
                  ),
                ),
                if( cubit.postImageFile != null )
                  const SizedBox(height: 10,),
                if( cubit.postImageFile != null )
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                          width: double.infinity,
                          child: Image(image: FileImage(cubit.postImageFile!))
                        // Image.network(cubit.postImageUrl!,fit: BoxFit.fitHeight,height: 250),
                      ),
                      GestureDetector(
                        onTap: (){
                          cubit.canceledImageForPost();
                        },
                        child: Container(margin:const EdgeInsets.all(7.5),child: const CircleAvatar(radius: 15,child:Icon(Icons.close,size: 20,),)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
            [
              defaultButton(
                  onTap: (){
                    cubit.getPostImage();
                  },
                  backgroundColor: whiteColor,
                  contentWidget: Row(
                    children:
                    const [
                      Icon(Icons.image,color: mainColor,),
                      SizedBox(width: 7,),
                      Text("add a photo",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),)
                    ],
                  )
              ),
              defaultButton(
                  onTap: (){},
                  backgroundColor: whiteColor,
                  contentWidget: Row(
                    children:
                    const [
                      Icon(Icons.link,color: mainColor,),
                      SizedBox(width: 7,),
                      Text("add a link",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),)
                    ],
                  )
              )
            ],
          ),
        ),
      ],
    );
  }
}
