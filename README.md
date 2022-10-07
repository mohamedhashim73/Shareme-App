# Shareme-App
Full Social App using Dart , Flutter , Firebase , Bloc , SharedPreferences
some notes about the App
- made a post successfully and after that show it on profile screen at the same time as i use stream to get my posts.
- there is an issue as if i create a post and then go to homeLayoutScreen the post will not shown at the same time, it takes about 30 seconds.
- you can show the post in seperated screen after click on any image for post on profile screen.
- you can add a comment and show the comments for each post depend on postID.
- there is an issue that can't shown the total number for comments on the post at homeLayoutScreen.
- there is an issue that happen when you type a caption but after selecting a image for a post
   * can solve this by ListView or SingleChildScrollView but in this case I can not use add a image || add a link which exist on the end.
- there is an issue specically in Responsive after sending more messages that bigger than for the height of screen 
   * can solve this by ListView or SingleChildScrollView but I can use Spacer() in this case to make textFormField on the end.

