import 'package:flutter/material.dart';
import '../controllers/hive_controller.dart';
import '../controllers/sqllite_controller.dart';
import '../models/note.dart';

enum StorageType { sqLite, hive }

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final SqLiteController _sqLiteController = SqLiteController();
  final HiveController _hiveController = HiveController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Note> _notes = [];
  StorageType _selectedStorage = StorageType.sqLite;
  Color _selectedColor = Colors.white; // Default color

  @override
  void initState() {
    super.initState();
    _initialHive();
    _loadNotes();
  }

  void _initialHive() async {
    await _hiveController.init();
  }

  void _loadNotes() async {
    if (_selectedStorage == StorageType.sqLite) {
      final notes = await _sqLiteController.getNotes();
      setState(() {
        _notes = notes;
      });
    } else {
      _initialHive();
      final notes = await _hiveController.getNotes();
      setState(() {
        _notes = notes;
      });
    }
  }

  void _addNote() async {
    final note = Note(
      title: _titleController.text,
      content: _contentController.text,
      color: _selectedColor.value, // Save color as an integer
    );
    if (_selectedStorage == StorageType.sqLite) {
      await _sqLiteController.insert(note);
    } else {
      await _hiveController.add(note);
    }

    _titleController.clear();
    _contentController.clear();

    _loadNotes();
  }

  void _deleteNote(int index) async {
    if (_selectedStorage == StorageType.sqLite) {
      await _sqLiteController.delete(_notes[index].id!);
    } else {
      await _hiveController.delete(index);
    }
    _loadNotes();
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Notes",style: TextStyle(color: Colors.red),),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColorButton(Colors.red),
                        _buildColorButton(Colors.green),
                        _buildColorButton(Colors.blue),
                        _buildColorButton(Colors.yellow),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _addNote,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<StorageType>(
              value: _selectedStorage,
              onChanged: (StorageType? newValue) {
                setState(() {
                  _selectedStorage = newValue!;
                });
                _loadNotes();
              },
              items: const [
                DropdownMenuItem(
                  value: StorageType.sqLite,
                  child: Row(
                    children: [Text("SQLite  "), Icon(Icons.storage)],
                  ),
                ),
                DropdownMenuItem(
                  value: StorageType.hive,
                  child: Row(
                    children: [Text("Hive  "), Icon(Icons.bug_report_rounded)],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Color(note.color), // Apply saved color
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteNote(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _selectedColor == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }
}
