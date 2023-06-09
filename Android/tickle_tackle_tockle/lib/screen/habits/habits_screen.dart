import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tickle_tackle_tockle/const/theme.dart';
import 'package:tickle_tackle_tockle/controller/edit_habit_controller.dart';
import '../../component/common_appbar.dart';
import '../../const/serveraddress.dart';
import '../../controller/loading_controller.dart';
import '../../controller/page_change_controller.dart';
import '../../controller/theme_controller.dart';
import 'package:get/get.dart';

import '../../model/HabitRes.dart';
import 'habit_edit_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  buildWeekRow({
    bool sun = false,
    bool mon = false,
    bool tue = false,
    bool wed = false,
    bool thu = false,
    bool fri = false,
    bool sat = false,
    Color themeColor = TTTPrimary1
  }) {
    const double checkMaxRadius = 10;
    const double checkMinRadius = 8;
    const double checkFontSize = 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          backgroundColor: sun ? themeColor : TTTWhite,
          maxRadius: checkMaxRadius,
          child: const CircleAvatar(
            backgroundColor: TTTWhite,
            maxRadius: checkMinRadius,
            child: Text('일', style: TextStyle(color: TTTPrimary1, fontSize: checkFontSize,)),
          ),
        ),
        CircleAvatar(
          backgroundColor: mon ? themeColor : TTTWhite,
          maxRadius: checkMaxRadius,
          child: const CircleAvatar(
            backgroundColor: TTTWhite,
            maxRadius: checkMinRadius,
            child: Text('월', style: TextStyle(color: TTTBlack, fontSize: checkFontSize,)),
          ),
        ),
        CircleAvatar(
          backgroundColor: tue ? themeColor : TTTWhite,
          maxRadius: checkMaxRadius,
          child: const CircleAvatar(
            backgroundColor: TTTWhite,
            maxRadius: checkMinRadius,
            child: Text('화', style: TextStyle(color: TTTBlack, fontSize: checkFontSize,)),
          ),
        ),
        CircleAvatar(
          backgroundColor: wed ? themeColor : TTTWhite,
          maxRadius: checkMaxRadius,
          child: const CircleAvatar(
            backgroundColor: TTTWhite,
            maxRadius: checkMinRadius,
            child: Text('수', style: TextStyle(color: TTTBlack, fontSize: checkFontSize,)),
          ),
        ),
        CircleAvatar(
          backgroundColor: thu ? themeColor : TTTWhite,
          maxRadius: checkMaxRadius,
          child: const CircleAvatar(
            backgroundColor: TTTWhite,
            maxRadius: checkMinRadius,
            child: Text('목', style: TextStyle(color: TTTBlack, fontSize: checkFontSize,)),
          ),
        ),
        CircleAvatar(
          backgroundColor: fri ? themeColor : TTTWhite,
          maxRadius: checkMaxRadius,
          child: const CircleAvatar(
            backgroundColor: TTTWhite,
            maxRadius: checkMinRadius,
            child: Text('금', style: TextStyle(color: TTTBlack, fontSize: checkFontSize,)),
          ),
        ),
        CircleAvatar(
          backgroundColor: sat ? themeColor : TTTWhite,
          maxRadius: checkMaxRadius,
          child: const CircleAvatar(
            backgroundColor: TTTWhite,
            maxRadius: checkMinRadius,
            child: Text('토', style: TextStyle(color: TTTPrimary1, fontSize: checkFontSize,)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double deviceWidth = size.width;
    final double deviceHeight = size.height;



    LoadingController loadingController = Get.put(LoadingController());
    ThemeController themeController = Get.put(ThemeController());
    PageChangeController pageChangeController = Get.put(PageChangeController());
    EditHabitController editHabitController = Get.put(EditHabitController());

    Future<http.Response> sendAccessToken() async {

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String accessToken = sharedPreferences.getString('accessToken')!;
      var url = Uri.parse('${ServerUrl}/habit');
      var response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'accesstoken' :  accessToken,
        },
      );
      return response;
    }

    Future<List<HabitRes>> checkAccessToken() async {
      final response = await sendAccessToken();
      List<HabitRes> habitList = [];

      if (response.statusCode == 200) {
        habitList = parseHabitList(utf8.decode(response.bodyBytes));

      }else if(response.statusCode == 401){
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        String accessToken = sharedPreferences.getString('accessToken')!;
        String refreshToken = sharedPreferences.getString('refreshToken')!;
        var url = Uri.parse('${ServerUrl}/habit');
        var response = await http.get(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'accesstoken' :  accessToken,
            'refreshtoken' : refreshToken,
          },
        );

        habitList = parseHabitList(utf8.decode(response.bodyBytes));
      }
      else {
        print('Login failed with status: ${response.statusCode}');
      }
      return habitList;
    }

    buildMoneyHabitsList(List<HabitRes> totalHabitsList) {
      List<Widget> columHabit = [];
      List<HabitRes>  habitList = [];

      for(int i=0;i<totalHabitsList.length;i++){
        HabitRes habitRes = totalHabitsList[i];
        if(habitRes.categoryId==0){
          habitList.add(habitRes);
        }
      }

      if(habitList.length > 0) {
        for(int i = 0; i < habitList.length; i++) {
          HabitRes habitRes = habitList[i];
          int id = habitRes.id;
          String emoji = habitRes.emoji;
          String name = habitRes.name;
          String repeatDay = habitRes.repeatDay;
          int tickleCount = habitRes.tickleCount;
          String repeatTime = habitRes.term;
          String startTime = habitRes.startTime;
          String endTime = habitRes.endTime;
          List<bool> week = [];
          for(int i=0;i<7;i++){
            String day = repeatDay[i];
            if(day=='1') week.add(true);
            else week.add(false);
          }

          columHabit.add(Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  editHabitController.id = id;
                  editHabitController.category = '금전';
                  editHabitController.name = name;
                  editHabitController.emoji = emoji;
                  editHabitController.repeatWeek = repeatDay;
                  editHabitController.repeatTime = repeatTime;
                  editHabitController.startTime = startTime;
                  editHabitController.endTime = endTime;

                  if(editHabitController.repeatTime == '2400') {
                    editHabitController.isAlarmRepeat = false;
                    editHabitController.alarmTime = editHabitController.startTime;
                  } else {
                    editHabitController.isAlarmRepeat = true;
                  }

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const HabitEditScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(emoji,),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Column(
                              children: [
                                Text(name, style: TextStyle(fontSize: 18)),
                                SizedBox(height: 5,),
                                buildWeekRow(
                                  sun: week[0],
                                  mon: week[1],
                                  tue: week[2],
                                  wed: week[3],
                                  thu: week[4],
                                  fri: week[5],
                                  sat: week[6],
                                  themeColor: themeController.selectedPrimaryColor,),
                              ],
                            );
                          }
                      ),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Text('$tickleCount 달성', style: TextStyle(color: themeController.selectedPrimaryColor),);
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('금전', style: TextStyle(fontSize: 25,)),
              ],
            ),
            Column(
              children: columHabit,
            ),
          ],
        );
      } else {
        return Container();
      }
    }

    buildExerciseHabitsList(List<HabitRes> totalHabitsList) {
      List<Widget> columHabit = [];
      List<HabitRes>  habitList = [];

      for(int i=0;i<totalHabitsList.length;i++){
        HabitRes habitRes = totalHabitsList[i];
        if(habitRes.categoryId==1){
          habitList.add(habitRes);
        }
      }

      if(habitList.length > 0) {
        for(int i = 0; i < habitList.length; i++) {
          HabitRes habitRes = habitList[i];
          int id = habitRes.id;
          String emoji = habitRes.emoji;
          String name = habitRes.name;
          String repeatDay = habitRes.repeatDay;
          int tickleCount = habitRes.tickleCount;
          String repeatTime = habitRes.term;
          String startTime = habitRes.startTime;
          String endTime = habitRes.endTime;

          List<bool> week = [];
          for(int i=0;i<7;i++){
            String day = repeatDay[i];
            if(day=='1') week.add(true);
            else week.add(false);
          }

          columHabit.add(Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  //누른 습관의 값을 받아와서 컨트롤러에 저장하면 됨
                  editHabitController.id = id;
                  editHabitController.category = '운동';
                  editHabitController.name = name;
                  editHabitController.emoji = emoji;
                  editHabitController.repeatWeek = repeatDay;
                  editHabitController.repeatTime = repeatTime;
                  editHabitController.startTime = startTime;
                  editHabitController.endTime = endTime;

                  if(editHabitController.repeatTime == '2400') {
                    editHabitController.isAlarmRepeat = false;
                    editHabitController.alarmTime = editHabitController.startTime;
                  } else {
                    editHabitController.isAlarmRepeat = true;
                  }

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const HabitEditScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(emoji,),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Column(
                              children: [
                                Text(name, style: TextStyle(fontSize: 18)),
                                SizedBox(height: 5,),
                                buildWeekRow(
                                  sun: week[0],
                                  mon: week[1],
                                  tue: week[2],
                                  wed: week[3],
                                  thu: week[4],
                                  fri: week[5],
                                  sat: week[6],
                                  themeColor: themeController.selectedPrimaryColor,),
                              ],
                            );
                          }
                      ),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Text('$tickleCount 달성', style: TextStyle(color: themeController.selectedPrimaryColor),);
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
        }
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('운동', style: TextStyle(fontSize: 25,)),
              ],
            ),
            Column(
              children: columHabit,
            ),
          ],
        );
      } else {
        return Container();
      }

    }

    buildStudyHabitsList(List<HabitRes> totalHabitsList) {
      List<Widget> columHabit = [];
      List<HabitRes>  habitList = [];

      for(int i=0;i<totalHabitsList.length;i++){
        HabitRes habitRes = totalHabitsList[i];
        if(habitRes.categoryId==2){
          habitList.add(habitRes);
        }
      }

      if(habitList.length > 0) {
        for(int i = 0; i < habitList.length; i++) {
          HabitRes habitRes = habitList[i];
          int id = habitRes.id;
          String emoji = habitRes.emoji;
          String name = habitRes.name;
          String repeatDay = habitRes.repeatDay;
          int tickleCount = habitRes.tickleCount;
          String repeatTime = habitRes.term;
          String startTime = habitRes.startTime;
          String endTime = habitRes.endTime;
          List<bool> week = [];
          for(int i=0;i<7;i++){
            String day = repeatDay[i];
            if(day=='1') week.add(true);
            else week.add(false);
          }

          columHabit.add(Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  editHabitController.id = id;
                  editHabitController.category = '학습';
                  editHabitController.name = name;
                  editHabitController.emoji = emoji;
                  editHabitController.repeatWeek = repeatDay;
                  editHabitController.repeatTime = repeatTime;
                  editHabitController.startTime = startTime;
                  editHabitController.endTime = endTime;

                  if(editHabitController.repeatTime == '2400') {
                    editHabitController.isAlarmRepeat = false;
                    editHabitController.alarmTime = editHabitController.startTime;
                  } else {
                    editHabitController.isAlarmRepeat = true;
                  }

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const HabitEditScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(emoji,),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Column(
                              children: [
                                Text(name, style: TextStyle(fontSize: 18)),
                                SizedBox(height: 5,),
                                buildWeekRow(
                                  sun: week[0],
                                  mon: week[1],
                                  tue: week[2],
                                  wed: week[3],
                                  thu: week[4],
                                  fri: week[5],
                                  sat: week[6],
                                  themeColor: themeController.selectedPrimaryColor,),
                              ],
                            );
                          }
                      ),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Text('$tickleCount 달성', style: TextStyle(color: themeController.selectedPrimaryColor),);
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
        }
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('학습', style: TextStyle(fontSize: 25,)),
              ],
            ),
            Column(
              children: columHabit,
            ),
          ],
        );
      } else {
        return Container();
      }

    }

    buildRelationshipHabitsList(List<HabitRes> totalHabitsList) {
      List<Widget> columHabit = [];
      List<HabitRes>  habitList = [];

      for(int i=0;i<totalHabitsList.length;i++){
        HabitRes habitRes = totalHabitsList[i];
        if(habitRes.categoryId==3){
          habitList.add(habitRes);
        }
      }

      if(habitList.length > 0) {
        for(int i = 0; i < habitList.length; i++) {
          HabitRes habitRes = habitList[i];
          int id = habitRes.id;
          String emoji = habitRes.emoji;
          String name = habitRes.name;
          String repeatDay = habitRes.repeatDay;
          int tickleCount = habitRes.tickleCount;
          String repeatTime = habitRes.term;
          String startTime = habitRes.startTime;
          String endTime = habitRes.endTime;
          List<bool> week = [];
          for(int i=0;i<7;i++){
            String day = repeatDay[i];
            if(day=='1') week.add(true);
            else week.add(false);
          }

          columHabit.add(Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  editHabitController.id = id;
                  editHabitController.category = '관계';
                  editHabitController.name = name;
                  editHabitController.emoji = emoji;
                  editHabitController.repeatWeek = repeatDay;
                  editHabitController.repeatTime = repeatTime;
                  editHabitController.startTime = startTime;
                  editHabitController.endTime = endTime;

                  if(editHabitController.repeatTime == '2400') {
                    editHabitController.isAlarmRepeat = false;
                    editHabitController.alarmTime = editHabitController.startTime;
                  } else {
                    editHabitController.isAlarmRepeat = true;
                  }

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const HabitEditScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(emoji,),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Column(
                              children: [
                                Text(name, style: TextStyle(fontSize: 18)),
                                SizedBox(height: 5,),
                                buildWeekRow(
                                  sun: week[0],
                                  mon: week[1],
                                  tue: week[2],
                                  wed: week[3],
                                  thu: week[4],
                                  fri: week[5],
                                  sat: week[6],
                                  themeColor: themeController.selectedPrimaryColor,),
                              ],
                            );
                          }
                      ),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Text('$tickleCount 달성', style: TextStyle(color: themeController.selectedPrimaryColor),);
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
        }
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('관계', style: TextStyle(fontSize: 25,)),
              ],
            ),
            Column(
              children: columHabit,
            ),
          ],
        );
      } else {
        return Container();
      }
    }

    buildLifeHabitsList(List<HabitRes> totalHabitsList) {
      List<Widget> columHabit = [];
      List<HabitRes>  habitList = [];

      for(int i=0;i<totalHabitsList.length;i++){
        HabitRes habitRes = totalHabitsList[i];
        if(habitRes.categoryId==4){
          habitList.add(habitRes);
        }
      }

      if(habitList.length > 0) {
        for(int i = 0; i < habitList.length; i++) {
          HabitRes habitRes = habitList[i];
          int id = habitRes.id;
          String emoji = habitRes.emoji;
          String name = habitRes.name;
          String repeatDay = habitRes.repeatDay;
          int tickleCount = habitRes.tickleCount;
          String repeatTime = habitRes.term;
          String startTime = habitRes.startTime;
          String endTime = habitRes.endTime;
          List<bool> week = [];
          for(int i=0;i<7;i++){
            String day = repeatDay[i];
            if(day=='1') week.add(true);
            else week.add(false);
          }

          columHabit.add(Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  editHabitController.id = id;
                  editHabitController.category = '생활';
                  editHabitController.name = name;
                  editHabitController.emoji = emoji;
                  editHabitController.repeatWeek = repeatDay;
                  editHabitController.repeatTime = repeatTime;
                  editHabitController.startTime = startTime;
                  editHabitController.endTime = endTime;

                  if(editHabitController.repeatTime == '2400') {
                    editHabitController.isAlarmRepeat = false;
                    editHabitController.alarmTime = editHabitController.startTime;
                  } else {
                    editHabitController.isAlarmRepeat = true;
                  }

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const HabitEditScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(emoji,),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Column(
                              children: [
                                Text(name, style: TextStyle(fontSize: 18)),
                                SizedBox(height: 5,),
                                buildWeekRow(
                                  sun: week[0],
                                  mon: week[1],
                                  tue: week[2],
                                  wed: week[3],
                                  thu: week[4],
                                  fri: week[5],
                                  sat: week[6],
                                  themeColor: themeController.selectedPrimaryColor,),
                              ],
                            );
                          }
                      ),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Text('$tickleCount 달성', style: TextStyle(color: themeController.selectedPrimaryColor),);
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
        }
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('생활', style: TextStyle(fontSize: 25,)),
              ],
            ),
            Column(
              children: columHabit,
            ),
          ],
        );
      } else {
        return Container();
      }
    }

    buildEtcHabitsList(List<HabitRes> totalHabitsList) {
      List<Widget> columHabit = [];
      List<HabitRes>  habitList = [];

      for(int i=0;i<totalHabitsList.length;i++){
        HabitRes habitRes = totalHabitsList[i];
        if(habitRes.categoryId==5){
          habitList.add(habitRes);
        }
      }

      if(habitList.length > 0) {
        for(int i = 0; i < habitList.length; i++) {
          HabitRes habitRes = habitList[i];
          int id = habitRes.id;
          String emoji = habitRes.emoji;
          String name = habitRes.name;
          String repeatDay = habitRes.repeatDay;
          int tickleCount = habitRes.tickleCount;
          String repeatTime = habitRes.term;
          String startTime = habitRes.startTime;
          String endTime = habitRes.endTime;
          List<bool> week = [];
          for(int i=0;i<7;i++){
            String day = repeatDay[i];
            if(day=='1') week.add(true);
            else week.add(false);
          }

          columHabit.add(Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  editHabitController.id = id;
                  editHabitController.category = '기타';
                  editHabitController.name = name;
                  editHabitController.emoji = emoji;
                  editHabitController.repeatWeek = repeatDay;
                  editHabitController.repeatTime = repeatTime;
                  editHabitController.startTime = startTime;
                  editHabitController.endTime = endTime;

                  if(editHabitController.repeatTime == '2400') {
                    editHabitController.isAlarmRepeat = false;
                    editHabitController.alarmTime = editHabitController.startTime;
                  } else {
                    editHabitController.isAlarmRepeat = true;
                  }

                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const HabitEditScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(emoji,),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Column(
                              children: [
                                Text(name, style: TextStyle(fontSize: 18)),
                                SizedBox(height: 5,),
                                buildWeekRow(
                                  sun: week[0],
                                  mon: week[1],
                                  tue: week[2],
                                  wed: week[3],
                                  thu: week[4],
                                  fri: week[5],
                                  sat: week[6],
                                  themeColor: themeController.selectedPrimaryColor,),
                              ],
                            );
                          }
                      ),
                      GetBuilder<ThemeController>(
                          builder: (_) {
                            return Text('$tickleCount 달성', style: TextStyle(color: themeController.selectedPrimaryColor),);
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
        }
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('기타', style: TextStyle(fontSize: 25,)),
              ],
            ),
            Column(
              children: columHabit,
            ),
          ],
        );
      } else {
        return Container();
      }
    }

    return GetBuilder<PageChangeController>(
      builder: (_) {
        return Scaffold(
          appBar: CommonAppBar(appBarType: AppBarType.normalAppBar, title: '나의 습관 목록'),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: FutureBuilder(
                future: checkAccessToken(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return Center(
                      child: Image.asset('assets/images/tockles/toc_loading.gif', width: 250, height: 250),
                    );
                  }

                  if(snapshot.hasError) {
                    return Container();
                  }

                  List<HabitRes> checkList = snapshot.data!;

                  return checkList.length != 0 ? Column(
                    children: [
                      buildMoneyHabitsList(snapshot.data!),
                      buildExerciseHabitsList(snapshot.data!),
                      buildStudyHabitsList(snapshot.data!),
                      buildRelationshipHabitsList(snapshot.data!),
                      buildLifeHabitsList(snapshot.data!),
                      buildEtcHabitsList(snapshot.data!),
                      SizedBox(height: deviceHeight * 0.05,),
                    ],
                  ) : Center(child: Text('습관을 등록해주세요!'),);
                }
              ),
            ),
          ),
        );
      }
    );
  }
}

void doNothing(BuildContext context) {
  print('doNothing 호출!!!!!!!');
}