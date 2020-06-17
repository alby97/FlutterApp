import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:youni_app/chat.dart';
import 'package:youni_app/chat_svago_screen.dart';
import 'package:youni_app/chat_view_screen.dart';
import 'package:youni_app/chats_screen.dart';
import 'package:youni_app/complete_profile_screen.dart';
import 'package:youni_app/create_new_lesson_change_screen.dart';
import 'package:youni_app/lessons_changes.dart';
import 'package:youni_app/loginScreen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'user_profile_screen.dart';
import 'teaching_materials_screen.dart';
import 'first_screen.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;

//void main() => runApp(MySApp());

void main() {
  runApp(MySApp());
  /*
  CatcherOptions options = new CatcherOptions(SilentReportMode(), [ConsoleHandler(), HttpHandler(HttpRequestType.post, Uri.parse(getUrl()+"sendAppLog"))]);
  CatcherOptions releaseOptions = new CatcherOptions(SilentReportMode(), [HttpHandler(HttpRequestType.post, Uri.parse(getUrl()+"sendAppLog"))]);
  WidgetsFlutterBinding.ensureInitialized();
  Catcher(MySApp(), debugConfig: options, profileConfig: options, releaseConfig: releaseOptions);
  */
}

/*
class MyApp extends StatelessWidget {
  // This widget is the root of your application.

//Si usa questa chiave perché in home_screen quando si clicca sulle card, nel metodo che ho implementato non ho il context, questa chiave permette
//di fare le pushNamed anche senza contesto.

  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  static String lastRoute;
  bool firstOpen = true;

  MyApp()  {
    getProperHomeRoute().then((s) {
      lastRoute = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstScreen(),
      routes: {
        '/teachingMaterial': (context) => TeachingMaterialsScreen(),
        '/homeScreen': (context) => HomeScreen(navigatorKey),
        '/registerScreen': (context) => RegisterScreen(),
        '/completeProfileScreen': (context) => CompleteProfileScreen(),
        '/firstScreen': (context) => FirstScreen(),
        '/userProfileScreen': (context) => UserProfileScreen(),
        '/lessonsChangesScreen': (context) => LessonsChangesScreen(),
        '/loginScreen': (context) => LoginScreen(),
      },
      navigatorKey: navigatorKey,
    );
  }
*/
/*
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstScreen(),
    );
  }

}
*/

class MySApp extends StatefulWidget {
  MySAppState createState() => MySAppState();
}

class MySAppState extends State<MySApp> with WidgetsBindingObserver {
  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  String properInitialRoute;

  bool done = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    /*
    retrieveProperRoute().then((route) {
      print(route);
      setState(() {
        properInitialRoute = route;
        print("Initial: " + properInitialRoute);
        done = true;
      });
    });*/

    properFirstRoute().then((value) {
      print(value);
      setState(() {
       properInitialRoute = value;
       done = true; 
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return done == false
        ? SpinKitPouringHourglass(
          color: Colors.white,
        )
        : MaterialApp(
            //home: FirstScreen(),
          /*  builder: (BuildContext context, Widget widget) {
              Catcher.addDefaultErrorWidget(
                showStacktrace: false,
                customTitle: "C'è stato un errore",
                customDescription: "Si è verificato un errore, ti preghiamo di ricaricare l'applicazione."
              );
              return widget;
            },
            */
            initialRoute: properInitialRoute,
            routes: {
              '/teachingMaterial': (context) => TeachingMaterialsScreen(),
              'homeScreen': (context) => HomeScreen(navigatorKey),
              '/registerScreen': (context) => RegisterScreen(),
              '/completeProfileScreen': (context) => CompleteProfileScreen(),
              'firstScreen': (context) => FirstScreen(),
              '/userProfileScreen': (context) => UserProfileScreen(),
              '/lessonsChangesScreen': (context) => LessonsChangesScreen(),
              '/loginScreen': (context) => LoginScreen(),
              '/chats': (context) => ChatScreen(),
              '/chat': (context) => Chat(),
              '/chatsView': (context) => ChatViewScreen(),
              '/chatSvago': (context) => ChatSvagoScreen(),
              //TODO: '/chatAcademic' : (context) => Chatac
            },
            navigatorKey: navigatorKey,
          );
  }

  Future<String> retrieveProperRoute() async {
    String token =
        await getToken(); //se il token c'è significa che il logout non è stato effettuato
    String routeName;
    if(await getBool('firstAccess') != null){
      if (token != null) {
      http.Response response = await http.get(getUrlHome() + "verLogin",
          headers: {HttpHeaders.authorizationHeader: token});
      if(response.statusCode == 200) {
        routeName = "homeScreen";
      }
      else {
        routeName = "firstScreen";
      }
    }
    else {
      routeName = "firstScreen";
    }
    }
    else {
      routeName = "firstScreen";
    }
    
    return routeName;
  }
}
