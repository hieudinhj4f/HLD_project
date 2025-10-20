import 'package:flutter/material.dart';
import 'package:hld_project/feature/Home/presentation/pages/home_page.dart';


class SplashScreen extends StatefulWidget{
  const SplashScreen({
    super.key,
});
  @override
  State<SplashScreen> createState() => _SplashScreenState();

}
class _SplashScreenState extends State<SplashScreen>{
  @override
    void initState(){
    super.initState();

    Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'H',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    TextSpan(
                        text: 'L',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    TextSpan(
                        text: 'D',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                  ]
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Healthy Life Diagnosis",
                style:  TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "HealthyCare Product",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            ]
          ,
        ),
      ),
    );
  }
}