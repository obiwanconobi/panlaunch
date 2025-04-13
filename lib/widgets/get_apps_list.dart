import 'package:flutter/material.dart';
import 'package:get_apps/models.dart';
import 'package:get_it/get_it.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:localstore/localstore.dart';

import '../controllers/get_apps_controller.dart';

class GetAppsList extends StatefulWidget {
  const GetAppsList({super.key});

  @override
  State<GetAppsList> createState() => _GetAppsListState();
}

class _GetAppsListState extends State<GetAppsList> {
  var controller = GetIt.instance<GetAppsController>();

  List<AppInfo> appList = [];
  late Future<List<AppInfo>> appListFuture;

  final db = Localstore.instance;
  @override
  void initState() {
    super.initState();
    appListFuture = controller.getApps2();
  }


  launchApp(String packageName)async{
    InstalledApps.startApp(packageName);
  }

  saveApp(AppInfo app){
    // gets new id
    final id = db.collection('homeApps').doc().id;

// save the item
    db.collection('homeApps').doc(id).set({
      'title': app.appName,
      'packageName': app.appPackage,
      'icon': app.appIcon
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppInfo>>(
        future: appListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              //child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('no_data_error'),
            );
          } else {
            // Data is available, build the list
            appList = snapshot.data!;
            return Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                color: Colors.blue,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: appList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
                        child: Container(
                            color: Colors.blue,
                            child: InkWell(
                              onLongPress: () => saveApp(appList[index]),
                                onTap: () => launchApp(appList[index].appPackage),
                                child: Text(appList[index].appName ?? "", style: TextStyle(fontSize: 20),))),
                      );
                    }
                ),
              ),
            );
          }
        });
  }
}
