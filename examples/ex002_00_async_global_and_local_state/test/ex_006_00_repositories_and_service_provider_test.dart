import 'package:ex002_00_async_global_and_local_state/ex_006_00_repositories_and_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

class FakeBookRepository extends Mock implements BooksRepository {}

void main() {
  final fakeRepository = FakeBookRepository();
  setUp(() {
    booksRepositoryRM.injectMock(() => fakeRepository);
  });

  testWidgets(
    'Mack BooksRepository and test the app '
    'THEN',
    (tester) async {
      when(() => fakeRepository.getBooks()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [
          Book(id: 'id1', title: 'title1', imageUrl: 'imageUrl1'),
          Book(id: 'id2', title: 'title2', imageUrl: 'imageUrl2'),
          Book(id: 'id3', title: 'title3', imageUrl: 'imageUrl3'),
        ];
      });
      // Use of network_image_mock library to mock Image network call
      mockNetworkImagesFor(
        () async {
          await tester.pumpWidget(const MyApp());
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          await tester.pump(const Duration(seconds: 1));
          expect(find.byType(ListTile), findsNWidgets(3));
          //
          expect(find.text('title1'), findsOneWidget);
          expect(find.text('title2'), findsOneWidget);
          expect(find.text('title3'), findsOneWidget);
        },
      );
    },
  );
}
