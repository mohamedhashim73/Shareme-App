import 'package:shared_preferences/shared_preferences.dart';
class CacheHelper{
  static SharedPreferences? sharedPreferences;
  static Future cacheInit() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }
  // method for save data on cache
  static Future<bool?> saveCacheData({required String key,required dynamic val}) async {
    if( val is int )
      {
        await sharedPreferences?.setInt(key, val);
        return true;
      }
    if( val is String )
    {
      await sharedPreferences?.setString(key, val);
      return true;
    }
    if( val is bool )
    {
      await sharedPreferences?.setBool(key, val);
      return true;
    }
    if( val is double )
    {
      await sharedPreferences?.setDouble(key, val);
      return true;
    }
    return false;
  }
  // method for get data
  static dynamic getCacheData({required String key}){
    return sharedPreferences?.get(key) ;
  }

  static Future<bool> deleteCacheData({required String key}) async{
    await sharedPreferences?.remove(key);
    return true;
  }
}