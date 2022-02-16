# ex005_00_crud_operations

## Getting Started
First, make sure you have installed states_rebuilder package, please check out the [Installation Guide](https://github.com/GIfatahTH/states_rebuilder/tree/master/states_rebuilder_package#getting-started-with-states_rebuilder). 
<Br />


## Objective

In this example, you will learn how to consume a Restful API by performing create, read, update and delete operations.

## Exploring Use-cases

- [01: CRUD operation using core state management](./lib/ex_000_crud_app_using_core_state_management)
   <br /><b> Description: </b>
    * In this example, we will create a todo app using only the core state management library.
    * We will follow clean architecture principles, and our code is testable and dependencies are changeable and mockable.
    * We will consume the `jsonplaceholder` API using the `http` library.
    * For the sake of completeness, we will create our fake repository.
    * All code functionality is tested.

- [02: CRUD operation using `InjectedCRUD`](./lib/ex_000_crud_app_using_core_state_management)
   <br /><b> Description: </b>
    * In this example, we will rewrite the first example using the `InjectedCRUD` object.
    * We will see that `InjectedCRUD` abstracts most of the repetitive tasks, following the principles of clean architecture.
    * `InjectedCRUD` makes it easy to develope a CRUD application without losing testability.

- [03: Mocking `InjectedCRUD`](./lib/ex_002_injected_curd_mocking)
   <br /><b> Description: </b>
    As testability means mockability, we show you different way to mock an `InjectedCRUD`

## Documentation
[🔍 See more detailed information about InjectedCRUD API](https://github.com/GIfatahTH/states_rebuilder/wiki/home).


## Question & Suggestion
Please feel free to post an issue or PR, as always, your feedback makes this library become better and better.

