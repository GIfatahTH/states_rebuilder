# ex_009_1_3_ca_todo_mvc_with_state_persistence

* Firebase as a dummy web server, knolage here are applicable to any web servere
1. create firebase project
2. create a realtime database and start in test mode
3. notice the generated url which we will use:
. in my case the name of the project is todo-mvc-fi and the generated url is https://todo-mvc-fi.firebaseio.com/
5. change the security rule to read and write `auth != null` so that only authenticated user ca read and write
6. under authentication tap unlack email and password sign in ()[https://firebase.google.com/docs/database/security]

()[https://firebase.google.com/docs/reference/rest/auth/#section-sign-in-email-password]


https://console.firebase.google.com/project/todo-mvc-fi/settings/general