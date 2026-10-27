import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class AdminQuizScreen extends StatefulWidget {
  const AdminQuizScreen({super.key});

  @override
  State<AdminQuizScreen> createState() => _AdminQuizScreenState();
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class _AdminQuizScreenState extends State<AdminQuizScreen> {
  // Quiz states: 0 = Start Screen, 1 = Playing, 2 = Results
  int _gameState = 0;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  
  // Timer
  Timer? _timer;
  int _timeLeft = 15;
  
  // Confetti
  late ConfettiController _confettiController;

  // Master Question Bank (Randomized and subsetted every time)
  final List<Question> _allQuestions = [
    Question(
      questionText: 'What is the primary purpose of an e-commerce inventory management system?',
      options: [
        'To prevent stockouts and overstocking',
        'To design website banners',
        'To process customer support tickets',
        'To generate UI animations',
      ],
      correctIndex: 0,
      explanation: 'Inventory management ensures accurate stock levels, preventing both stockouts and excess inventory costs.',
    ),
    Question(
      questionText: 'In Flutter, which widget is most efficient for rendering large, dynamic product lists?',
      options: [
        'Column with children',
        'ListView.builder',
        'SingleChildScrollView',
        'Stack',
      ],
      correctIndex: 1,
      explanation: 'ListView.builder creates items lazily as they scroll into view, ensuring high performance for large datasets.',
    ),
    Question(
      questionText: 'What does the HTTP status code 200 signify in API responses?',
      options: [
        'Bad Request',
        'Unauthorized Access',
        'OK / Success',
        'Internal Server Error',
      ],
      correctIndex: 2,
      explanation: 'Status code 200 indicates that the request has succeeded.',
    ),
    Question(
      questionText: 'Which state management library uses ChangeNotifier and Provider pattern?',
      options: [
        'Bloc / Cubit',
        'Provider',
        'Riverpod',
        'Redux',
      ],
      correctIndex: 1,
      explanation: 'Provider builds on InheritedWidget and works seamlessly with ChangeNotifier for reactive state management.',
    ),
    Question(
      questionText: 'What is a key benefit of real-time order tracking in admin dashboards?',
      options: [
        'Slower order processing',
        'Faster fulfillment and enhanced customer satisfaction',
        'Higher server costs',
        'Reduced security',
      ],
      correctIndex: 1,
      explanation: 'Real-time tracking gives admins instant visibility to fulfill orders quickly and delight customers.',
    ),
    Question(
      questionText: 'In database systems, what does ACID stand for?',
      options: [
        'Access, Control, Index, Data',
        'Atomicity, Consistency, Isolation, Durability',
        'Async, Cache, Integration, Deployment',
        'Application, Client, Interface, Database',
      ],
      correctIndex: 1,
      explanation: 'ACID properties guarantee reliable transaction processing in database management systems.',
    ),
    Question(
      questionText: 'Why is input validation crucial for admin login forms?',
      options: [
        'To make the UI colorful',
        'To prevent unauthorized access and injection attacks',
        'To increase app download size',
        'To slow down user typing',
      ],
      correctIndex: 1,
      explanation: 'Robust validation safeguards admin portals against malicious inputs and unauthorized access.',
    ),
    Question(
      questionText: 'What is the main advantage of Flutter for building cross-platform admin suites?',
      options: [
        'Writing separate code for Web, iOS, and Android',
        'Single codebase compiled natively for Web, Mobile, and Desktop',
        'Using HTML and CSS directly',
        'Running only on desktop browsers',
      ],
      correctIndex: 1,
      explanation: 'Flutter allows developers to write one codebase and deploy natively across web, mobile, and desktop.',
    ),
    Question(
      questionText: 'What does widget tree rebuilding optimization in Flutter primarily rely on?',
      options: [
        'Const constructors and proper use of Keys',
        'Infinite loops',
        'Disabling garbage collection',
        'Hardcoding screen resolutions',
      ],
      correctIndex: 0,
      explanation: 'Using const constructors and keys prevents unnecessary rebuilds, keeping UI performance exceptionally smooth.',
    ),
    Question(
      questionText: 'Which file is used for package and dependency management in Flutter projects?',
      options: [
        'build.gradle',
        'pubspec.yaml',
        'AndroidManifest.xml',
        'main.dart',
      ],
      correctIndex: 1,
      explanation: 'pubspec.yaml declares project dependencies, assets, and metadata.',
    ),
    Question(
      questionText: 'What is the primary role of an admin dashboard in an e-commerce platform?',
      options: [
        'Monitoring sales, orders, analytics, and managing inventory',
        'Playing background music for shoppers',
        'Designing customer avatars',
        'Mining cryptocurrencies',
      ],
      correctIndex: 0,
      explanation: 'An admin dashboard provides centralized control over store operations, analytics, and fulfillment.',
    ),
    Question(
      questionText: 'What are WebSockets commonly used for in modern admin applications?',
      options: [
        'Bi-directional real-time communication (e.g. live notifications & order alerts)',
        'Static file compression',
        'Database backups',
        'Font rendering',
      ],
      correctIndex: 0,
      explanation: 'WebSockets establish persistent connections for instant, real-time push events.',
    ),
    Question(
      questionText: 'Why use SharedPreferences in Flutter applications?',
      options: [
        'To store simple key-value pairs locally on the device',
        'To render complex 3D graphics',
        'To compile native iOS binaries',
        'To execute SQL database migrations',
      ],
      correctIndex: 0,
      explanation: 'SharedPreferences is ideal for persisting lightweight data like auth tokens or theme settings locally.',
    ),
    Question(
      questionText: 'What is the purpose of R8 / ProGuard during Android release builds?',
      options: [
        'Code shrinking, obfuscation, and optimization',
        'Translating Dart code to Python',
        'Adding watermarks to images',
        'Increasing APK size',
      ],
      correctIndex: 0,
      explanation: 'R8 optimizes bytecode and obfuscates code to reduce app size and protect intellectual property.',
    ),
    Question(
      questionText: 'How do you handle asynchronous network operations cleanly in Dart?',
      options: [
        'Using async and await keywords with Futures',
        'Blocking the main UI thread with loops',
        'Using print statements',
        'Restarting the application',
      ],
      correctIndex: 0,
      explanation: 'async/await allows asynchronous code to be written cleanly and sequentially without freezing the UI.',
    ),
  ];

  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    // Shuffle master questions and take 6 random questions every single time!
    final shuffled = List<Question>.from(_allQuestions)..shuffle();
    setState(() {
      _questions = shuffled.take(6).toList();
      _gameState = 1;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedOptionIndex = null;
      _answered = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 15;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _handleAnswerTimeout();
      }
    });
  }

  void _handleAnswerTimeout() {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOptionIndex = -1;
    });

    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _selectOption(int index) {
    if (_answered) return;
    _timer?.cancel();

    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
      if (index == _questions[_currentQuestionIndex].correctIndex) {
        _score += 10;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _answered = false;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      setState(() {
        _gameState = 2;
      });
      final maxScore = _questions.length * 10;
      final percentage = (_score / maxScore) * 100;
      if (percentage >= 60) {
        _confettiController.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentGameState(),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentGameState() {
    switch (_gameState) {
      case 0:
        return _buildStartScreen();
      case 1:
        return _buildPlayingScreen();
      case 2:
        return _buildResultScreen();
      default:
        return _buildStartScreen();
    }
  }

  Widget _buildStartScreen() {
    return Column(
      key: const ValueKey(0),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.sports_esports_rounded, size: 56, color: Color(0xFF2563EB)),
        ),
        const SizedBox(height: 24),
        Text(
          'Admin Brain Boost & Trivia',
          style: GoogleFonts.lexend(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Test your e-commerce, architecture, and Flutter expertise! Each game features a fresh random set of questions, 15 seconds per question, and celebration rewards upon winning.',
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoChip(Icons.shuffle_rounded, 'Randomized Questions'),
            const SizedBox(width: 16),
            _buildInfoChip(Icons.timer_rounded, '15s / Q'),
            const SizedBox(width: 16),
            _buildInfoChip(Icons.emoji_events_rounded, 'Win Badges'),
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _startQuiz,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              'Start Random Quiz',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingScreen() {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      key: ValueKey(_currentQuestionIndex),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeLeft <= 5 ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _timeLeft <= 5 ? Colors.red.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: _timeLeft <= 5 ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '0:${_timeLeft.toString().padLeft(2, '0')}',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 5 ? Colors.red : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          question.questionText,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(question.options.length, (index) {
          bool isSelected = _selectedOptionIndex == index;
          bool isCorrect = index == question.correctIndex;

          Color borderColor = Colors.grey.shade200;
          Color bgColor = Colors.white;
          Color textColor = const Color(0xFF1E293B);

          if (_answered) {
            if (isCorrect) {
              borderColor = Colors.green.shade400;
              bgColor = Colors.green.shade50;
              textColor = Colors.green.shade900;
            } else if (isSelected && !isCorrect) {
              borderColor = Colors.red.shade400;
              bgColor = Colors.red.shade50;
              textColor = Colors.red.shade900;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectOption(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _answered && isCorrect
                              ? Colors.green
                              : _answered && isSelected && !isCorrect
                              ? Colors.red
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _answered && (isCorrect || (isSelected && !isCorrect))
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (_answered && isCorrect)
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                      if (_answered && isSelected && !isCorrect)
                        const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_answered) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.explanation,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultScreen() {
    final maxScore = _questions.length * 10;
    final percentage = (_score / maxScore) * 100;
    bool isWinner = percentage >= 60;

    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isWinner ? Colors.green.shade50 : Colors.amber.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isWinner ? Icons.emoji_events_rounded : Icons.sentiment_satisfied_rounded,
            size: 64,
            color: isWinner ? Colors.green : Colors.amber.shade800,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isWinner ? '🎉 Amazing Job, Champion! 🎉' : 'Good Effort, Keep Practicing!',
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isWinner
              ? 'You successfully passed the Admin Quiz with flying colors!'
              : 'You scored $_score out of $maxScore. Try again to unlock the master badge!',
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Final Score', '$_score pts'),
              _buildStatItem('Accuracy', '${percentage.toStringAsFixed(0)}%'),
              _buildStatItem('Status', isWinner ? 'Winner 🏆' : 'Runner Up'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _startQuiz,
                child: Text(
                  'Play Again (New Quiz)',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    _gameState = 0;
                  });
                },
                child: Text(
                  'Back to Menu',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
