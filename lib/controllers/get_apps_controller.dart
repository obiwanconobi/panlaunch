import 'package:get_apps/get_apps.dart';
import 'package:get_apps/models.dart';

class GetAppsController{
  List<AppInfo> appList = [];
  late Future<List<AppInfo>> appListFuture;

  Future<List<AppInfo>> getApps2()async{
    List<AppInfo> apps = await GetApps().getApps();
    apps.sort((e, f) => e.appName.toLowerCase().compareTo(f.appName.toLowerCase()));
    //apps.removeWhere((test) => test.packageName.startsWith("com.android"));

    return apps;
  }


}