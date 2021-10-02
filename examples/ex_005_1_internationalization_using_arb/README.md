# ex_005_1_internationalization_using_arb

Steps:
1. add `generate: true` to `pubspec.yaml` file
    ```yaml
    dependencies:
        flutter:
            sdk: flutter
       
    flutter:
        # Adds code generation (synthetic package) support 
        generate: true
    ```
2. Create the `l10n.yaml` file In the root directory of your flutter application and add the following cotenant:
    ```yaml
        # [arb-dire] is the directory where to put the language arb files
        arb-dir: lib/l10n
        # arb file to take as template. It contains translation as well as metadata
        template-arb-file: app_en.arb
    ```
3. create `lib/l10n`. Add put all your arb language here. For example create:
    - app_en.arb for english (the template one)
    - app_ar.arb for arabic
    - app_es.arb for spanish
4. inside the `lib/l10n` folder create the file `i18n.dart` where to use `Injected18n`
    ```dart
    
    ```