import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;

class Answer {
  Color btnColor;
  bool isSelected;
  final String text;

  Answer(this.btnColor, this.isSelected, this.text);
}

class Question {
  final String title;
  final List<Answer> answers;
  final String answerCorrect;
  final String image;
  String selectedAnswer;

  Question({
    required this.title,
    required this.answers,
    required this.answerCorrect,
    required this.image,
    required this.selectedAnswer,
  });
}

class MultiQuestionPage extends StatefulWidget {
  const MultiQuestionPage({Key? key}) : super(key: key);

  @override
  State<MultiQuestionPage> createState() => _MultiQuestionPageState();
}

class _MultiQuestionPageState extends State<MultiQuestionPage> {
  List<Question> questionsList = [];
  bool isDataLoaded = false;
  List<Question> currentQuestions = [];
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    fetchAnswers();
  }

  Future<void> fetchAnswers() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.praktycznyegzamin.pl/inf03ee09e14/teoria/wszystko/'));

      if (response.statusCode == 200) {
        final document = htmlparser.parse(response.body);
        var questions = document.getElementsByClassName('question');

        questionsList = questions.map((question) {
          var title = question.getElementsByClassName('title')[0].text;
          var answers = question
              .getElementsByClassName('answer')
              .map((e) => e.text)
              .toList();
          var correctAnswer =
              question.getElementsByClassName('answer  correct')[0].text;
          var image = question.querySelector('.image img')?.attributes['src'];

          List<Answer> answersList =
              answers.map((e) => Answer(Colors.blue, false, e)).toList();

          return Question(
            title: title,
            answers: answersList,
            answerCorrect: correctAnswer,
            image: image ?? '',
            selectedAnswer: '',
          );
        }).toList();

        setState(() {
          isDataLoaded = true;
          currentQuestions = getRandomQuestions();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      Exception('Error fetching data: $e');
    }
  }

  List<Question> getRandomQuestions() {
    List<int> indices =
        List<int>.generate(questionsList.length, (index) => index);
    indices.shuffle();

    List<Question> selectedQuestions = [];
    for (int i = 0; i < min(40, questionsList.length); i++) {
      selectedQuestions.add(questionsList[indices[i]]);
    }

    return selectedQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isDataLoaded
          ? ListView.builder(
              itemCount: currentQuestions.length + 1,
              itemBuilder: (context, index) {
                if (index < currentQuestions.length) {
                  var question = currentQuestions[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      renderQuestionContent(question),
                      renderAnswerButtons(question),
                    ],
                  );
                } else {
                  return renderCustomButton();
                }
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget renderQuestionContent(Question question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          question.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        if (question.image.isNotEmpty)
          Image.network(
            Uri.parse(
                    "https://www.praktycznyegzamin.pl/inf03ee09e14/teoria/wszystko/${question.image}")
                .toString(),
            fit: BoxFit.cover,
          ),
      ],
    );
  }

  Widget renderAnswerButtons(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.answers.map((answer) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                handleAnswerButtonClick(question, answer);
              },
              style: ElevatedButton.styleFrom(backgroundColor: answer.btnColor),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(answer.text,
                    style: const TextStyle(color: Colors.black)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget renderCustomButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            for (var i = 0; i < currentQuestions.length; i++) {
              if (currentQuestions[i].selectedAnswer ==
                  currentQuestions[i].answerCorrect) {
                totalScore++;
                currentQuestions[i]
                    .answers
                    .firstWhere(
                        (e) => e.text == currentQuestions[i].answerCorrect)
                    .btnColor = Colors.green;
              } else {
                for (var element in currentQuestions[i].answers) {
                  if (element.text == currentQuestions[i].selectedAnswer) {
                    element.btnColor = Colors.red;
                  }
                  currentQuestions[i]
                      .answers
                      .firstWhere(
                          (e) => e.text == currentQuestions[i].answerCorrect)
                      .btnColor = Colors.green;
                }
              }
            }
          });
          showResultAlertDialog(context, totalScore);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
        child: const Padding(
          padding: EdgeInsets.all(3.0),
          child:
              Text('Sprawdź odpowiedzi', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void showResultAlertDialog(BuildContext context, int score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Twój wynik to: $score', style: const TextStyle(fontSize: 20)),
          ],
        ));
      },
    );
  }

  void handleAnswerButtonClick(Question question, Answer answer) {
    setState(() {
      var questionIndex =
          currentQuestions.indexWhere((e) => e.title == question.title);
      currentQuestions[questionIndex].selectedAnswer = answer.text;
      question.answers.firstWhere((e) => e.text == answer.text).btnColor =
          Colors.orange;
      for (var e in question.answers) {
        if (e.text != answer.text) {
          e.btnColor = Colors.blue;
        }
      }
    });
  }
}
