import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tickle_tackle_tockle/component/common_appbar.dart';
import 'package:tickle_tackle_tockle/controller/loading_controller.dart';
import 'package:tickle_tackle_tockle/screen/mypage/privacy_screen.dart';
import 'package:tickle_tackle_tockle/screen/mypage/tos_screen.dart';
import '../../const/serveraddress.dart';
import '../../const/theme.dart';
import 'menual_screen.dart';
import 'package:flutter/services.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final deviceWidth = size.width;
    final deviceHeight = size.height;
    final menuFontSize = deviceHeight * 0.023;

    LoadingController loadingController = Get.put(LoadingController());

    Future<http.Response> sendAccessToken(String strUrl, bool check) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String accessToken = pref.getString('accessToken')!;
      var url = Uri.parse('${ServerUrl}${strUrl}');
      if(check) {
        var response = await http.get(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'accesstoken': accessToken,
          },
        );
        return response;
      }else{
        var response = await http.patch(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'accesstoken': accessToken,
          },
        );
        return response;
      }
    }
    Future<void> checkAccessToken(String strUrl,bool check) async {
      final response = await sendAccessToken(strUrl, check);
      if (response.statusCode == 200) {
        print('api 요청 성공');
      } else {
        print('YN failed with status: ${response.statusCode}');
      }
    }


    Future<void> signOutGoogle() async {
      await FirebaseAuth.instance.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.disconnect();
      //우리 서버 로그아웃
      String url = '/tttlogout';
      bool check = true;
      await checkAccessToken(url,check);
    }
    Future<void> deleteAccount() async {
      FirebaseAuth auth = FirebaseAuth.instance;
      User user = auth.currentUser!;
      if(user != null) {
        await user.delete().then((value) async {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          await googleSignIn.disconnect();
        });
      }
      String url = '/user/quit';
      bool check = false;
      await checkAccessToken(url,check);
    }


    return SafeArea(
      child: Scaffold(
        appBar: CommonAppBar(appBarType: AppBarType.normalAppBar, title: '설정'),
        body: Padding(
          padding: EdgeInsets.fromLTRB(deviceWidth * 0.05, deviceHeight * 0.02, deviceWidth * 0.05, 0),
          child: Container(
            height: deviceHeight * 0.3,
            width: deviceWidth * 0.9,
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
            child: Padding(
              padding: EdgeInsets.all(deviceHeight * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const PrivacyScreen(),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '개인 정보 처리 방침',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: menuFontSize
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const TosScreen(),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '이용 약관',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: menuFontSize
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      loadingController.setIsLoadingFlag(true);
                      signOutGoogle().then((value) {
                        loadingController.setIsLoadingFlag(false);
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '로그아웃',
                          style: TextStyle(
                              color: TTTPrimary1,
                              fontSize: menuFontSize
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Dialogs.materialDialog(
                        msg: '가지마세요 ㅠㅠ \n저장된 데이터 모두 날려버릴거에요',
                        title: '회원탈퇴',
                        titleStyle: const TextStyle(
                          color: Colors.red,
                        ),
                        color: Colors.white,
                        context: context,
                        actions: [
                          IconsOutlineButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: '취소',
                            textStyle: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          IconsButton(
                            onPressed: () {
                              deleteAccount().then((value) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              });

                            },
                            text: '탈퇴하기',
                            color: Colors.red,
                            textStyle: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '회원탈퇴',
                          style: TextStyle(
                              color: TTTPrimary1,
                              fontSize: menuFontSize
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}