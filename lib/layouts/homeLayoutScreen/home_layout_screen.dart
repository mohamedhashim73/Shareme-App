import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/components/constants.dart';
import '../layoutCubit/layoutCubit.dart';
import '../layoutCubit/layoutStates.dart';

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
              const BottomNavigationBarItem(icon: Icon(Icons.messenger_outline),label: 'null'),
              BottomNavigationBarItem(
                  icon: Container(
                      clipBehavior: Clip.hardEdge,
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey)
                      ),
                      child : cubit.userData?.image != null? Image.network(cubit.userData!.image!,fit: BoxFit.cover,) : const Text("")),
                  label: 'null'
              ),
            ],
            currentIndex: cubit.bottomNavIndex,
            onTap: (index)
            {
              cubit.changeBottomNavIndex(index);
            },
          ),
          body: cubit.layoutWidgets[cubit.bottomNavIndex],
        );
      },
    );
  }
}
