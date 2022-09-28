import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/layoutCubit.dart';
import 'package:social_app/layouts/cubit/layoutStates.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/colors.dart';

class EditProfileScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final nameController = TextEditingController();
  final userNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state) {
          if( state is UpdateUserDataWithoutImageSuccessState )
          {
            showSnackBar(message: "User Data Updated successfully!", context: context, color: Colors.grey);
            Navigator.pushReplacementNamed(context, 'homeLayoutScreen');
          }
        },
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          emailController.text = cubit.userData!.email!;
          nameController.text = cubit.userData!.name!;
          userNameController.text = cubit.userData!.userName!;
          bioController.text = cubit.userData!.bio!;
          return Scaffold(
              appBar: AppBar(
                leading: InkWell(
                  onTap: (){
                    // made this function as if i change profile photo but canceled update imageProfileUrl will show on EditProfileScreen as i canceled update and i use profileImageUrl to be shown not userData!.image
                    cubit.canceledUpdateUserData();    // for this reason i made this function canceledUpdateUserData()
                    Navigator.pop(context);
                    },
                  child: const Icon(Icons.arrow_back_ios),
                ),
                title: const Text("Edit",style: TextStyle(fontSize: 18),),
                titleSpacing: 7.5,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: state is UpdateUserDataWithImageLoadingState || state is UpdateUserDataWithoutImageLoadingState?
                    const CupertinoActivityIndicator(color: mainColor,) :
                    InkWell(
                      onTap: ()
                      {
                        if( cubit.userImageFile != null )
                        {
                          cubit.updateUserDataWithImage(name: nameController.text,userName: userNameController.text,email: emailController.text,bio: bioController.text);
                        }
                        else
                        {
                          cubit.updateUserDataWithoutImage(name: nameController.text,userName: userNameController.text,email: emailController.text,bio: bioController.text);
                        }
                      },
                      child: const Icon(Icons.done),),
                  ),
                ],
              ),
              body: cubit.userData == null ?
              const CircularProgressIndicator(color: mainColor) :
              Form(
                key: formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                      [
                        Center(
                          child: Container(
                              height: 120,
                              width: 120,
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                              ),
                            // made this function as if i change profile photo but canceled update imageProfileUrl will show on EditProfileScreen as i canceled update and i use profileImageUrl to be shown not userData!.image
                            child: cubit.userImageFile != null && state is! CanceledUpdateUserDataState?
                            Image(image: FileImage(cubit.userImageFile!)) :
                            Image(image: NetworkImage(cubit.userData!.image!),),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        defaultTextButton(
                            title: Text("change Profile Photo",style: Theme.of(context).textTheme.headline6!.copyWith(color: mainColor)),
                            onTap: (){
                              cubit.getProfileImage();
                            },width: double.infinity,alignment: Alignment.center
                        ),
                        const SizedBox(height: 30,),
                        specificTextFormField(
                          label: "UserName",
                            inputType: TextInputType.name,
                            controller: userNameController,
                            validator: (val)
                            {
                              return emailController.text.isEmpty ? "UserName must not be empty" : null ;
                            }
                        ),
                        const SizedBox(height: 20,),
                        specificTextFormField(
                          label: "Name",
                            inputType: TextInputType.name,
                            controller: nameController,
                            validator: (val)
                            {
                              return emailController.text.isEmpty ? "Name must not be empty" : null ;
                            }
                        ),
                        const SizedBox(height: 20,),
                        specificTextFormField(
                          label: "Email",
                            inputType: TextInputType.emailAddress,
                            controller: emailController,
                            validator: (val)
                            {
                              return emailController.text.isEmpty ? "Email must not be empty" : null ;
                            }
                        ),
                        const SizedBox(height: 20,),
                        specificTextFormField(
                            label: "Bio",
                            inputType: TextInputType.text,
                            controller: bioController,
                            validator: (val)
                            {
                              return bioController.text.isEmpty ? "bio must not be empty" : null ;
                            }
                        ),
                      ]
                    ),
                  ),
                ),
              )
          );
        }
    );
  }

  Widget specificTextFormField({required String label,required TextEditingController controller,required TextInputType inputType,required dynamic validator}){
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: const UnderlineInputBorder(),
      ),
    );
  }
}
