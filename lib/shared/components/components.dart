import 'package:flutter/material.dart';
import '../../models/commentModel.dart';
import '../styles/colors.dart';

Widget buildDividerItem(){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: Divider(thickness: 0.5,color: Colors.grey.withOpacity(0.5),),
  );
}
// use it in post in suffix icon to show menu like delete post and under this update post and so on
void showDefaultMenuItem({required String title,required Function() method,required BuildContext context}){
  showMenu(
      context: context,
      elevation: 1,
      position: const RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),
      items:
      [
        PopupMenuItem(
          onTap: method,
          child: Text(title),
        )
      ]
  );
}

Widget defaultTextFormField({required TextInputType inputType,bool secureStatus = false,required TextEditingController controller,required dynamic validateMethod, String? label,String? hint,Widget? suffixIcon,IconData? prefixIcon}){
  return TextFormField(
    keyboardType: inputType,
    obscureText: secureStatus,
    validator: validateMethod,
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      prefixIcon: Icon(prefixIcon),
      border: UnderlineInputBorder() ,
    ),
  );
}

Widget defaultButton({required Function() onTap,required Widget contentWidget,double? height,double? minWidth,dynamic padding,Color backgroundColor = Colors.teal,dynamic roundedRectangleBorder}){
  return MaterialButton(
      onPressed: onTap,
      height: height,
      minWidth: minWidth,
      padding: padding,
      elevation: 0,
      hoverColor: Colors.red,
      color: backgroundColor,
      shape: roundedRectangleBorder,
      child: contentWidget,
  );
}

Widget defaultTextButton({required Widget title,required Function() onTap,double? width,dynamic alignment}){
  return Container(
    alignment: alignment,
    width: width,
    child: InkWell(
      onTap: onTap,
      child: title,
    ),
  );
}

void showDefaultSnackBar({required String message,required BuildContext context,required Color color,double elevation = 0 }){
  var snackBar = SnackBar(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    elevation: elevation,
    content: Text(message,textAlign: TextAlign.center,),
    clipBehavior: Clip.hardEdge,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 70,vertical: 15),
    padding: const EdgeInsets.all(10),
    backgroundColor: color,
    duration: const Duration(seconds: 1),);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget buildCommentItem({required CommentDataModel model,required BuildContext context,required int commentsLength}){
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: commentsLength,
    itemBuilder: (context,i){
      return Row(
        children:
        [
          CircleAvatar(
            radius: 27,
            backgroundImage: NetworkImage(model.commentMakerImage!),
          ),
          const SizedBox(width: 10,),
          Expanded(
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),border: Border.all(color: Colors.grey.withOpacity(0.5))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text(model.commentMakerName!),
                      Text(model.comment!,style: TextStyle(color: blackColor.withOpacity(0.7),fontSize: 14.5),),
                    ],
                  )
              )
          ),
        ],
      );
    }, separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 5),
  );
}
