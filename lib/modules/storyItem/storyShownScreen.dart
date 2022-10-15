import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/styles/colors.dart';
import '../../layouts/homeLayoutScreen/home_layout_screen.dart';
import '../../layouts/layoutCubit/layoutCubit.dart';
import '../../layouts/layoutCubit/layoutStates.dart';
import '../../models/storyModel.dart';
import '../../shared/components/components.dart';

class StoryShownScreen extends StatelessWidget {
  StoryDataModel storyModel;
  UserDataModel userModel;
  StoryShownScreen({super.key,required this.storyModel,required this.userModel});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text("Story"),titleSpacing: 0,
        leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios), onTap: (){Navigator.pop(context);}),
      ),
      body: buildStoryShownItem(context: context,model:storyModel,userModel:userModel),
    );
  }

  Widget buildStoryShownItem({required BuildContext context,required StoryDataModel model,required UserDataModel userModel}){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
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
                      backgroundImage: NetworkImage(userModel.image.toString()),
                    ),
                  ],
                ),
                const SizedBox(width: 13,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // did yhe condition down as if I update my date will show with update as I sent data with post with the last data for me like my image for example
                    Text(model.userName.toString(),style: const TextStyle(fontSize: 16),),
                    const SizedBox(height: 2,),
                    Text(storyModel.storyDate.toString(),style: Theme.of(context).textTheme.caption,),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: Center(child: Image.network(model.storyImage.toString())),
          ),
          Container(
            height: 75,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(model.storyTitle.toString(),style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),
          )
        ],
      ),
    );
  }
}
