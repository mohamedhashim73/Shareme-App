abstract class SignStates{}

class InitialSignState extends SignStates{}

class CreateUserLoadingState extends SignStates{}

class CreateUserSuccessState extends SignStates{}

class CreateUserErrorState extends SignStates{
  final String error;
  CreateUserErrorState(this.error);
}


class ChosenUserImageSuccessfullyState extends SignStates{}

class ChosenUserImageErrorState extends SignStates{}

class SaveUserDataLoadingState extends SignStates{}

class SaveUserDataSuccessState extends SignStates{}

class SaveUserDataErrorState extends SignStates{
  String error;
  SaveUserDataErrorState(this.error);
}

class UserLoginLoadingState extends SignStates{}

class UserLoginSuccessState extends SignStates{}

class UserLoginErrorState extends SignStates{
  String error;
  UserLoginErrorState(this.error);
}
