import 'package:flutter/material.dart';

Future<bool?> showAlertDialog(BuildContext context,
    {required String message, required String title}) async {
  Widget cancelButton = TextButton(
    child: const Text(
      "Cancelar",
      style: TextStyle(color: Colors.red),
    ),
    onPressed: () {
      Navigator.pop(context, false);
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Continuar"),
    onPressed: () {
      Navigator.pop(context, true);
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
