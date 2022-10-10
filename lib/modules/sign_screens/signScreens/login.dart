import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/homeLayoutScreen/home_layout_screen.dart';
import 'package:social_app/modules/sign_screens/cubit/signCubit.dart';
import 'package:social_app/modules/sign_screens/cubit/signStates.dart';
import 'package:social_app/modules/sign_screens/signScreens/register.dart';
import '../../../shared/components/components.dart';
import '../../../shared/styles/colors.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignCubit,SignStates>(
        listener: (context,state){
          if(state is UserLoginSuccessState)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeLayoutScreen()));
          }
          if(state is UserLoginErrorState)
          {
            showDefaultSnackBar(message: state.error.toString(), context: context, color: Colors.grey);
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
                        const Text("Sign In",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                        const SizedBox(height: 20,),
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
                        const SizedBox(height: 15,),
                        defaultTextButton(title: const Text("Forget Password?"),onTap:(){},width: double.infinity,alignment: Alignment.centerRight),
                        const SizedBox(height: 20,),
                        defaultButton(
                            contentWidget: state is UserLoginLoadingState ?
                                const Center(child: CircularProgressIndicator(color: whiteColor),) :
                                const Text("Sign In",style: TextStyle(color: whiteColor),),
                            minWidth: double.infinity,
                            onTap: ()
                            {
                              cubit.userLogin(email: emailController.text, password: passwordController.text);
                            },
                            padding: const EdgeInsets.all(10),
                            roundedRectangleBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                        ),
                        const SizedBox(height: 10,),
                        defaultButton(
                            contentWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircleAvatar(
                                  maxRadius: 10,
                                  backgroundImage: (AssetImage("images/google.png")),
                                ),
                                SizedBox(width: 10,),
                                Text("Sign In with Google",style: TextStyle(color: whiteColor),),
                              ],
                            ),
                            minWidth: double.infinity,
                            onTap: (){print("Tapped!");},
                            padding: const EdgeInsets.all(10),
                            roundedRectangleBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?..."),
                            defaultTextButton(
                                title: const Text("Sign Up",style: TextStyle(fontWeight:FontWeight.bold,fontSize:15,color: mainColor),),
                                onTap: ()
                                {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterScreen()));
                                }
                                ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
