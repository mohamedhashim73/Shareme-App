import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_data_model.dart';
import '../../layouts/layoutCubit/layoutCubit.dart';
import '../../layouts/layoutCubit/layoutStates.dart';
import '../../shared/styles/colors.dart';
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state){},
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          return Scaffold(
            appBar: AppBar(title: Text("Chat"),),
            body: cubit.allUsersData.isEmpty ?
                const Center(child: CircularProgressIndicator(),) :
                ListView.separated(
                    itemBuilder: (context,index){
                      return buildChatItem(context: context,model: cubit.allUsersData[index]);
                    },
                    separatorBuilder: (context,i)=>Container(height: 5),
                    itemCount: cubit.allUsersID.length
                ),
          );
        }
    );
  }

  Widget buildChatItem({required UserDataModel model,required BuildContext context}){
    return Padding(
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
                backgroundImage: NetworkImage(model.image!),
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
              Text("last message",style: Theme.of(context).textTheme.caption,),
            ],
          ),
          const Spacer(),
          GestureDetector(child: Icon(Icons.more_vert,color: blackColor.withOpacity(0.5),size: 25,),onTap: (){},),
        ],
      ),
    );
  }
}
