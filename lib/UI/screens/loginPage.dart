import 'dart:async';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ynotes/UI/screens/schoolAPIChoicePage.dart';
import 'package:ynotes/UI/animations/FadeAnimation.dart';
import 'package:ynotes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ynotes/UI/screens/gradesPage.dart';
import 'package:ynotes/parsers/EcoleDirecte.dart';
import 'package:ynotes/usefulMethods.dart';
import 'package:connectivity/connectivity.dart';
import '../../apiManager.dart';

Color textButtonColor = Color(0xff252B62);

class LoginPage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

class _LoginPageState extends State<LoginPage> {
  String casValue = "Aucun";
  Future<String> connectionData;
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _url = TextEditingController();
  final _cas = TextEditingController();
  bool _isFirstUse = true;
  String _obligationText = "";
  StreamSubscription loginconnexion;

  bool isOffline = false;

  @override
  initState() {
    super.initState();

    tryToConnect();

    getFirstUse();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    loginconnexion = connectionStatus.connectionChange.listen(connectionChanged);
    isOffline = !connectionStatus.hasConnection;
  }

  void connectionChanged(dynamic hasConnection) {
    print("connected");
    setState(() {
      isOffline = !hasConnection;
    });
    tryToConnect();
  }

  getFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('firstUse') == true && storage.read(key: 'agreedTermsAndConfiguredApp') == null) {
      _isFirstUse = true;
    }
  }

  tryToConnect() async {

    await getChosenParser();
    
    String u = await ReadStorage("username");
    String p = await ReadStorage("password");
    String url = await ReadStorage("pronoteurl");
    String cas = await ReadStorage("pronotecas");
    String z = await storage.read(key: "agreedTermsAndConfiguredApp");
  
    if (u != null && p != null && z != null) {
      connectionData =  localApi.login(u, p, url: url, cas: cas);
      openLoadingDialog();
    }
  }

  openAlertBox() {
    MediaQueryData screenSize;
    screenSize = MediaQuery.of(context);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: SingleChildScrollView(
              child: Container(
                width: screenSize.size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Conditions d’utilisation",
                          style: TextStyle(fontSize: 24.0, fontFamily: "Asap"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10),
                        child: SingleChildScrollView(
                            child: Container(
                          child: Text(
                            "En utilisant cette application ainsi que les services tiers vous acceptez et comprenez les conditions suivantes :\n- Mon identifiant ainsi que mon mot de passe ne sont pas enregistrés sur des serveurs, seulement sur votre appareil. Mais vous vous portez responsables en cas de perte de ces derniers.\n - YNote ne se porte pas responsable en cas de suppression ou altération de la qualité de votre compte EcoleDirecte par une entité externe.\n - YNote est un client libre et gratuit et non officiel\n - YNote n’est en aucun cas affilié ou relié à une quelconque entité\n - EcoleDirecte est un produit de la société STATIM",
                            style: TextStyle(
                              fontFamily: "Asap",
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ))),
                    RaisedButton(
                      padding: EdgeInsets.only(left: 60, right: 60, top: 15, bottom: 18),
                      color: Color(0xff27AE60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32.0), bottomRight: Radius.circular(32.0)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(router(carousel()));
                      },
                      child: Text(
                        "J'accepte",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  openLoadingDialog() {
    MediaQueryData screenSize;
    screenSize = MediaQuery.of(context);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 20),
                child: Column(
                  children: <Widget>[
                    FutureBuilder(
                      future: connectionData,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data.toString().contains("Bienvenue")) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.pop(context);
                            if (_isFirstUse == true) {
                              openAlertBox();
                            } else {
                              Navigator.of(context).pushReplacement(router(homePage()));
                            }
                          });
                          return Column(
                            children: <Widget>[
                              Icon(
                                Icons.check_circle,
                                size: MediaQuery.of(context).size.width / 5,
                                color: Colors.lightGreen,
                              ),
                              Text(
                                snapshot.data,
                                textAlign: TextAlign.center,
                              )
                            ],
                          );
                        } else if (snapshot.hasData && !snapshot.data.toString().contains("Bienvenue")) {
                          return Column(
                            children: <Widget>[
                              Icon(
                                Icons.error,
                                size: MediaQuery.of(context).size.width / 5,
                                color: Colors.redAccent,
                              ),
                              Text(
                                snapshot.data.toString(),
                                textAlign: TextAlign.center,
                              )
                            ],
                          );
                        } else {
                          return Container(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                backgroundColor: Color(0xff444A83),
                              ));
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    MediaQueryData screenSize;
    screenSize = MediaQuery.of(context);

//BEGINNING OF THE STYLE OF THE WINDOW
    return WillPopScope(
      onWillPop: () async {
        Future.value(false);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          color: Color(0xFF252B62),
          child: SafeArea(
              child: Container(
                    height: screenSize.size.height - screenSize.padding.top - screenSize.padding.bottom,
                    decoration: BoxDecoration(color: Color(0xFF252B62)),
                    child: SingleChildScrollView(
                      child: Container(
                          height: screenSize.size.height - screenSize.padding.top - screenSize.padding.bottom,
                          width: screenSize.size.width,
                          child: Stack(
                            //Random icons
                            children: <Widget>[
              Positioned(
                right: screenSize.size.width / 5 * 0.4,
                bottom: screenSize.size.height / 10 * 5 + screenSize.size.width / 5 * 0.6,
                child: Transform.rotate(
                    angle: -0.2,
                    child: FadeAnimation(
                        0.7,
                        Icon(
                          MdiIcons.emoticonHappyOutline,
                          size: screenSize.size.width / 5 * 0.8,
                          color: Colors.white.withOpacity(0.2),
                        ))),
              ),
              Positioned(
                left: screenSize.size.width / 5 * 2,
                bottom: screenSize.size.height / 10 * 0.4,
                child: Transform.rotate(
                    angle: 0.3,
                    child: FadeAnimation(
                        0.71,
                        Icon(
                          MdiIcons.bookshelf,
                          size: screenSize.size.width / 5 * 0.8,
                          color: Colors.white.withOpacity(0.2),
                        ))),
              ),
              Positioned(
                left: -screenSize.size.width / 5 * 0.2,
                bottom: screenSize.size.height / 10 * 0.9,
                child: Transform.rotate(
                    angle: -0.1,
                    child: FadeAnimation(
                        0.72,
                        Icon(
                          MdiIcons.information,
                          size: screenSize.size.width / 5 * 1,
                          color: Colors.white.withOpacity(0.2),
                        ))),
              ),
              Positioned(
                left: screenSize.size.width / 5 * 1.5,
                top: screenSize.size.height / 10 * 1.2,
                child: Transform.rotate(
                    angle: 0.2,
                    child: FadeAnimation(
                        0.73,
                        Icon(
                          MdiIcons.starCircle,
                          size: screenSize.size.width / 5 * 0.95,
                          color: Colors.white.withOpacity(0.2),
                        ))),
              ),
              Positioned(
                right: screenSize.size.width / 5 * -0.1,
                bottom: screenSize.size.height / 10 * 0.5,
                child: Transform.rotate(
                    angle: -0.4,
                    child: FadeAnimation(
                        0.74,
                        Icon(
                          MdiIcons.schoolOutline,
                          size: screenSize.size.width / 5 * 1.2,
                          color: Colors.white.withOpacity(0.2),
                        ))),
              ),
              Positioned(
                left: screenSize.size.width / 5 * 0.1,
                top: screenSize.size.height / 10 * 0.1,
                child: Transform.rotate(
                    angle: 0,
                    child: FadeAnimation(
                        0.75,
                        Icon(
                          MdiIcons.pencil,
                          size: screenSize.size.width / 5 * 0.7,
                          color: Colors.white.withOpacity(0.2),
                        ))),
              ),
              Positioned(
                right: screenSize.size.width / 5 * 0.25,
                top: screenSize.size.height / 10 * 0.15,
                child: Transform.rotate(
                    angle: 0,
                    child: Image(
                      image: AssetImage('assets/images/LogoYNotes.png'),
                      width: screenSize.size.width / 5 * 0.7,
                    )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FadeAnimation(
                  0.8,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Material(
                        color: chosenParser == 0 ? Color(0xff2874A6) : Color(0xff4BA55D),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25)),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(router(SchoolAPIChoice()));
                          },
                          borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25)),
                          child: Container(
                            width: screenSize.size.width / 5 * 4,
                            height: screenSize.size.height / 10 * 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width / 10 * 0.1),
                                  margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 10 * 0.2),
                                  child: Image(
                                      width: MediaQuery.of(context).size.width / 5 * 0.5,
                                      height: screenSize.size.width / 5 * 0.5,
                                      fit: BoxFit.fitWidth,
                                      image: AssetImage('assets/images/${chosenParser == 0 ? "EcoleDirecte" : "Pronote"}/${chosenParser == 0 ? "EcoleDirecte" : "Pronote"}Icon.png')),
                                ),
                                Container(
                                    width: screenSize.size.width / 5 * 3,
                                    child: FittedBox(child: Text("Connexion avec ${chosenParser == 0 ? "EcoleDirecte" : "Pronote"}", textAlign: TextAlign.center, style: TextStyle(fontFamily: "Asap", color: Colors.white)))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                                              child: Container(
                          margin: EdgeInsets.only(top: screenSize.size.height / 10 * 0.2),
                          width: screenSize.size.width / 5 * 4,
                          padding: EdgeInsets.symmetric(vertical: screenSize.size.width / 5 * 0.2),
                          decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25)), color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: screenSize.size.height / 10 * 0.9,
                                child: FittedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          "Bienvenue sur yNotes",
                                          style: TextStyle(fontFamily: 'Asap', fontWeight: FontWeight.bold, color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        width: screenSize.size.width / 5 * 3,
                                        child: Text(
                                          "Connectez vous à votre espace scolaire",
                                          style: TextStyle(fontFamily: 'Asap', color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: screenSize.size.height / 10 * 0.3,
                                  left: screenSize.size.height / 10 * 0.4,
                                  bottom: screenSize.size.height / 10 * 0.1,
                                ),
                         
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        "Identifiant",
                                        style: TextStyle(fontFamily: 'Asap', color: Colors.black),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Text(_obligationText, style: TextStyle(color: Colors.red))
                                  ],
                                ),
                              ),
                              Container(
                                width: screenSize.size.width / 5 * 3.2,
                                margin: EdgeInsets.only(
                                  left: screenSize.size.height / 10 * 0.1,
                                ),
                                height: screenSize.size.height / 10 * 0.4,
                                child: TextFormField(
                                  controller: _username,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: screenSize.size.height / 10 * 0.3,
                                  left: screenSize.size.height / 10 * 0.4,
                                  bottom: screenSize.size.height / 10 * 0.1,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Mot de passe",
                                      style: TextStyle(fontFamily: 'Asap', color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenSize.size.width / 5 * 3.2,
                                margin: EdgeInsets.only(
                                  left: screenSize.size.height / 10 * 0.1,
                                ),
                                height: screenSize.size.height / 10 * 0.4,
                                child: TextFormField(
                                  controller: _password,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              if (chosenParser == 1)
                                Container(
                                  margin: EdgeInsets.only(
                                    top: screenSize.size.height / 10 * 0.3,
                                    left: screenSize.size.height / 10 * 0.4,
                                    bottom: screenSize.size.height / 10 * 0.1,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          "Adresse Pronote",
                                          style: TextStyle(fontFamily: 'Asap', color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(_obligationText, style: TextStyle(color: Colors.red))
                                    ],
                                  ),
                                ),
                              if (chosenParser == 1)
                                Container(
                                  width: screenSize.size.width / 5 * 3.2,
                                  margin: EdgeInsets.only(
                                    left: screenSize.size.height / 10 * 0.1,
                                  ),
                                  height: screenSize.size.height / 10 * 0.8,
                                  child: TextFormField(
                                    controller: _url,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              if (chosenParser == 1)
                                Container(
                                  margin: EdgeInsets.only(
                                    top: screenSize.size.height / 10 * 0.3,
                                    left: screenSize.size.height / 10 * 0.4,
                                    bottom: screenSize.size.height / 10 * 0.1,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "ENT",
                                        style: TextStyle(fontFamily: 'Asap', color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              if (chosenParser == 1)
                                Container(
                                    width: screenSize.size.width / 5 * 3.2,
                                    margin: EdgeInsets.only(
                                      left: screenSize.size.height / 10 * 0.1,
                                    ),
                                    
                                    child: DropdownButton<String>(
                                      value: casValue,
                                      style: TextStyle(color: Colors.black),
                                      icon: null,
                                      iconSize: 0,
                                      underline: Container(
                                        height: screenSize.size.height / 10 * 0.02,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          casValue = newValue;
                                        });
                                      },
                                      items: <String>['Aucun', 'Atrium Sud'].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(fontFamily: 'Asap', color: Colors.black),
                                          ),
                                        );
                                      }).toList(),
                                    )),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                    width: screenSize.size.width / 5 * 4,
                                    height: screenSize.size.height / 10 * 0.55,
                                    margin: EdgeInsets.only(top: screenSize.size.height / 10 * 0.55, right: screenSize.size.width / 5 * 0.25),
                                    child: GestureDetector(
                                      onTapDown: (details) {
                                        setState(() {
                                          textButtonColor = Colors.white;
                                        });
                                      },
                                      onTapCancel: () {
                                        setState(() {
                                          textButtonColor = Color(0xff252B62);
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          if (isOffline)
                                            Row(
                                              children: <Widget>[
                                                Text("Vous êtes hors ligne", style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          SizedBox(
                                            width: screenSize.size.width / 5 * 0.2,
                                          ),
                                          OutlineButton(
                                            color: Color(0xff252B62),
                                            highlightColor: Color(0xff252B62),
                                            focusColor: Color(0xff252B62),
                                            borderSide: BorderSide(color: Color(0xff252B62)),
                                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                            highlightedBorderColor: Color(0xff252B62),
                                            onPressed: () async {
                                              await getChosenParser();
                                            

                                              //Actions when pressing the ok button
                                              if (_username.text != "" && (chosenParser == 1 ? _url.text != null : true) && _password.text != null) {
                                                //Login using the chosen API
                                                connectionData = localApi.login(_username.text.trim(), _password.text.trim(), url: _url.text.trim(), cas: casValue);

                                                openLoadingDialog();
                                              } else {
                                                setState(() {
                                                  _obligationText = " (obligatoire)";
                                                });
                                              }
                                            },
                                            child: Text(
                                              "Allons-y",
                                              style: TextStyle(fontFamily: "Asap", fontSize: screenSize.size.width / 5 * 0.3, fontWeight: FontWeight.bold, color: textButtonColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                            ],
                          )),
                    ))),
        ),
      ),
    );
  }
}

