import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/createUserImageScreen/create_userImage_Screen.dart';
import 'package:social_app/modules/sign_screens/cubit/signCubit.dart';
import '../../../layouts/homeLayoutScreen/home_layout_screen.dart';
import '../../../shared/components/components.dart';
import '../../../shared/styles/colors.dart';
import '../cubit/signStates.dart';
import 'login.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignCubit,SignStates>(
        listener: (context,state)
        {
          if(state is CreateUserErrorState)
          {
            showSnackBar(message: state.error.toString(), context: context, color: Colors.grey);
          }
          if(state is SaveUserDataErrorState)
          {
            showSnackBar(message: state.error.toString(), context: context, color: Colors.grey);
          }
          if(state is SaveUserDataSuccessState)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> CreateUserImageScreen()));
          }
        },
        builder: (context,state){
          SignCubit cubit = SignCubit.get(context);
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
                        const Text("Sign Up",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                        state is CreateUserLoadingState || state is SaveUserDataLoadingState || state is CreateUserSuccessState ?
                            const Center(child: CupertinoActivityIndicator(color: mainColor,),) :
                            defaultButton(
                                contentWidget: const Text("Sign Up",style: TextStyle(color: whiteColor),),
                                minWidth: double.infinity,
                                onTap: ()
                                {
                                  cubit.createUser(userName:userNameController.text,email: emailController.text, password: passwordController.text);
                                },
                                padding: const EdgeInsets.all(10),
                                roundedRectangleBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                            ),
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
