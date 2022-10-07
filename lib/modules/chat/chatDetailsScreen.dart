import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/models/messgaeDataModel.dart';
import '../../models/user_data_model.dart';
import '../../shared/components/components.dart';
import '../../shared/styles/colors.dart';
// this screen contain chat with messages between me and another user

class ChatDetailsScreen extends StatelessWidget {
  TextEditingController messageController = TextEditingController();
  UserDataModel receiverUserDataModel;
  ChatDetailsScreen({super.key, required this.receiverUserDataModel});
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context){
        LayoutCubit.getCubit(context)..getMessages(messageReceiverID: receiverUserDataModel.userID!);
        return BlocConsumer<LayoutCubit,LayoutStates>(
            listener: (context,state){
              if( state is SendMessageSuccessState )
                {
                  messageController.text = '';
                }
            },
            builder: (context,state){
              final cubit = LayoutCubit.getCubit(context);
              return Scaffold(
                backgroundColor: mainColor.shade50,
                appBar: AppBar(
                  leadingWidth: 0,
                  leading: const Text(''),
                  title: Row(
                    children:
                    [
                      CircleAvatar(radius: 17,backgroundImage: NetworkImage(receiverUserDataModel.image!)),
                      const SizedBox(width: 15,),
                      Text(receiverUserDataModel.userName!,style: const TextStyle(fontSize: 17),)
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      state is GetMessageLoadingState ?
                        const Center(child: CupertinoActivityIndicator()) :
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context,i){
                            return cubit.messages[i].messageSenderID == cubit.userData!.userID ?
                            buildMyMessageItem(cubit.messages[i]) :
                            buildReceiverMessageItem(cubit.messages[i]);
                          },
                          separatorBuilder: (context,i)=>const SizedBox(height: 12,),
                          itemCount: cubit.messages.length,
                        ),
                      const Spacer(),
                      TextFormField(
                        controller: messageController,
                        onFieldSubmitted: (val)
                        {
                          cubit.sendMessage(message: messageController.text, messageReceiverID: receiverUserDataModel.userID!);
                        },
                        decoration: InputDecoration(
                            hintText: "type your message here",
                            contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                            suffixIcon: IconButton(
                              onPressed: ()
                              {
                                cubit.sendMessage(message: messageController.text, messageReceiverID: receiverUserDataModel.userID!);
                              },
                              color: Colors.teal,
                              icon: const Icon(Icons.send),
                            )
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
        );
      },
    );
  }

  Widget buildMyMessageItem(MessageDataModel model){
    return Row(
      children:
      [
        const Expanded(child: Text("")),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(0),bottomLeft: Radius.circular(10),topLeft: Radius.circular(10),bottomRight: Radius.circular(10))
              ),
              child: Text(model.message!,style: const TextStyle(fontWeight: FontWeight.w500),),
            ),
          ),),
      ],
    );
  }

  Widget buildReceiverMessageItem(MessageDataModel model){
    return Row(
      children:
      [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.4),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(10),bottomLeft: Radius.circular(10),topLeft: Radius.circular(0),bottomRight: Radius.circular(10))
              ),
              child: Text(model.message!,style: const TextStyle(fontWeight: FontWeight.w500),),
            ),
          ),),
        const Expanded(child: Text("")),
      ],
    );
  }
}
