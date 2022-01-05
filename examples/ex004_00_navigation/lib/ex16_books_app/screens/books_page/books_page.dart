// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../../ex18_books_app.dart';
import '../../data_source/library.dart';
import '../../model/book.dart';
import 'book_list.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late final String? kind = context.routeData.pathParams['kind'];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    switch (kind) {
      case 'popular':
        _tabController.index = 0;
        break;

      case 'new':
        _tabController.index = 1;
        break;

      case 'all':
        _tabController.index = 2;
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Books'),
          bottom: TabBar(
            controller: _tabController,
            onTap: _handleTabTapped,
            tabs: const [
              Tab(
                text: 'Popular',
                icon: Icon(Icons.people),
              ),
              Tab(
                text: 'New',
                icon: Icon(Icons.new_releases),
              ),
              Tab(
                text: 'All',
                icon: Icon(Icons.list),
              ),
            ],
          ),
        ),
        body: BookList(
          books: () {
            final location = navigator.routeData.location;
            if (location.startsWith('/books/all')) {
              return libraryInstance.allBooks;
            }
            if (location.startsWith('/books/popular')) {
              return libraryInstance.popularBooks;
            }
            return libraryInstance.newBooks;
          }(),
          onTap: _handleBookTapped,
        ),
        // body: TabBarView(
        //   controller: _tabController,
        //   children: [
        //     BookList(
        //       books: libraryInstance.popularBooks,
        //       onTap: _handleBookTapped,
        //     ),
        //     BookList(
        //       books: libraryInstance.newBooks,
        //       onTap: _handleBookTapped,
        //     ),
        //     BookList(
        //       books: libraryInstance.allBooks,
        //       onTap: _handleBookTapped,
        //     ),
        //   ],
        // ),
      );

  void _handleBookTapped(Book book) {
    navigator.to('/book/${book.id}');
  }

  void _handleTabTapped(int index) {
    switch (index) {
      case 1:
        navigator.to('/books/new');
        break;
      case 2:
        navigator.to('/books/all');
        break;
      case 0:
      default:
        navigator.to('/books/popular');
        break;
    }
  }
}
