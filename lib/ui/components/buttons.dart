import 'package:flutter/material.dart';
import 'package:ynotes/core/utils/themeUtils.dart';

class CustomButtons {
  Widget materialButton(BuildContext context, double width, double height, Function onTap,
      {IconData icon, String label, Color backgroundColor}) {
    var screenSize = MediaQuery.of(context);
    return Container(
      width: width,
      margin: EdgeInsets.only(left: (screenSize.size.height / 10 * 8.8) / 10 * 0.1),
      child: Material(
        color: backgroundColor ?? Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(screenSize.size.width / 5 * 0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(screenSize.size.width / 5 * 0.15),
          onTap: onTap,
          child: Container(
              height: height,
              padding: EdgeInsets.all(screenSize.size.width / 5 * 0.1),
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (icon != null)
                      Icon(
                        icon,
                        color: ThemeUtils.textColor(),
                      ),
                    if (label != null)
                      Text(
                        label ?? "",
                        style: TextStyle(
                          fontFamily: "Asap",
                          color: ThemeUtils.textColor(),
                        ),
                      ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
