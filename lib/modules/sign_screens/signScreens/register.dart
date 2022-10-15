import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/homeLayoutScreen/home_layout_screen.dart';
import 'package:social_app/modules/sign_screens/cubit/signCubit.dart';
import '../../../shared/components/components.dart';
import '../../../shared/styles/colors.dart';
import '../cubit/signStates.dart';
import 'login.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();
  final bioController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignCubit,SignStates>(
        listener: (context,state)
        {
          if(state is CreateUserErrorState)
          {
            showDefaultSnackBar(message: state.error.toString(), context: context, color: Colors.grey);
          }
          if(state is SaveUserDataErrorState)
          {
            showDefaultSnackBar(message: state.error.toString(), context: context, color: Colors.grey);
          }
          if(state is SaveUserDataSuccessState)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeLayoutScreen()));
          }
        },
        builder: (context,state){
          final cubit = SignCubit.get(context);
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      [
                        Center(
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                height: 125,
                                width: 125,
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(shape: BoxShape.circle,color: mainColor),
                              ),
                              Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: whiteColor,
                                    ),
                                    child: cubit.userImageFile != null ?
                                    Image(image: FileImage(cubit.userImageFile!)) :
                                    const Text(""),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      cubit.getUserImageFile();
                                    },
                                    child: const CircleAvatar(maxRadius: 15,child: Icon(Icons.photo_camera,size: 20,),),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20,),
                        defaultTextFormField(
                            inputType: TextInputType.name,
                            controller: userNameController,
                            prefixIcon: Icons.person_add,
                            hint: "UserName",
                            validateMethod: (val)
                            {
                              return emailController.text.isEmpty ? "UserName must not be empty" : null ;
                            }
                        ),
                        const SizedBox(height: 10,),
                        defaultTextFormField(
                            inputType: TextInputType.text,
                            controller: bioController,
                            prefixIcon: Icons.text_snippet_outlined,
                            hint: "Bio",
                            validateMethod: (val)
                            {
                              return bioController.text.isEmpty ? "Bio must not be empty" : null ;
                            }
                        ),
                        const SizedBox(height: 10,),
                        defaultTextFormField(
                            inputType: TextInputType.emailAddress,
                            controller: emailController,
                            prefixIcon: Icons.email,
                            hint: "Email",
                            validateMethod: (val)
                            {
                              return emailController.text.isEmpty ? "Email must not be empty" : null ;
                            }
                        ),
                        const SizedBox(height: 10,),
                        defaultTextFormField(
                            inputType: TextInputType.visiblePassword,
                            prefixIcon: Icons.password,
                            suffixIcon: InkWell(
                              onTap: (){print("Changed status!");},
                              child: const Icon(Icons.visibility_off),
                            ),
                            controller: passwordController,
                            secureStatus: true,
                            hint: "Password",
                            validateMethod: (val)
                            {
                              return emailController.text.isEmpty ? "Email must not be empty" : null ;
                            }
                        ),
                        const SizedBox(height: 20,),
                        defaultButton(
                            contentWidget: state is CreateUserLoadingState || state is SaveUserDataLoadingState || state is CreateUserSuccessState ?
                                const CupertinoActivityIndicator(color: whiteColor) :
                                const Text("Sign Up",style: TextStyle(color: whiteColor),),
                            minWidth: double.infinity,
                            onTap: ()
                            {
                              if( cubit.userImageFile != null && formKey.currentState!.validate() )
                              {
                                cubit.createUser(userName:userNameController.text,email: emailController.text, password: passwordController.text,bio: bioController.text);
                              }
                              else if ( cubit.userImageFile == null)
                              {
                                showDefaultSnackBar(message: "choose an Image and try again!", context: context, color: Colors.grey.withOpacity(1));
                              }
                              },
                            padding: const EdgeInsets.all(10),
                            roundedRectangleBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Already have an account?... "),
                            defaultTextButton(
                                title: const Text("Sign In",style: TextStyle(fontWeight:FontWeight.bold,fontSize:15,color: mainColor),),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}
