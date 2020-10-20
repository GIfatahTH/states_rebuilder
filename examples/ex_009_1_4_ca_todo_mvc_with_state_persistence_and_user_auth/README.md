# ex_009_1_4_ca_todo_mvc_with_state_persistence_and_user_auth

...Tutorial todo?!!

The example consist of the [Todo MVC app](https://github.com/brianegan/flutter_architecture_samples/blob/master/app_spec.md) extended to handle dynamic dark/light theme and app internationalization.
The app state will be stored using SharedPreferences, Hive and sqflite for demonstration purpose. In This example we will add user authentication.



* Firebase as a dummy web server, knowledge here are applicable to any web server
1. create firebase project
2. create a realtime database and start in test mode
3. notice the generated url which we will use:
. in my case the name of the project is todo-mvc-fi and the generated url is https://todo-mvc-fi.firebaseio.com/
5. change the security rule to read and write `auth != null` so that only authenticated user can read and write
6. under authentication tap unlock email and password sign in ()[https://firebase.google.com/docs/database/security]

()[https://firebase.google.com/docs/reference/rest/auth/#section-sign-in-email-password]


https://console.firebase.google.com/project/todo-mvc-fi/settings/general