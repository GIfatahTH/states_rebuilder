// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../../ex18_books_app.dart';
import '../../model/book.dart';
import '../author_details_page/author_details_page.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              book.author.name,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            TextButton(
              onPressed: () {
                navigator.toPageless(AuthorDetailsScreen(author: book.author));
              },
              child: const Text('View author (navigator.toPageless)'),
            ),
            Link(
              uri: Uri.parse('/author/${book.author.id}'),
              builder: (context, followLink) => TextButton(
                onPressed: followLink,
                child: const Text('View author (Link)'),
              ),
            ),
            TextButton(
              onPressed: () {
                navigator.to('/author/${book.author.id}');
              },
              child: const Text('View author (navigator.to)'),
            ),
          ],
        ),
      ),
    );
  }
}
