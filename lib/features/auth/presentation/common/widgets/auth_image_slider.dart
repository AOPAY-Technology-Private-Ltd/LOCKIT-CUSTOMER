import 'dart:async';

import 'package:flutter/material.dart';


class AuthImageSlider extends StatefulWidget {

  final double size;


  const AuthImageSlider({

    super.key,

    this.size = 300,

  });


  @override
  State<AuthImageSlider> createState() =>
      _AuthImageSliderState();

}



class _AuthImageSliderState extends State<AuthImageSlider> {


  final PageController controller =
  PageController();


  Timer? timer;


  int currentPage = 0;



  final List<String> images = [

    "assets/images/slider1.png",

    "assets/images/slider2.png",

    "assets/images/slider3.png",

    "assets/images/slider4.png",

  ];



  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      timer = Timer.periodic(

        const Duration(milliseconds:1500),

            (_) {

          if(controller.hasClients){

            currentPage++;


            if(currentPage >= images.length){

              currentPage = 0;

            }


            controller.jumpToPage(
                currentPage
            );

          }


        },

      );


    });

  }




  @override
  void dispose(){

    timer?.cancel();

    controller.dispose();

    super.dispose();

  }





  @override
  Widget build(BuildContext context) {


    return SizedBox(

      width: widget.size,

      height: widget.size,


      child: PageView.builder(

        controller: controller,

        physics:
        const NeverScrollableScrollPhysics(),


        itemCount: images.length,


        itemBuilder:(context,index){


          return Image.asset(

            images[index],

            fit: BoxFit.contain,

            cacheWidth:
            (widget.size * 2).toInt(),

          );


        },

      ),

    );

  }

}