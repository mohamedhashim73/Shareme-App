import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/layoutCubit/layoutCubit.dart';
import 'package:social_app/layouts/layoutCubit/layoutStates.dart';
import 'package:social_app/models/user_data_model.dart';

class SearchScreen extends StatelessWidget {
  final searchController = TextEditingController();

  SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit,LayoutStates>(
        listener: (context,state){},
        builder: (context,state){
          final cubit = LayoutCubit.getCubit(context);
          return Scaffold(
            appBar: AppBar(toolbarHeight: 25,),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children:
                [
                  const SizedBox(height: 15,),
                  TextFormField(
                    controller: searchController,
                    validator: (val)
                    {
                      return searchController.text.isEmpty ? "search must not be empty" : null;
                    },
                    onChanged: (input)
                    {
                      // cubit.searchForUser(input: input);
                    },
                    style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500,decoration: TextDecoration.none),
                    decoration: InputDecoration(
                      hintText: "search for user by his Name",
                      hintStyle: Theme.of(context).textTheme.caption!.copyWith(fontSize: 15),
                      prefixIcon: const Icon(Icons.search),
                      suffix: GestureDetector(
                        child: const Icon(Icons.close),
                        onTap: ()
                        {
                          searchController.text = '';
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      )
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Expanded(
                    child: cubit.searchData.isNotEmpty ?
                        ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 10,   // type cubit.searchData.length
                        itemBuilder: (context,index){
                          return buildUserItemShown();
                        },
                      ) :
                        const Center(child: Text("There is no users to shown",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),)
                  )
                ],
              ),
            )
          );
        }
    );
  }

  // build the item that user will be shown in this screen => after click on the user, will go to his profile
  Widget buildUserItemShown({UserDataModel? model}){
    return const ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: CircleAvatar(radius: 25,),     // model.image!
      title: Text("Mohamed Hashim Rezk"),    // model.userName!
      subtitle: Text("Software Engineer"),   // model.bio!
    );
  }
}
