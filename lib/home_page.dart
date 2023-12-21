import 'package:ee09/multi_question_page.dart';
import 'package:ee09/one_question_page.dart';
import 'package:flutter/material.dart';
import 'package:ee09/all_answers_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton(
                'Pokaż wszystkie odpowiedzi', const AllAnswersPage(), context),
            customButton('Jedno pytanie', const OneQuestionPage(), context),
            customButton('Test 40 pytań', const MultiQuestionPage(), context),
          ],
        ),
      ),
    );
  }
}

Widget customButton(String text, Widget page, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        width: double.infinity,
        height: 70.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.blue.shade800,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
