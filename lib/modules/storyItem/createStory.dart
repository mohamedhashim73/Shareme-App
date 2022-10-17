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

class CreateStoryScreen extends StatelessWidget {
  final storyCaptionController = TextEditingController();
  CreateStoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state)
        {
          if( state is CreateStorySuccessState )
          {
            showDefaultSnackBar(message: "Story Uploaded successfully!", context: context, color: Colors.green);
            // LayoutCubit.getCubit(context).getUsersPosts();
            // Navigator.pop(context);    // عملت pop عشان ميحصلش تراكم ف البوستات اما ارجع لصفحه home
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
            LayoutCubit.getCubit(context).storyImage = null ;
          }
        },
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: const Text("New Story"),titleSpacing: 0,
              leading: defaultTextButton(title: const Icon(Icons.arrow_back_ios), onTap: (){Navigator.pop(context);}),
              actions:
              [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: state is CreateStoryLoadingState ?
                  const CupertinoActivityIndicator(color: mainColor) :
                  InkWell(
                    child: const Icon(Icons.done,color: mainColor,size: 25,),
                    onTap: ()
                    {
                      if( cubit.storyImage != null )
                      {
                        cubit.createStory(storyTitle: storyCaptionController.text);
                      }
                      else
                      {
                        showDefaultSnackBar(message: "choose an Image and try again!", context: context, color: Colors.grey.withOpacity(1));
                      }
                    },
                  ),
                )
              ],
            ),
            body: cubit.userData == null ?
            const Center(child: CircularProgressIndicator(color: mainColor,),) :
            buildStoryItem(context: context, cubit: cubit),
          );
        }
    );
  }

  Widget buildStoryItem({required BuildContext context,required LayoutCubit cubit}){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
              ],
            ),
          ),
          const SizedBox(height: 5,),
          if( cubit.storyImage != null )
            Expanded(
              child: Center(
                child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    SizedBox(
                        child: Image(image: FileImage(cubit.storyImage!))
                    ),
                    GestureDetector(
                      onTap: ()
                      {
                        cubit.canceledImageForStory();
                      },
                      child: Container(margin:const EdgeInsets.all(7.5),child: const CircleAvatar(radius: 15,child:Icon(Icons.close,size: 20,),)),
                    ),
                  ],
                ),
              ),
            ),
          if( cubit.storyImage != null )
            Container(
              height: 75,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              alignment: Alignment.center,
              child: TextFormField(
                controller: storyCaptionController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    hintText: "type title for story here ....",
                    hintStyle: Theme.of(context).textTheme.caption!.copyWith(fontSize: 16)
                ),
              ),
            ),
          if( cubit.storyImage == null )
            Expanded(
              child: Center(
                  child: GestureDetector(
                    child: const Text("Select Image",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold,fontSize: 20),),
                    onTap: ()
                    {
                      cubit.getStoryImage();
                    },
                  )
              ),
            ),
        ],
      ),
    );
  }
}
