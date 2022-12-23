# ex006_00_authentication_and_authorization

## Getting Started
First, make sure you have installed states_rebuilder package, please check out the [Installation Guide](https://github.com/GIfatahTH/states_rebuilder/tree/master/states_rebuilder_package#getting-started-with-states_rebuilder). 
<Br />


## Objective

In this example, you will learn how to handle user authentication and authorization.

## Exploring Use-cases

- [01: User authentication](./lib/ex_001_user_authentication)
   <br /><b> Description: </b>
    * In this example, we will use InjectedAuth to manage user authentication.
    * We will use FirebaseAuth to sign in/up a user using Google, Apple, Email and Password, or anonymously.
    * We will create our fake repository.
    * Sign in/up form is validated both in the frontend and backend.


- [02: User authentication using InjectedNavigator](./lib/ex_002_user_authentication_using_navigation2_api)
   <br /><b> Description: </b>
    * The same example rewritten using InjectedNavigator.

- [03: Authorizing a user and token refreshing](./lib/ex_003_auto_logout_and_refresh_token)
   <br /><b> Description: </b>
   * In this example, we will handle token and token refreshing.
   * We will see two scenarios.
        * User is automatically logged out after token expiration.
        * Token is refreshed just before token expires.
   * User credential are persisted to a local storage. 

- [04: Mocking InjectedAuth](./lib/ex_004_mocking_injected_auth)
   <br /><b> Description: </b>
   * Here you find different way of mocking `InjectedAuth`.

## Documentation
[🔍 See more detailed information about `InjectedAuth` API](https://github.com/GIfatahTH/states_rebuilder/wiki/home).


## Questions & Suggestions
Please feel free to post an issue or PR. As always, your feedback makes this library become better and better.

