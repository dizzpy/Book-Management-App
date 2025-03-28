import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title);
    _authorController = TextEditingController(text: widget.book?.author);
    _descriptionController =
        TextEditingController(text: widget.book?.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter an author' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveBook,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBook() {
    if (_formKey.currentState?.validate() ?? false) {
      final book = Book(
        id: widget.book?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
      );

      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      if (widget.book == null) {
        bookProvider.addBook(book);
      } else {
        bookProvider.updateBook(book);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
