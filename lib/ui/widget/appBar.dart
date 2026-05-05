import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/global_key.dart';
import '../../utils/style/color_constants.dart';
import '../../utils/style/text_view_style.dart';
import '../../utils/utilsMethods.dart';
import '../component/textView.dart';

PreferredSizeWidget appBarView(BuildContext context,var title,var showBackArrow, bool? enableNotificationClick){
  return  AppBar(automaticallyImplyLeading: false,backgroundColor:ColorConstants.whiteColor,
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    leading:showBackArrow?IconButton(
      icon: Image.asset('assets/images/backarrow.png',
        height: 30,width: 30,
      ),
      onPressed:(){
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          SystemNavigator.pop();
        }
      },
    ):const SizedBox(),
    actions: [
      Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible:loginStatus,child:GestureDetector(child: Container(margin:const EdgeInsets.only(right:10),padding:const EdgeInsets.all(7),decoration:BoxDecoration(
        border: Border.all(color: ColorConstants.dividerColor,width: 0.5),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),child: SvgPicture.asset(
        height:25,width:25,
        'assets/svg/bell_icon.svg',
      ),),
        onTap: (){
        },))
    ],
    title:Center(child:TextView(data:title,fontSize:textLabelFontSize_24,fontFamily:'Poppins',
      fontWeight:FontWeight.w400, textColor: ColorConstants.blackColor,textAlign:TextAlign.center,)),
  );
}