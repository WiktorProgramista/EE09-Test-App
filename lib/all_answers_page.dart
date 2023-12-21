import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;

class AllAnswersPage extends StatefulWidget {
  const AllAnswersPage({super.key});

  @override
  State<AllAnswersPage> createState() => _AllAnswersPageState();
}

class Question {
  final String title;
  final List<String> answers;
  final String answerCorrect;
  final String image;

  Question({
    required this.title,
    required this.answers,
    required this.answerCorrect,
    required this.image,
  });
}

class _AllAnswersPageState extends State<AllAnswersPage> {
  List<Question> questionsList = [];
  bool isDataLoaded = false;

  Future<void> fetchAnswers() async {
    setState(() {
      isDataLoaded = false;
    });
    final response = await http.get(Uri.parse(
        'https://www.praktycznyegzamin.pl/inf03ee09e14/teoria/wszystko/'));

    if (response.statusCode == 200) {
      final document = htmlparser.parse(response.body);
      var questions = document.getElementsByClassName('question');
      for (var i = 0; i < questions.length; i++) {
        var title = questions[i].getElementsByClassName('title')[0].text;
        var answers = questions[i]
            .getElementsByClassName('answer')
            .map((e) => e.text)
            .toList();
        var correctAnswer =
            questions[i].getElementsByClassName('answer  correct')[0].text;
        var image = questions[i].querySelector('.image img')?.attributes['src'];

        questionsList.add(Question(
          title: title,
          answers: answers,
          answerCorrect: correctAnswer,
          image: image ?? '',
        ));
      }
      setState(() {
        isDataLoaded = true;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAnswers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isDataLoaded
            ? ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: questionsList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Text(
                        questionsList[index].title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (questionsList[index].image.isNotEmpty)
                        Image.network(
                          "https://www.praktycznyegzamin.pl/inf03ee09e14/teoria/wszystko/${questionsList[index].image}",
                          fit: BoxFit.cover,
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: questionsList[index].answers.map((answer) {
                          return question(answer, Colors.blue);
                        }).toList(),
                      ),
                      question(
                          questionsList[index].answerCorrect, Colors.green),
                    ],
                  );
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget question(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Container(
        width: double.infinity / 1.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
