import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/theme_provider.dart';
import '../models/book.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                );
              },
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          final books = bookProvider.books;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Dismissible(
                key: Key(book.id),
                background: Container(
                  color: Colors.green.shade100,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: const Icon(Icons.edit, color: Colors.green),
                ),
                secondaryBackground: Container(
                  color: Colors.red.shade100,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Edit
                    _showBookForm(context, book);
                    return false;
                  } else {
                    // Delete confirmation
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: Text(
                              "Are you sure you want to delete '${book.title}'?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    bookProvider.deleteBook(book.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${book.title} deleted'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Card(
                  child: ListTile(
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showBookForm(context, book);
                        } else if (value == 'delete') {
                          bookProvider.deleteBook(book.id);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBookForm(BuildContext context, [Book? book]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BookFormSheet(book: book),
      ),
    );
  }
}

class BookFormSheet extends StatefulWidget {
  final Book? book;

  const BookFormSheet({super.key, this.book});

  @override
  State<BookFormSheet> createState() => _BookFormSheetState();
}

class _BookFormSheetState extends State<BookFormSheet> {
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.book == null ? 'Add Book' : 'Edit Book',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saveBook,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
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
