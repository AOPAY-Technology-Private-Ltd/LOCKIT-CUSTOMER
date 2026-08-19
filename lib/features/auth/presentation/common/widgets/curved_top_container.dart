import 'package:flutter/material.dart';


class CurvedTopContainer extends StatelessWidget {


  final Widget child;

  final Color color;

  final double curveHeight;



  const CurvedTopContainer({

    super.key,

    required this.child,

    this.color = const Color(0xffE8EFFF),

    this.curveHeight = 0.42,

  });



  @override
  Widget build(BuildContext context) {


    return ClipPath(

      clipper: CurvedTopClipper(

        curveHeight: curveHeight,

      ),


      child: Container(

        width: double.infinity,

        color: color,

        child: child,

      ),

    );

  }

}





class CurvedTopClipper extends CustomClipper<Path> {


  final double curveHeight;



  CurvedTopClipper({

    required this.curveHeight,

  });



  @override
  Path getClip(Size size) {


    final path = Path();



    path.moveTo(

      0,

      size.height * curveHeight,

    );



    path.quadraticBezierTo(

      size.width * 0.5,

      -size.height * 0.28,

      size.width,

      size.height * curveHeight,

    );



    path.lineTo(

      size.width,

      size.height,

    );


    path.lineTo(

      0,

      size.height,

    );


    path.close();



    return path;

  }



  @override
  bool shouldReclip(

      covariant CurvedTopClipper oldClipper

      ) {


    return oldClipper.curveHeight != curveHeight;

  }


}