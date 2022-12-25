import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';
/*
 * This is an example on how to use repositories and an external service provider.
 * You can easily fake a repository or a service provider if it is injected using
 * RM.inject or RM.injectFuture and consume it using its state getter.
 */

// Models
class Book {
  final String id;
  final String title;
  final String imageUrl;
  Book({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));
}

// Data source (Repositories)
class BooksRepository {
  // We inject the HttpClient so we can mock it.
  static final httpClientRM = RM.inject(() => http.Client());

  http.Client get client => httpClientRM.state;

  Future<List<Book>> getBooks() async {
    // This example uses the Google Books API to search for books about http.
    // https://developers.google.com/books/docs/overview
    var url =
        Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

    // Await the http get response, then decode the json-formatted response.
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var booksResponse = jsonResponse['items'] as List;
      final List<Book> books = [];
      for (final book in booksResponse) {
        books.add(Book(
          id: book['id'],
          title: book['volumeInfo']['title'],
          imageUrl: book['volumeInfo']['imageLinks']['smallThumbnail'],
        ));
      }
      return books;
    } else {
      throw Exception('fetching books failure');
    }
  }
}

// It is important to inject the repositories using RM.inject to enable easy mockability.
//
// See test folder where we use mocktail to mock it.
final booksRepositoryRM = RM.inject(() => BooksRepository());

@immutable
class BookService {
  // For injected repositories to be mockable, they must be consumed using their
  // state getter.
  BooksRepository get repository => booksRepositoryRM.state;

  late final _booksRM = RM.inject<List<Book>>(
    () => [],
    // Fire getBooks
    sideEffects: SideEffects(
      initState: () => getBooks(),
    ),
  );
  // We can use RM.injectedFuture

  List<Book> get books => [..._booksRM.state];
  late final whenBooksState = _booksRM.onAll;
  //
  void getBooks() {
    _booksRM.stateAsync = repository.getBooks();
  }
}

final bookService = BookService();

void main() {
  // Uncomment to use the faked HttpClient
  // BooksRepository.httpClientRM.injectMock(() => FakeClient());

  /*
  * You can also mock plugins the same way.
  */
  runApp(const MyApp());
}

class MyApp extends ReactiveStatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // We can fire getBooks here if we want to trigger it each time we enter this
  // Widget
  //
  // @override
  // void didMountWidget() {
  //   bookService.getBooks();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: bookService.whenBooksState(
            onWaiting: () => const CircularProgressIndicator(),
            onError: (err, refresh) => Text('${err.message}'),
            onData: (books) => ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(books[index].title),
                    leading: SizedBox(
                      child: Image.network(
                        books[index].imageUrl,
                      ),
                    ),
                  ),
                );
                // return Image.network(books[index].imageUrl);
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Here is the fake implementation of HttpClient
class FakeClient implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (url.queryParameters['q'] == '{http}') {
      return http.Response(
        convert.jsonEncode(fakeBody),
        200,
      );
    }
    return http.Response(
      'json',
      404,
    );
  }

  @override
  void close() {}

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers,
      Object? body,
      convert.Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers,
      Object? body,
      convert.Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers,
      Object? body,
      convert.Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers,
      Object? body,
      convert.Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }
}

const fakeBody = {
  "kind": "books#volumes",
  "totalItems": 1515,
  "items": [
    {
      "kind": "books#volume",
      "id": "guOixT8KyYEC",
      "etag": "9NK0wqowPNI",
      "selfLink": "https://www.googleapis.com/books/v1/volumes/guOixT8KyYEC",
      "volumeInfo": {
        "title": "HTTP",
        "subtitle": "précis & concis",
        "authors": ["Clinton Wong"],
        "publisher": "O'Reilly Media, Inc.",
        "publishedDate": "2000",
        "description":
            "HTTP (HyperText Transfer Protocol) est le protocole sans lequel aucune transaction ne pourrait exister sur le Web. C'est ce langage qui permet aux programmes client (Internet Explorer, Netscape, etc.) de communiquer avec les serveurs et de solliciter des actions toujours plus complexes. Ainsi, tout développeur de site, tout programmeur, tout administrateur, a besoin d'utiliser et de connaître HTTP. Certes, on peut se connecter tous les jours sans rien savoir d'HTTP, mais si vous voulez passer de l'autre côté de la toile mondiale, alors ce guide vous deviendra indispensable. Il propose une approche solide du protocole. Vous y trouverez une explication détaillée des requêtes clients et des réponses serveurs ; des tableaux résumant les paramètres standardisés utilisés par HTTP, des transcriptions d'échanges, les particularités les plus avancées du protocole (comme les connexions persistantes ou les cookies).",
        "industryIdentifiers": [
          {"type": "ISBN_10", "identifier": "2841771156"},
          {"type": "ISBN_13", "identifier": "9782841771158"}
        ],
        "readingModes": {"text": false, "image": true},
        "pageCount": 77,
        "printType": "BOOK",
        "maturityRating": "NOT_MATURE",
        "allowAnonLogging": false,
        "contentVersion": "2.1.2.0.preview.1",
        "panelizationSummary": {
          "containsEpubBubbles": false,
          "containsImageBubbles": false
        },
        "imageLinks": {
          "smallThumbnail":
              "http://books.google.com/books/content?id=guOixT8KyYEC&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
          "thumbnail":
              "http://books.google.com/books/content?id=guOixT8KyYEC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
        },
        "language": "fr",
        "previewLink":
            "http://books.google.com/books?id=guOixT8KyYEC&pg=PA1&dq=http&hl=&cd=1&source=gbs_api",
        "infoLink":
            "http://books.google.com/books?id=guOixT8KyYEC&dq=http&hl=&source=gbs_api",
        "canonicalVolumeLink":
            "https://books.google.com/books/about/HTTP.html?hl=&id=guOixT8KyYEC"
      },
      "saleInfo": {
        "country": "DZ",
        "saleability": "NOT_FOR_SALE",
        "isEbook": false
      },
      "accessInfo": {
        "country": "DZ",
        "viewability": "PARTIAL",
        "embeddable": true,
        "publicDomain": false,
        "textToSpeechPermission": "ALLOWED",
        "epub": {"isAvailable": false},
        "pdf": {"isAvailable": false},
        "webReaderLink":
            "http://play.google.com/books/reader?id=guOixT8KyYEC&hl=&printsec=frontcover&source=gbs_api",
        "accessViewStatus": "SAMPLE",
        "quoteSharingAllowed": false
      },
      "searchInfo": {
        "textSnippet":
            "\u003cb\u003eHTTP\u003c/b\u003e précis &amp; concis Ce livre décrit \u003cb\u003eHTTP\u003c/b\u003e , le protocole de transfert hypertexte ( HyperText Transfer Protocol ) , et contient des informations de références sur les requêtes des clients et les réponses des serveurs ."
      }
    },
    {
      "kind": "books#volume",
      "id": "oxg8_i9dVakC",
      "etag": "oCvPF7fdJvc",
      "selfLink": "https://www.googleapis.com/books/v1/volumes/oxg8_i9dVakC",
      "volumeInfo": {
        "title": "HTTP Developer's Handbook",
        "authors": ["Chris Shiflett"],
        "publisher": "Sams Publishing",
        "publishedDate": "2003",
        "description":
            "HTTP is the protocol that powers the Web. As Web applications become more sophisticated, and as emerging technologies continue to rely heavily on HTTP, understanding this protocol is becoming more and more essential for professional Web developers. By learning HTTP protocol, Web developers gain a deeper understanding of the Web's architecture and can create even better Web applications that are more reliable, faster, and more secure. The HTTP Developer's Handbook is written specifically for Web developers. It begins by introducing the protocol and explaining it in a straightforward manner. It then illustrates how to leverage this information to improve applications. Extensive information and examples are given covering a wide variety of issues, such as state and session management, caching, SSL, software architecture, and application security.",
        "industryIdentifiers": [
          {"type": "ISBN_10", "identifier": "0672324547"},
          {"type": "ISBN_13", "identifier": "9780672324543"}
        ],
        "readingModes": {"text": false, "image": true},
        "pageCount": 282,
        "printType": "BOOK",
        "categories": ["Computers"],
        "averageRating": 3.5,
        "ratingsCount": 6,
        "maturityRating": "NOT_MATURE",
        "allowAnonLogging": false,
        "contentVersion": "3.4.2.0.preview.1",
        "panelizationSummary": {
          "containsEpubBubbles": false,
          "containsImageBubbles": false
        },
        "imageLinks": {
          "smallThumbnail":
              "http://books.google.com/books/content?id=oxg8_i9dVakC&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
          "thumbnail":
              "http://books.google.com/books/content?id=oxg8_i9dVakC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
        },
        "language": "en",
        "previewLink":
            "http://books.google.com/books?id=oxg8_i9dVakC&pg=PA221&dq=http&hl=&cd=2&source=gbs_api",
        "infoLink":
            "http://books.google.com/books?id=oxg8_i9dVakC&dq=http&hl=&source=gbs_api",
        "canonicalVolumeLink":
            "https://books.google.com/books/about/HTTP_Developer_s_Handbook.html?hl=&id=oxg8_i9dVakC"
      },
      "saleInfo": {
        "country": "DZ",
        "saleability": "NOT_FOR_SALE",
        "isEbook": false
      },
      "accessInfo": {
        "country": "DZ",
        "viewability": "PARTIAL",
        "embeddable": true,
        "publicDomain": false,
        "textToSpeechPermission": "ALLOWED_FOR_ACCESSIBILITY",
        "epub": {"isAvailable": false},
        "pdf": {"isAvailable": false},
        "webReaderLink":
            "http://play.google.com/books/reader?id=oxg8_i9dVakC&hl=&printsec=frontcover&source=gbs_api",
        "accessViewStatus": "SAMPLE",
        "quoteSharingAllowed": false
      },
      "searchInfo": {
        "textSnippet":
            "A method of inband indicates that the key was previously included in a Key - Assign \u003cb\u003eHTTP\u003c/b\u003e header , whereas a method of outband indicates that the method of key exchange lies outside of the scope of Secure \u003cb\u003eHTTP\u003c/b\u003e . This flexibility would be&nbsp;..."
      }
    },
  ]
};
