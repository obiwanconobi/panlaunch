import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_apps/models.dart';
import 'package:get_it/get_it.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:localstore/localstore.dart';
import 'package:panlaunch/widgets/get_apps_list.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:panlaunch/widgets/step_count_widget.dart';
import 'package:pedometer/pedometer.dart';
import 'controllers/get_apps_controller.dart';
import 'package:permission_handler/permission_handler.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  final db = Localstore.instance;
  var controller = GetIt.instance<GetAppsController>();



  @override
  void initState() {
    super.initState();
     appListFuture = getApps2();
  }
  List<AppInfo> appList = [];
  late Future<List<AppInfo>> appListFuture;
   Map<String, dynamic>? rawApps;

  Future<List<AppInfo>> getApps2()async{
    List<AppInfo> returnList = [];
    rawApps = (await db.collection('homeApps').get());
    List<int> test = [];



    if(rawApps != null){
      for(var item in rawApps!.values){
        Uint8List bytes = Uint8List.fromList(test);
        returnList.add(AppInfo(appName: item["title"]!, appPackage: item["packageName"]!, appIcon: bytes));
      }
    }
    return returnList;

  }

  refresh(){
    setState(() {
      appListFuture = getApps2();
    });
  }

  removeFromHomeScreen(String packageName)async{
  //  final data = await db.collection('homeApps').where('packageName', isEqualTo: packageName).get();

    var matchingKeys = rawApps?.entries
        .where((entry) => entry.value["packageName"] == packageName)
        .map((entry) => entry.key)
        .toList();

    var id = matchingKeys?.first.replaceAll("/homeApps/", "");

    db.collection('homeApps').doc(id).delete();


  }

  launchApp(String packageName)async{
    InstalledApps.startApp(packageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: GetAppsList(),
      appBar: null,
      body: RefreshIndicator(
        onRefresh: () => refresh(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Center(
              child:  Column(
                children: [
                  AnalogClock.dark(secondHandColor: null,),
                  StepCountWidget(),
                  Expanded(
                    child: FutureBuilder<List<AppInfo>>(
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
                              child: Column(
                                children: [
                                  Text('Add Apps To Home Screen', style: TextStyle(color: Colors.white),),
                                  IconButton(
                                    icon: const Icon(Icons.menu),
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      refresh();
                                    },
                                  ),
                                ],
                              ),

                            );
                          } else {
                            // Data is available, build the list
                            appList = snapshot.data!;
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: appList.length,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(40, 20, 8, 0),
                                          child: InkWell(
                                            onLongPress: () => removeFromHomeScreen(appList[index].appPackage),
                                            onTap: () => launchApp(appList[index].appPackage),
                                              child: Text(appList[index].appName ?? "",  style: TextStyle(fontSize: 20, color: Colors.white),)),
                                        );
                                      }
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.menu),
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.refresh),
                                        onPressed: () {
                                          refresh();
                                        },
                                      ),
                                    ],
                                  ),
                                ],),
                            );
                          }
                        }),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}
