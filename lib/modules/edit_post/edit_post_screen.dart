import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../layouts/homeLayoutScreen/home_layout_screen.dart';
import '../../layouts/layoutCubit/layoutCubit.dart';
import '../../layouts/layoutCubit/layoutStates.dart';
import '../../shared/components/components.dart';

class EditPostScreen extends StatelessWidget{
  String postID;  // as it not saved with post data on fireStore so i will get when i call this state from PostsID that use in usersPostsData
  PostDataModel model;  // to get post data to be able to update it throw its id and the maker of it
  final captionController = TextEditingController();
  EditPostScreen({super.key,required this.model,required this.postID});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state)
        {
          if( state is UpdatePostSuccessfullyState )
          {
            showDefaultSnackBar(message: "Post Updated successfully!", context: context, color: Colors.grey);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
            LayoutCubit.getCubit(context).postImageFile = null ;
          }
        },
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          captionController.text = model.postCaption!;
          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: const Text("Update Post"),titleSpacing: 0,
              leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios), onTap: (){Navigator.pop(context);}),
              actions:
              [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: state is UpdatePostLoadingState ?
                  const CupertinoActivityIndicator(color: mainColor) :
                  InkWell(
                    child: const Icon(Icons.done,color: mainColor,size: 25,),
                    onTap: ()
                    {
                      cubit.updatePost(postMakerID: model.userID!, postID: postID, postMakerName: model.userName!, postMakerImage: model.userImage!, postCaption: captionController.text, postDate: model.postDate!, postImage: model.postImage!);
                    },
                  ),
                )
              ],
            ),
            body: model.userID == null ?
            const Center(child: CircularProgressIndicator(color: mainColor,),) :
            SingleChildScrollView(
              child: buildPostItem(context: context,model: model),
            ),
          );
        }
    );
  }

  Widget buildPostItem({required BuildContext context,required PostDataModel model}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  child : model.userImage != null ? Image.network(model.userImage!,fit: BoxFit.cover,) : const Text("")
              ),
              const SizedBox(width: 15,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.userName!,style: const TextStyle(fontSize: 16),),
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
            controller: captionController,
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
        if( model.postImage != '' )      // as if there is no image for a post , postImage that on post field on fireStore contain '' and this instead of imageUrl
          const SizedBox(height: 10,),
        if( model.postImage != '' )      // لو مش هعمل الاوبشن بتاع حذف صوره البوست ف مش بحاجه لل stack
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1),bottom: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1))
                  ),
                  child: Image.network(model.postImage!,fit: BoxFit.cover,),
                // Image.network(cubit.postImageUrl!,fit: BoxFit.fitHeight,height: 250),
              ),
            ],
          ),
      ],
    );
  }
}
