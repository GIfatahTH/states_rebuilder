//OK
It is very easy to dynamically switch the theme of your app. states_rebuilder offers a very simple API to handle app theming.

# Table of Contents <!-- omit in toc --> 
- [**InjectedTheme**](#InjectedTheme)  
  - [**lightThemes**](#lightThemes)  
  - [**darkThemes**](#darkThemes)  
  - [**themeMode**](#themeMode)  
  - [**persistKey**](#persistKey)  
- [**get the current theme**](#get-the-current-theme)  
- [**Setting a theme**](#Setting-a-theme)  
- [**toggle between light and dark theme**](#toggle-between-light-and-dark-theme)  
- [**set ThemeMode**](#set-ThemeMode)  
- [**check the theme dark (isDarkTheme)**](#check-the-theme-dark-(isDarkTheme))  
- [**get supported themes**](#get-supported-themes)  
- [**listen to theme change**](#listen-to-theme-change)  


## InjectedTheme

Suppose our `InjectedAuth` state is named `theme`.


```dart
//Key is a generic type, it is the type of the 
//keys of the lightThemes and darkThemes map.
InjectedTheme<Key> theme = injectTheme<Key>({
    required Map<Key, ThemeData> lightThemes,
    Map<Key, ThemeData>? darkThemes,
    ThemeMode themeMode = ThemeMode.system,
    String? persistKey,
    //Similar to other injects
    SnapState<T> Function(MiddleSnapSate<Key> ) middleSnapState,
    void Function(Key s)? onInitialized,
    void Function(Key s)? onDisposed,
    On<void>? onSetState,
    DependsOn<Key>? dependsOn,
    int undoStackLength = 0,
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  })
```
### lightThemes

This is a required parameter. It is a `Map<Key, ThemeData>`. It maps the light themes the app supports.

`Key` can be a simple string or enumeration.

The first Map Entry is taken as the default (fallback) one.

### darkThemes

This is an optional parameter. Normally, there is a correspondence between the light and dark themes. Nevertheless, it is allowable to have a light theme that has no corresponded dark one.

### themeMode

Used to switch between dark, light, and system theme mode. The default value will be that of the system.

### persistKey
It is the key to be used to locally store the state of the theme. If defined the app will store the chosen theme and retrieve it on app start.

You have to first implement the `IPersistStore` or use the library `states_rebuilder_storage`.

## get the current theme
```dart
theme.lightTheme; // get current light theme
theme.darkTheme:  // get current dark theme
theme.themeMode:  // get current theme mode
```
## Setting a theme
To set the app to use a particular theme, you use:

```dart
//just mutate the state of the theme
theme.state = 'key';
```

## toggle between light and dark theme
```dart
theme.toggle();
```
## set ThemeMode 
```dart
theme.themeMode = ThemeMode.system;
```

## check the theme dark (isDarkTheme)
```dart
theme.isDarkTheme();
```
example:
```dart
Switch(
    value: theme.isDarkTheme,
    onChanged: (_) => theme.toggle(),
)
```
## get supported themes
```dart
theme.supportedLightThemes; //get a list of light supported themes
theme.supportedDarkThemes; //get a list of dark supported themes
```
## listen to theme change
To listen to the InjectedTheme state, we use the TopAppWidget that must be on top of the MaterialApp widget.
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(//Use TopAppWidget
      injectedTheme: theme, //Set te injectedTheme
      builder: (context) {
        return MaterialApp(
          theme: theme.lightTheme, //light theme
          darkTheme: theme.darkTheme, //dark theme
          themeMode: theme.themeMode, //theme mode
          home: HomePage(),
        );
      },
    );
  }
}
```

