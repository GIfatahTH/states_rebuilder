// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../model/author.dart';

class AuthorList extends StatelessWidget {
  const AuthorList({
    required this.authors,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final List<Author> authors;
  final ValueChanged<Author>? onTap;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: authors.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            authors[index].name,
          ),
          subtitle: Text(
            '${authors[index].books.length} books',
          ),
          onTap: onTap != null ? () => onTap!(authors[index]) : null,
        ),
      );
}
