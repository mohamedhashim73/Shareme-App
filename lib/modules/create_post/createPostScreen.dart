import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/styles/colors.dart';
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
            showSnackBar(message: "Post Uploaded successfully!", context: context, color: Colors.grey);
            Navigator.pushReplacementNamed(context, 'homeLayoutScreen');
            LayoutCubit.getCubit(context).postImageFile = null ;
          }
        },
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: const Text("New Post"),titleSpacing: 0,
              leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios), onTap: (){Navigator.pushReplacementNamed(context, 'homeLayoutScreen');}),
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
                      //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
                    },
                  ),
                )
              ],
            ),
            body: cubit.userData == null ?
            const Center(child: CircularProgressIndicator(color: mainColor,),) :
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: buildPostItem(context: context, cubit: cubit),
              ),
            ),
          );
        }
    );
  }

  Widget buildPostItem({required BuildContext context,dynamic model,required LayoutCubit cubit}){
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
                    backgroundImage: NetworkImage(cubit.userData?.image.toString() ?? defaultUserImage),
                  ),
                ],
              ),
              const SizedBox(width: 13,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 2.5,),
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
            maxLines: 3,
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
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1),bottom: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1))
              ),
              child: Image(image: FileImage(cubit.postImageFile!),height: 250,fit: BoxFit.fitHeight)
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
        const SizedBox(height: 5,),
        Row(
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
                    Text("Add a photo",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),)
                  ],
                )
            ),
            defaultButton(
                onTap: (){},
                backgroundColor: whiteColor,
                contentWidget: Row(
                  children:
                  const [
                    Icon(Icons.closed_caption,color: mainColor,),
                    SizedBox(width: 7,),
                    Text("Add a Tag",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),)
                  ],
                )
            )
          ],
        ),
      ],
    );
  }
}
