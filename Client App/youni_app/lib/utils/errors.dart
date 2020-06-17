import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:youni_app/utils/utility.dart';

void checkResponseStatus(Response response, BuildContext context) {
    if(response.statusCode == 403) {
      logout(context);
    }
}



