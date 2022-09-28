import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/layoutCubit.dart';
import 'package:social_app/layouts/cubit/layoutStates.dart';

import '../../shared/components/constants.dart';

class HomeLayoutScreen extends StatelessWidget {
  const HomeLayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
      listener:(context,state){},
      builder:(context,state){
        final cubit = LayoutCubit.getCubit(context);
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home),label: 'null'),
              const BottomNavigationBarItem(icon: Icon(Icons.search),label: 'null'),
              const BottomNavigationBarItem(icon: CircleAvatar(maxRadius: 18,child: Icon(Icons.add,),),label: 'null'),
              const BottomNavigationBarItem(icon: Icon(Icons.settings),label: 'null'),
              BottomNavigationBarItem(icon: CircleAvatar(radius:15.0,backgroundImage: NetworkImage(cubit.userData?.image.toString()?? defaultUserImage)),label: 'null'),
            ],
            currentIndex: cubit.bottomNavIndex,
            onTap: (index){
              cubit.changeBottomNavIndex(index);
              if( index == 2 ) Navigator.pushNamed(context, 'createPostScreen');
            },
          ),
          body: cubit.layoutWidgets[cubit.bottomNavIndex],
        );
      },
    );
  }
}
