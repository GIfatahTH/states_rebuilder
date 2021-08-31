//OK
Hello world, hola mondo, boujour le monde and مرحبا بالعالم .

With `RM.injectI18N`, app internationalization has never been easier.

# Table of Contents <!-- omit in toc --> 
- [**Create translation classes**](#Create-translation-classes)  
- [**InjectI18N**](#InjectI18N)  
  - [**selectionMap**](#selectionMap)  
  - [**persistKey**](#persistKey)  
- [**Listen to i18n (TopAppWidget)**](#Listen-to-i18n-(TopAppWidget))  
- [**Consume the translation**](#Consume-the-translation) 
- [**Change locale**](#Change-locale)   
- [**Device system locale**](#Device-system-locale)
- [**supported locales**](#supported-locales)   

## Create translation classes
You start by creating the translation class.

Example:
For English US:
```dart
//My naming convention is: EnUS = (En: language code, US: country code)
class EnUS{
    final helloWorld = 'Hello world';
    //You can use method for plurals
    String countTimes(int count){
        if (count<=1){
            return '$count time';
        }
        return '$count times';
    }

    //Can have formJson method if the translation is load asynchronously
    EnUs fromJson(String json){
        ...
    }
}
```
For Arabic
```dart
//Implements EnUS for type consistency.
//We can use an abstract class as type.
class ArDZ implements EnUS { 
    final helloWorld = 'مرحبا بالعالم';
    //You can use method for plurals
    String countTimes(int count){
        if (count<=1){
            return '$count مرة';
        }
        return '$count مرات';
    }
}
```

## InjectI18N:
```dart
  static InjectedI18N<I18N> i18n = RM.injectI18N<I18N>(
    Map<Locale, FutureOr<I18N> Function()> selectionMap, {
    String? persistKey,
    //
    //Similar to other injected
    SnapState<T> Function(MiddleSnapSate<I18N> ) middleSnapState,
    void Function(I18N s)? onInitialized,
    void Function(I18N s)? onDisposed,
    On<void>? onSetState,
    DependsOn<I18N>? dependsOn,
    int undoStackLength = 0,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  })
```

### selectionMap
It is a map between `Locale`s and function that returns the corresponding translation Objects.

The function return is FutureOr of the translation object type. This means that we can return Futures.

Example:

```dart
final i18n = RM.injectI18N<EnUS>(
    {
        Locale('en', 'US'): ()=> EnUS();
        Locale('es', 'Es'): () async {
            String json = await rootBundle.loadString('lang/es_es.json');
            return EsES.fromJson(json);
        };
    }
)
```
Notice here that translation can be obtained synchronously or asynchronously. Both ways are accepted. Even if you mix them, states_rebuilder will handle them appropriately.

## persistKey
It is the key to be used to locally store the state of the app's locale. If defined the app will store the chosen locale and retrieve it on app start.

You have to first implement the `IPersistStore` or use the library `states_rebuilder_storage`.

## Listen to i18n (TopAppWidget)

To make the state of the `InjectedI18N` available to the widget tree, we use the `TopAppWidget`.

```dart
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(
      //Provide and listen to i18n state
      injectedI18N: i18n,
      //If the translation is obtained asynchronously, we must define
      //the onWaiting widget.
      onWaiting: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      builder: (context) {
        return MaterialApp(
          //Defining locale and localeResolutionCallback is more than enough for the app to get 
          //the right locale.
          locale: i18n.locale,
          localeResolutionCallback: i18n.localeResolutionCallback,

          //For more elaborate locale resolution algorithm use supportedLocales and 
          //localeListResolutionCallback.
          // supportedLocales: i18n.supportedLocales,
          // localeListResolutionCallback: (List<Locale>? locales, Iterable<Locale> supportedLocales){
          //   //your algorithm
          //   } ,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomePage(),//Notice const here
        );
      },
    );
  }
}
```
The `onWaiting` parameter of TopAppWidget is optional and should be defined if the translation is fetched from an async source. If you forget to define onWaiting and some of your translations are async and an exception will be thrown.

## Consume the translation

In the widget tree, we use the `i18n.of(context)` to obtain the translations.
```dart
Text(i18n.of(context).helloWorld);
Text(i18n.of(context).countTimes(count));
```
The `of` method depends on an inherited widget, so even if your widget is declared const, it will rebuild when the app locale changes.

You can directly use `i18n.state.helloWorld` and it will work provided you do not use const widgets that prevent the parent from rebuilding them.

## Change locale
To change locale use set the locale of the i18n state
```dart
i18n.locale = Locale('en');
i18n.locale = SystemLocale();
```
states_rebuilder search of an exact match for the locale, if don't find any, it searches for a locale with the same languageCode. If that fails, then the first element in `selectionMap` is used.

SystemLocale is a class from states_rebuilder library. It extends the Locale class. It is used to represent the system locale.

Example: 

```dart
PopupMenuButton<Locale>(
    onSelected: (locale) {
        //set the locale, the app will use the corresponding translation
        i18n.locale = locale;
    },
    itemBuilder: (context) {
        return [
        //First item is for the system locale
        PopupMenuItem(
            value: SystemLocale(),
            child: Text('Use system language'),
        ),
        //Map throw all the supported locales
        ...i18n.supportedLocales.map(
            (e) => PopupMenuItem(
                value: locale,
                child: Text('$locale'),
            ),
          )
        ];
    },
),
```
## Device system locale
If the app is set to use the system locale, then it will look for the device system locale. and search if it finds an exact correspondence in the `selectionMap`. If it does not find one, it looks for a locale with the same language code, and lastly, if it fails it takes the first locale in the `selectionMap`.

When the device app locale changes, states_rebuilder observe it and change to the corresponding locale.

## supported locales
Use the getter `supportedLocales` to get the support locales.