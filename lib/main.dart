import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/createUserImageScreen/create_userImage_Screen.dart';
import 'package:social_app/layouts/cubit/layoutCubit.dart';
import 'package:social_app/layouts/homeLayoutScreen/home_layout_screen.dart';
import 'package:social_app/modules/create_post/createPostScreen.dart';
import 'package:social_app/modules/edit_profile/editProfileScreen.dart';
import 'package:social_app/modules/profile/profileScreen.dart';
import 'package:social_app/modules/sign_screens/cubit/signCubit.dart';
import 'package:social_app/modules/sign_screens/signScreens/login.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/network/local/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'firebase_options.dart';
import 'layouts/bloc_observer.dart';
import 'modules/sign_screens/signScreens/register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.cacheInit();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  userID = CacheHelper.getCacheData(key: 'uid');
  passedChosenImage = CacheHelper.getCacheData(key: 'passedChosenImage')?? false;
  print("User ID is $userID");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers:
        [
          BlocProvider(create: (BuildContext context)=>SignCubit()),
          BlocProvider(create: (BuildContext context)=>LayoutCubit()..getUserData()..getAllUsersData()..getPostsForUser()..getPostsForAllUsers()),
        ],
        child: MaterialApp(
          home: userID != null && passedChosenImage == true ? const HomeLayoutScreen() : userID == null ? LoginScreen() : const CreateUserImageScreen(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.teal,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: blackColor,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              unselectedItemColor: Colors.grey,
              selectedItemColor: mainColor,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              selectedIconTheme: IconThemeData(size: 28),
              unselectedIconTheme: IconThemeData(size: 25),
            ),
          ),
          routes:
          {
            'register' : (context)=>RegisterScreen(),
            'login' : (context)=>LoginScreen(),
            'createUserImageScreen' : (context)=> const CreateUserImageScreen(),
            'createPostScreen' : (context)=> CreatePostScreen(),
            'editProfileScreen' : (context)=>EditProfileScreen(),
            'homeLayoutScreen' : (context)=>const HomeLayoutScreen(),
          },
        ),
    );
  }
}
