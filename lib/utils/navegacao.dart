import 'package:flutter/material.dart';

class NavegacaoCUSTOM {
  static void push(BuildContext context, Widget pagina) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => pagina));
  }

  static void pushReplacement(BuildContext context, Widget pagina) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => pagina));
  }
}
