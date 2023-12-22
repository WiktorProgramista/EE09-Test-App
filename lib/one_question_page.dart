import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;

class OneQuestionPage extends StatefulWidget {
  const OneQuestionPage({Key? key}) : super(key: key);

  @override
  State<OneQuestionPage> createState() => _OneQuestionPageState();
}

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

  Question({
    required this.title,
    required this.answers,
    required this.answerCorrect,
    required this.image,
  });
}

class _OneQuestionPageState extends State<OneQuestionPage> {
  List<Question> questionsList = [];
  bool isDataLoaded = false;
  Question? currentQuestion;
  bool isButtonClicked = false;

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
          );
        }).toList();

        setState(() {
          isDataLoaded = true;
          currentQuestion = getRandomQuestion();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      Exception('Error fetching data: $e');
    }
  }

  Question getRandomQuestion() {
    Random random = Random();
    int randIndex = random.nextInt(questionsList.length);
    return questionsList[randIndex];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isDataLoaded
            ? Column(
                children: [
                  Expanded(child: renderQuestionContent()),
                  SingleChildScrollView(child: renderAnswerButtons()),
                  SingleChildScrollView(child: nextQuestion()),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget renderQuestionContent() {
    if (currentQuestion == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          currentQuestion!.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        if (currentQuestion!.image.isNotEmpty)
          Image.network(
            Uri.parse(
              'https://www.praktycznyegzamin.pl/inf03ee09e14/teoria/wszystko/${currentQuestion!.image}',
            ).toString(),
            fit: BoxFit.cover,
          ),
      ],
    );
  }

  Widget renderAnswerButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: currentQuestion!.answers.map((answer) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                handleAnswerButtonClick(answer);
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

  Widget nextQuestion() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          loadNextQuestion();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
        child: const Padding(
          padding: EdgeInsets.all(5.0),
          child:
              Text("Następne pytanie", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void handleAnswerButtonClick(Answer answer) {
    if (!isButtonClicked) {
      setState(() {
        if (currentQuestion!.answerCorrect == answer.text) {
          answer.btnColor = Colors.green;
        } else {
          answer.btnColor = Colors.red;
          currentQuestion!.answers
              .firstWhere((a) => a.text == currentQuestion!.answerCorrect)
              .btnColor = Colors.green;
        }
        isButtonClicked = true;
      });
    }
  }

  void loadNextQuestion() {
    setState(() {
      currentQuestion = getRandomQuestion();
      isButtonClicked = false;
    });
  }
}
