// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../ex18_books_app.dart';
import '../../data_source/library.dart';
import 'author_list.dart';

class AuthorsScreen extends StatelessWidget {
  const AuthorsScreen({Key? key}) : super(key: key);

  static const title = 'Authors';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(title),
        ),
        body: AuthorList(
          authors: libraryInstance.allAuthors,
          onTap: (author) {
            navigator.to('/author/${author.id}');
          },
        ),
      );
}
