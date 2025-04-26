import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(InterviewCoachApp());
}

class InterviewCoachApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview Coach',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: CompanySelectionScreen(),
    );
  }
}

String get baseUrl {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return 'http://localhost:5000';
  } else {
    return 'http://10.0.2.2:5000';
  }
}

class CompanySelectionScreen extends StatelessWidget {
  final List<Map<String, String>> companies = [
    {'name': 'Google', 'logo': 'assets/google.png'},
    {'name': 'Amazon', 'logo': 'assets/amazon.png'},
    {'name': 'Meta', 'logo': 'assets/meta.png'},
    {'name': 'Netflix', 'logo': 'assets/netflix.png'},
    {'name': 'Apple', 'logo': 'assets/apple.png'},
    {'name': 'Microsoft', 'logo': 'assets/microsoft.png'},
    {'name': 'Tesla', 'logo': 'assets/tesla.png'},
    {'name': 'NVIDIA', 'logo': 'assets/nvidia.png'},
    {'name': 'Oracle', 'logo': 'assets/oracle.png'},
    {'name': 'Adobe', 'logo': 'assets/adobe.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select a Company")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: GridView.builder(
            itemCount: companies.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategorySelectionScreen(
                          company: companies[index]['name']!),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        companies[index]['logo']!,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 8),
                      Text(
                        companies[index]['name']!,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CategorySelectionScreen extends StatelessWidget {
  final String company;
  CategorySelectionScreen({required this.company});

  void navigateToChat(BuildContext context, String category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_question'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company': company,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final initialQuestion = data['question'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            company: company,
            category: category,
            initialQuestion: initialQuestion,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Interview Type")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            CategoryCard(
              title: 'Behavioral',
              image: 'assets/behavioral.png',
              onTap: () => navigateToChat(context, 'Behavioral'),
            ),
            CategoryCard(
              title: 'Technical',
              image: 'assets/technical.png',
              onTap: () => navigateToChat(context, 'Technical'),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const CategoryCard(
      {required this.title, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 60),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String company;
  final String category;
  final String initialQuestion;
  ChatScreen(
      {required this.company,
      required this.category,
      required this.initialQuestion});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> chatLog = [];
  final TextEditingController inputController = TextEditingController();
  bool isSubmittingAnswer = true;
  bool interviewEnded = false;

  @override
  void initState() {
    super.initState();
    chatLog.add({'role': 'ai', 'text': widget.initialQuestion});
  }

  void sendMessage() async {
    final input = inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      chatLog.add({'role': 'user', 'text': input});
      inputController.clear();
    });

    final uri = isSubmittingAnswer ? '/submit_answer' : '/ask_interviewer';

    final response = await http.post(
      Uri.parse('$baseUrl$uri'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company': widget.company,
        'category': widget.category,
        'log': chatLog,
        'input': input,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        chatLog.add({'role': 'ai', 'text': data['reply']});
      });
    }
  }

  void endInterview() async {
    final response = await http.post(
      Uri.parse('$baseUrl/end_interview'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company': widget.company,
        'category': widget.category,
        'log': chatLog,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        chatLog.add({'role': 'ai', 'text': data['summary']});
        interviewEnded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.company} Interview'),
        actions: [
          if (!interviewEnded)
            IconButton(
              icon: Icon(Icons.flag),
              tooltip: 'End Interview',
              onPressed: endInterview,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: chatLog.length,
              itemBuilder: (context, index) {
                final message = chatLog[index];
                return Align(
                  alignment: message['role'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message['role'] == 'user'
                          ? Colors.blueGrey
                          : Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['text']!),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text('Submit Answer'),
                selected: isSubmittingAnswer,
                onSelected: (val) => setState(() => isSubmittingAnswer = true),
              ),
              SizedBox(width: 12),
              ChoiceChip(
                label: Text('Ask Interviewer'),
                selected: !isSubmittingAnswer,
                onSelected: (val) => setState(() => isSubmittingAnswer = false),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    enabled: !interviewEnded,
                    onSubmitted: (value) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: interviewEnded
                          ? 'Interview has ended.'
                          : isSubmittingAnswer
                              ? 'Type your answer...'
                              : 'Ask the interviewer...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: interviewEnded ? null : sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
