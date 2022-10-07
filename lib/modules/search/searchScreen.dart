import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/homeLayoutScreen/home_layout_screen.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/shared/components/components.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state){},
        builder: (context,state){
          return Scaffold(
            appBar: AppBar(leading: const Text(''),leadingWidth:0,title: Text("Search"),),
            body: MaterialButton(
              onPressed: ()
              {
                Navigator.pop(context);
                print("Tapped");
               //  Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeLayoutScreen()));
              },
              child: Text("Go to Home"),
            )
          );
        }
    );
  }
}
