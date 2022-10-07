import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/models/commentModel.dart';
import 'package:social_app/models/likeDataModel.dart';
import '../../shared/components/components.dart';
import '../../shared/styles/colors.dart';

class LikesViewScreen extends StatelessWidget {
  String postMakerID;
  String postID;  // to enable to get the comments for this post
  LikesViewScreen({super.key,required this.postID,required this.postMakerID});
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          LayoutCubit.getCubit(context).getLikes(postMakerID: postMakerID, postID: postID);
          return BlocConsumer<LayoutCubit,LayoutStates>(
            listener: (context,state){},
            builder: (context,state){
              final cubit = LayoutCubit.getCubit(context);
              return Scaffold(
                appBar: AppBar(
                  titleSpacing: 0,
                  title: const Text("Likes",style: TextStyle(fontSize: 20),),
                  leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios,size: 20,), onTap: (){Navigator.pushReplacementNamed(context, 'homeLayoutScreen');}),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      state is GetLikesLoadingState ?
                      const Center(child: CupertinoActivityIndicator(),) :
                      cubit.likesData.isNotEmpty ?
                      ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context,i){ return buildCommentItem(model: cubit.likesData[i]);},
                        separatorBuilder: (context,i){return const SizedBox(height: 15.0);},
                        itemCount: cubit.likesData.length,) :
                      const Expanded(
                          child: Center(child: Text("No Likes yet",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),))
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  Widget buildCommentItem({required LikeDataModel model}){
    return Row(
      children:
      [
        CircleAvatar(
          radius: 23,
          backgroundImage: NetworkImage(model.likeMakerImage!),
        ),
        const SizedBox(width: 15,),
        Text(model.likeMakerName!,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
        const Spacer(),
        Text(model.isLike!.toString(),style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
      ],
    );
  }
}
