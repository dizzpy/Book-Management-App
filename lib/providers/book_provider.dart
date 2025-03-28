import 'package:flutter/foundation.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  final List<Book> _books = [];

  List<Book> get books => [..._books];

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  void updateBook(Book book) {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      _books[index] = book;
      notifyListeners();
    }
  }

  void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  Book? getBook(String id) {
    return _books.firstWhere((b) => b.id == id);
  }
}
