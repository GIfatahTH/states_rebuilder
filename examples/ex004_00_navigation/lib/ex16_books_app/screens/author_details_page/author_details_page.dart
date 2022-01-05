// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

import '../../../ex18_books_app.dart';
import '../../model/author.dart';
import '../books_page/book_list.dart';

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({
    required this.author,
    Key? key,
  }) : super(key: key);

  final Author author;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(author.name),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: BookList(
                books: author.books,
                onTap: (book) => navigator.to('/book/${book.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
