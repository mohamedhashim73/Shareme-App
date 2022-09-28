import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

// Widget for cached_network_image
Widget customCacheNetworkImage({dynamic imageUrl}){
  return CachedNetworkImage(
    imageUrl: imageUrl?? "https://student.valuxapps.com/storage/uploads/users/LLnK6Hgq8c_1663616268.jpeg",
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
      ),
    ),
    placeholder: (context, url) => const CircularProgressIndicator(),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}

void showSnackBar({required String message,required BuildContext context,required Color color}){
  var snackBar = SnackBar(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    content: Text(message,textAlign: TextAlign.center,),
    clipBehavior: Clip.hardEdge,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 70,vertical: 15),
    padding: const EdgeInsets.all(10),
    backgroundColor: color,
    duration: const Duration(seconds: 1),);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}