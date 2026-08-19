import 'package:flutter/material.dart';


class AuthFooter extends StatelessWidget {


  final VoidCallback? onTap;



  const AuthFooter({

    super.key,

    this.onTap,

  });





  @override
  Widget build(BuildContext context) {


    final theme = Theme.of(context);



    return GestureDetector(


      onTap: onTap,


      child: Text.rich(


        TextSpan(

          children: [


            TextSpan(

              text: '@ Aopay Technology Pvt. Ltd.',

              style: theme.textTheme.bodySmall?.copyWith(

                color: Colors.black,

                fontSize: 12,

                fontWeight: FontWeight.w400,

              ),

            ),


          ],

        ),


        textAlign: TextAlign.center,


      ),


    );


  }


}