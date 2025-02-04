import 'package:doctor_app/login_page.dart';
import 'package:flutter/material.dart';

class LoginType extends StatefulWidget {
  const LoginType({super.key});

  @override
  State<LoginType> createState() => _LoginTypeState();
}

class _LoginTypeState extends State<LoginType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                // child: Text(
                //   "Home Admin",
                //   style: AppWeiget.HeadlineText(),
                // ),
                ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Material(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Text(
                          "Login page",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "bold",
                              fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Material(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          // child: Image.asset(
                          //   "images/food.jpg",
                          //   height: 100,
                          //   width: 100,
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Text(
                          "Go to homepage",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "bold",
                              fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
