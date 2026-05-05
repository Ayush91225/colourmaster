import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/style/color_constants.dart';

Widget loadingIndicator(){
  return  SizedBox(height:40,width:40,child:CupertinoActivityIndicator(color:ColorConstants.blackColor,radius:25.0,));
}