# ex_005_1_internationalization_using_arb

## App localization steps
1. add `generate: true` to `pubspec.yaml` file
    ```yaml
        # The following section is specific to Flutter.
        flutter:
            generate: true # Add this line
    ```
2. Create the `l10n.yaml` file In the root directory of your flutter application and add the following content:
    ```yaml
        # [arb-dire] is the directory where to put the language arb files
        arb-dir: lib/l10n
        # arb file to take as template. It contains translation as well as metadata
        template-arb-file: app_en.arb
    ```
3. Create `lib/l10n` directory. Put all your arb languages here. For example create:
    - `app_en.arb` for english (the template one)
    - `app_ar.arb` for arabic
    - `app_es.arb` for spanish
4. Inside the `lib/l10n` folder, create the file `i18n.dart`, indicating where to use `Injected18n`
    ```dart
        import 'package:states_rebuilder/states_rebuilder.dart';
        // Generated file are in ${FLUTTER_PROJECT}/.dart_tool/flutter_gen/gen_l10n
        import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
        import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
        import 'package:flutter_gen/gen_l10n/app_localizations_es.dart';

        final i18nRM = RM.injectI18N({
            const Locale('en'): () => AppLocalizationsEn(),
            const Locale('ar'): () => AppLocalizationsAr(),
            const Locale('es'): () => AppLocalizationsEs(),
        });
    ```
    Flutter generates the translation files inside `${FLUTTER_PROJECT}/.dart_tool/flutter_gen/gen_l10n`.
    For each language, the generated class is `AppLocalizations[LAN_CODE]`. To import it use `import 'package:flutter_gen/gen_l10n/app_localizations_[LAN_CODE].dart'`;

    For example:
    - The language is `en` => the generated class is `AppLocalizationsEn`. To import: `import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';`
    - The language is `ar` => the generated class is `AppLocalizationsAr`. To import: `import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';`
    - The language is `es` => the generated class is `AppLocalizationsEs`. To import: `import 'package:flutter_gen/gen_l10n/app_localizations_es.dart';`
    - The language is `en_US` => the generated class is `AppLocalizationsEnUS`. To import: `import 'package:flutter_gen/gen_l10n/app_localizations_en_us.dart';`
5.  Use `TopStatelessWidget` in top of the `MaterialApp` widget:
    ```dart
        class MyApp extends TopStatelessWidget {
        const MyApp({Key? key}) : super(key: key);

        @override
        Widget build(BuildContext context) {
            return MaterialApp(
                locale: i18nRM.locale,
                localeResolutionCallback: i18nRM.localeResolutionCallback,
                localizationsDelegates: i18nRM.localizationsDelegates,
                
                home: const MyHomePage(),
            );
        }
        }
    ```

Now your app is globalized.

## working with arb files

`arb` files in `lib/l10n` follow the following naming convention: `app_[LAN_CODE].arb` and it must contain:
    ```arb
        {
          "@@locale": [LAN_CODE]
        }
    ```
* For english the name `app_en.arb` is contains:
    ```arb
        {
         "@@locale": "en"
        }
    ```
* For arabic the name `app_ar.arb` is contains:
    ```arb
        {
         "@@locale": "ar"
        }
    ```
* For spanish the name `app_es.arb` is contains:
   ```arb
        {
         "@@locale": "es"
        }
    ```
Now you can add translation messages.

### Simple String:

* For english:
    ```arb
        {
         "helloWorld": "Hello World!",
        }
    ```
* For arabic:
    ```arb
        {
          "helloWorld": "مرحبا بالجميع!",
        }
    ```
* For spanish:
   ```arb
        {
          "helloWorld": "¡Hola Mundo!",
        }
    ```
### String with arguments:

* For english:
    ```arb
        {
          "welcome": "Welcome {name}",
          "@welcome": {
              "placeholders": {
                  "name": {}
              }
          },
        }
    ```
* For arabic:
    ```arb
        {   
          "welcome": "مرحبا {name}",
        }
    ```
* For spanish:
   ```arb
        {
          "welcome": "Hola {name}",
        }
    ```
### gender:

* For english:
    ```arb
        {
          "gender": "{gender, select, male {Hi man!} female {Hi woman!} other {Hi there!}}",
          "@gender": {
              "placeholders": {
                  "gender": {}
              }
          },
        }
    ```
* For arabic:
    ```arb
        {           
          "gender": "{gender, select, male {مرحبا يارجل!} female {مرحبا يامرأة!} other {مرحبا هناك!}}",
        }
    ```
* For spanish:
   ```arb
        {
          "gender": "{gender, select, male {Hola el hombre!} female {Hola la mujer!} other {Hola!}}",
        }
    ```
### plural:

* For english:
    ```arb
        {
          "plural": "{howMany, plural, =1{1 message} other{{howMany} messages}}",
          "@plural": {
              "placeholders": {
                  "howMany": {}
              }
          },
        }
    ```
* For arabic:
    ```arb
        {
          "plural": "{howMany, plural,=0{صفر رسالة} =1{رسالة واحدة} 2{رسالاتان} few{{howMany} رسائل}  other{{howMany} رسالة}}",
        }
    ```
* For spanish:
   ```arb
        {
          "plural": "{howMany, plural, =1{1 mensaje} other{{howMany} mensajes}}",
        }
    ```
### Formatted number:

* For english:
    ```arb
        {
          "formattedNumber": "The formatted number is: {value}",
          "@formattedNumber": {
              "placeholders": {
                  "value": {
                      "type": "int",
                      "format": "compactLong"
                  }
              }
          },
        }
    ```
* For arabic:
    ```arb
        {
          "formattedNumber": "الرقم بعد التهيئة هو {value}",
        }
    ```
* For spanish:
   ```arb
        {
          "formattedNumber": "El número formateado es: {value}",
        }
    ```
### Date:

* For english:
    ```arb
        {
          "date": "It is {date}",
          "@date": {
              "placeholders": {
                  "date": {
                      "type": "DateTime",
                      "format": "yMMMMd"
                  }
              }
          }
        }
    ```
* For arabic:
    ```arb
        {
          "date": "اليوم هو {date}"
        }
    ```
* For spanish:
   ```arb
        {
          "date": "Es {date}"
        }
   ```

For more information about the localization tool, such as dealing with DateTime and handling plurals, see the [Internationalization User’s Guide](https://docs.google.com/document/d/10e0saTfAv32OZLRmONy866vnaw0I2jwL8zukykpgWBc/edit).

## For references: 
### Formatting a number
[See intl package docs](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html)

| Message “format” value | Output for formattedNumber(1200000)  |
| ---------------------- | ------------------------------------ |
| "compact" | "1.2M" |
| "compactCurrency" | "$1.2M" |
| "compactSimpleCurrency" | "$1.2M" |
| "compactLong" | "1.2 million" |
| "currency"* | "USD1,200,000.00" |
| "decimalPattern" | "1,200,000" |
| "decimalPercentPattern" | "120,000,000%" |
| "percentPattern" | "120,000,000%" |
| "scientificPattern" | "1E6" |
| "simpleCurrency" | "$1,200,000.00" |

## Date and time
[See intl package docs](https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html)

 | ICU  Name                  | Skeleton|
 | ---------------------------| --------|
 | DAY                          | d|
 | ABBR_WEEKDAY                 | E|
 | WEEKDAY                      | EEEE|
 | ABBR_STANDALONE_MONTH        | LLL|
 | STANDALONE_MONTH             | LLLL|
 | NUM_MONTH                    | M|
 | NUM_MONTH_DAY                | Md|
 | NUM_MONTH_WEEKDAY_DAY        | MEd|
 | ABBR_MONTH                   | MMM|
 | ABBR_MONTH_DAY               | MMMd|
 | ABBR_MONTH_WEEKDAY_DAY       | MMMEd|
 | MONTH                        | MMMM|
 | MONTH_DAY                    | MMMMd|
 | MONTH_WEEKDAY_DAY            | MMMMEEEEd|
 | ABBR_QUARTER                 | QQQ|
 | QUARTER                      | QQQQ|
 | YEAR                         | y|
 | YEAR_NUM_MONTH               | yM|
 | YEAR_NUM_MONTH_DAY           | yMd|
 | YEAR_NUM_MONTH_WEEKDAY_DAY   | yMEd|
 | YEAR_ABBR_MONTH              | yMMM|
 | YEAR_ABBR_MONTH_DAY          | yMMMd|
 | YEAR_ABBR_MONTH_WEEKDAY_DAY  | yMMMEd|
 | YEAR_MONTH                   | yMMMM|
 | YEAR_MONTH_DAY               | yMMMMd|
 | YEAR_MONTH_WEEKDAY_DAY       | yMMMMEEEEd|
 | YEAR_ABBR_QUARTER            | yQQQ|
 | YEAR_QUARTER                 | yQQQQ|
 | HOUR24                       | H|
 | HOUR24_MINUTE                | Hm|
 | HOUR24_MINUTE_SECOND         | Hms|
 | HOUR                         | j|
 | HOUR_MINUTE                  | jm|
 | HOUR_MINUTE_SECOND           | jms|
 | HOUR_MINUTE_GENERIC_TZ       | jmv|   (not yet implemented)
 | HOUR_MINUTE_TZ               | jmz|   (not yet implemented)
 | HOUR_GENERIC_TZ              | jv|    (not yet implemented)
 | HOUR_TZ                      | jz|    (not yet implemented)
 | MINUTE                       | m|
 | MINUTE_SECOND                | ms|
 | SECOND                       | s|
