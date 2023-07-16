import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluro/fluro.dart';

class NoPageFoundHandlers {
  static Handler noPageFound =
      Handler(handlerFunc: (BuildContext? context, params) {
    context?.read<PagesProvider>().setCurrentPageUrl('/404');

    return Container();
  });
}
