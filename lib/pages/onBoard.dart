import 'package:flutter/material.dart';
import 'package:quickbite/pages/index.dart';
import 'package:quickbite/widget/content_medel.dart';
import 'package:quickbite/widget/widget_support.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05; // 5%
    final topPadding = size.height * 0.05; // 5%
    final imageHeight = size.height * 0.4; // 40%

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        contents[i].image,
                        height: imageHeight,
                        width: size.width,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: size.height * 0.03),
                      Text(
                        contents[i].title,
                        textAlign: TextAlign.center,
                        style:
                            AppWidget.semiBoldTextFieldStyle(context).copyWith(
                          fontSize: size.width * 0.06, // 6% of width
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        contents[i].description,
                        textAlign: TextAlign.center,
                        style: AppWidget.LigthTextFieldStyle(context).copyWith(
                          fontSize: size.width * 0.045, // 4.5% of width
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length,
              (index) => buildDot(index),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (currentIndex == contents.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              } else {
                _controller.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: size.height * 0.07,
              // 7% of height
              margin: EdgeInsets.all(size.width * 0.08),
              width: double.infinity,
              child: Center(
                child: Text(
                  currentIndex == contents.length - 1 ? "Start" : "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.05, // 5% of width
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 10.0,
      width: currentIndex == index ? 20 : 8,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: currentIndex == index ? Colors.red : Colors.black38,
      ),
    );
  }
}
