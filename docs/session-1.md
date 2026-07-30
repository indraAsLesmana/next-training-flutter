# Session 1: Flutter Basics & Layouts

## Durasi: 4 jam

## Objectives
- Memahami dasar Flutter dan Dart
- Mengenal widget dan layout Flutter
- Membuat UI sederhana
- Memahami state dan lifecycle

## Agenda
1. Introduction to Flutter (30 menit)
2. Dart Programming Basics (45 menit)
3. Widget Fundamentals (60 menit)
4. Hands-on Practice (45 menit)

## 1. Introduction to Flutter

### Apa itu Flutter?
- **Flutter SDK:** Framework UI dari Google untuk mobile, web, desktop
- **Dart Language:** Bahasa pemrograman untuk Flutter
- **Hot Reload:** Fitur development yang mempercepat iterasi

### Keunggulan Flutter
- Single codebase untuk iOS dan Android
- Performa tinggi dengan rendering langsung ke canvas
- Rich widget library
- Strong community support

### Setup Project Baru
```bash
# Create new Flutter project
flutter create todo_app_flutter

# Navigate to project
cd todo_app_flutter

# Run the app
flutter run
```

## 2. Dart Programming Basics

### Variabel dan Tipe Data
```dart
// Variables
String name = 'Flutter Training';
int participantCount = 4;
double rating = 4.8;
bool isActive = true;

// Lists
List<String> participants = ['Participant 1', 'Participant 2'];
List<int> scores = [85, 90, 95];

// Maps
Map<String, dynamic> user = {
  'name': 'John Doe',
  'age': 30,
  'isTeacher': true,
};
```

### Functions
```dart
// Basic function
void printMessage(String message) {
  print('Message: $message');
}

// Function with return value
int addNumbers(int a, int b) {
  return a + b;
}

// Arrow function (single expression)
int multiply(int a, int b) => a * b;

// Named parameters
void displayInfo({String name, int age}) {
  print('Name: $name, Age: $age');
}
```

### Classes dan Objects
```dart
class Task {
  String title;
  String description;
  bool isCompleted;

  Task(this.title, this.description, {this.isCompleted = false});

  void complete() {
    isCompleted = true;
    print('Task "$title" completed');
  }
}
```

## 3. Widget Fundamentals

### Stateless Widget
```dart
import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  final String name;

  GreetingWidget({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

### Stateful Widget
```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: _incrementCounter,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### Basic Widgets
```dart
Column(
  children: [
    Text('Heading', style: TextStyle(fontSize: 24)),
    SizedBox(height: 16),
    TextField(
      decoration: InputDecoration(
        labelText: 'Enter task',
        border: OutlineInputBorder(),
      ),
    ),
    SizedBox(height: 16),
    ElevatedButton(
      onPressed: () {},
      child: Text('Add Task'),
    ),
    SizedBox(height: 16),
    CheckboxListTile(
      title: Text('Task 1'),
      value: false,
      onChanged: (value) {},
    ),
  ],
)
```

### Layout Widgets
```dart
// Column (vertical)
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [...],
)

// Row (horizontal)
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [...],
)

// Container (box with styling)
Container(
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Text('Task Item'),
)
```

## 4. Hands-on Practice

### Exercise 1: Create Simple UI
Buat screen dengan komponen:
1. AppBar dengan title
2. TextField untuk input
3. Button untuk submit
4. List untuk menampilkan items

```dart
class SimpleTodoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple To-Do'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'What needs to be done?',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Add Task'),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Task 1'),
                  trailing: Icon(Icons.delete),
                ),
                ListTile(
                  title: Text('Task 2'),
                  trailing: Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Exercise 2: Add Interactivity
Tambah state management sederhana:
1. Buat StatefulWidget
2. Tambahkan List untuk menyimpan tasks
3. Implement addTask function
4. Update UI saat state berubah

```dart
class InteractiveTodoScreen extends StatefulWidget {
  @override
  _InteractiveTodoScreenState createState() => _InteractiveTodoScreenState();
}

class _InteractiveTodoScreenState extends State<InteractiveTodoScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text);
        _controller.clear();
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... similar structure
      body: Column(
        children: [
          // ... input section
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_tasks[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 5. Summary & Key Takeaways

### What We Learned:
- ✅ Struktur dasar Flutter project
- ✅ Sintaks Dart: variables, functions, classes
- ✅ Stateless vs Stateful widgets
- ✅ Basic layout dengan Column, Row, Container
- ✅ State management dengan setState()

### Best Practices:
1. **Widget Composition:** Pecah UI menjadi widget kecil
2. **Immutability:** Gunakan final dan const sebanyak mungkin
3. **Separation of Concerns:** Pisahkan UI, logic, dan data
4. **Clean Code:** Gunakan meaningful names dan komentar

### Common Pitfalls:
- ❌ Forgetting setState() pada StatefulWidget
- ❌ Build method yang terlalu kompleks
- ❌ Tidak menggunakan const untuk widget statis
- ❌ Direct manipulation widget state

## 6. Homework / Preparation for Next Session

### Exercises:
1. Buat custom widget untuk task item
2. Tambahkan checkbox untuk task completion
3. Implement filter untuk completed/incomplete tasks
4. Tambahkan styling dengan themes

### Reading Materials:
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Layouts Guide](https://docs.flutter.dev/development/ui/layout)

### Tools to Explore:
- Flutter Inspector di VS Code
- Dart DevTools untuk debugging
- Hot Reload vs Hot Restart

## 7. Q&A Session

### Common Questions:
**Q:** Apa perbedaan Stateless dan Stateful widget?
**A:** Stateless widget immutable (tidak bisa berubah), Stateful widget mutable (bisa berubah state-nya).

**Q:** Kapan harus menggunakan const?
**A:** Gunakan const untuk widget yang tidak berubah selama runtime.

**Q:** Bagaimana cara debug Flutter app?
**A:** Gunakan print() untuk logging, Dart DevTools untuk inspect widget tree.

### Next Session Preview:
- **Session 2:** HTTP & API Integration
- **Session 3:** Neon Database Setup
- **Session 4:** CRUD Implementation
- **Session 5:** State Management & Polish

## 8. Resources

### Code Examples:
- [Github Repository](https://github.com/example/flutter-training)
- [Dart Pad Online](https://dartpad.dev)

### Documentation:
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Widget Catalog](https://flutter.dev/docs/development/ui/widgets)

### Community:
- [Flutter Indonesia](https://t.me/flutter_id)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Weekly](https://flutterweekly.net)

## 9. Assessment

### Quick Quiz:
1. Widget apa yang digunakan untuk vertical layout?
2. Apa fungsi setState()?
3. Bagaimana cara membuat function dengan named parameters?
4. Apa perbedaan ListView dan Column?

### Practice Project:
Buat aplikasi counter dengan:
- Tombol increment dan decrement
- Display angka counter
- Reset button
- Change theme color button