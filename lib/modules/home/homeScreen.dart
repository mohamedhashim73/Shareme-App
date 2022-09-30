import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/models/post_Data_Model.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/styles/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context){
        // call getPostsForAllUsers for first time i open this screen
        LayoutCubit.getCubit(context).getPostsForAllUsers();
        return BlocConsumer<LayoutCubit,LayoutStates>(
            listener: (context,state){},
            builder: (context,state){
              final cubit = LayoutCubit.getCubit(context);
              return Scaffold(
                backgroundColor: whiteColor,
                appBar: AppBar(leading: const Text(""),leadingWidth: 0,title: const Text("Feed"),toolbarHeight: 45,),
                body: state is GetPostsDataForAllUsersLoadingState ?  // mean that there is no posts for all users on FireStore
                const Center(child: CupertinoActivityIndicator(color: mainColor,),) :
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      [
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context,i){
                            return buildPostItem(context: context, cubit: cubit,model: cubit.usersPostsData[i]);
                          },
                          separatorBuilder: (context,i){
                            return const Divider(thickness: 1,height: 3,);
                          },
                          itemCount: cubit.usersPostsData.length,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        );
      },
    );
  }

  Widget buildPostItem({required BuildContext context,required PostDataModel model,required LayoutCubit cubit}){
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
                    backgroundImage: NetworkImage(model.userImage!),
                  ),
                ],
              ),
              const SizedBox(width: 13,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 2.5,),
                  Text(model.userName!,style: const TextStyle(fontSize: 16),),   // if user change userName , it will be shown but if shown the value that store on postData there will be difference
                  const SizedBox(height: 2,),
                  Text(model.postDate!,style: Theme.of(context).textTheme.caption,),
                ],
              ),
              const Spacer(),
              GestureDetector(child: Icon(Icons.more_vert,color: blackColor.withOpacity(0.5),size: 25,),onTap: (){},),
            ],
          ),
        ),
        if( model.postCaption != '' )
        const SizedBox(height: 10,),
        if( model.postCaption != '' )
        Container(
          color: model.postImage == '' ? Colors.white.withOpacity(0.2) : whiteColor,
          padding : const EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
          child: Text(model.postCaption!,style: model.postImage == '' ? const TextStyle(fontWeight: FontWeight.w400,fontSize: 17.5) : const TextStyle()),
        ),
        if( model.postImage != '' )   // as if image not exist postImage on fireStore will have '' value
        const SizedBox(height: 10,),
        if( model.postImage != '' )
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1),width: 1),bottom: BorderSide(color: Colors.grey.withOpacity(0.3),width: 1))
          ),
          child: Image.network(model.postImage!),
        ),
        const SizedBox(height: 8,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          child: Row(
            children: [
              GestureDetector(onTap:(){},child: const Icon(Icons.favorite_border,color: Colors.grey,size: 22,)),
              const SizedBox(width: 12.5),
              GestureDetector(onTap:(){},child: const Icon(Icons.messenger_outline,color: Colors.grey,size: 22,)),
              const SizedBox(width: 12.5),
              GestureDetector(onTap:(){},child: const Icon(Icons.send,color: Colors.grey,size: 22,)),
              const Spacer(),
              GestureDetector(onTap:(){},child: const Icon(Icons.turned_in_not,color: Colors.grey,size: 22,)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              const SizedBox(height: 5),
              Text("0 likes",style: Theme.of(context).textTheme.caption,),
              Row(
                children:
                [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(cubit.userData?.image.toString() ?? defaultUserImage),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "add a new comment...",
                        hintStyle: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14)
                      ),
                    ),
                  )
                ],
              )
            ],
          )
        )
      ],
    );
  }
}
