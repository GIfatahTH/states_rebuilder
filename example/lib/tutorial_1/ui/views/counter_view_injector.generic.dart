import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../logic/viewModels/counter_model_injector.generic.dart';

class CounterViewInjectorGeneric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<CounterModelInjectorGeneric>(
      models: [() => CounterModelInjectorGeneric()],
      builder: (context, CounterModelInjectorGeneric model) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("${model.counter}"),
              RaisedButton(
                child: Text("Increment"),
                onPressed: model.increment,
              ),
              Divider(),
              Expanded(
                child: Markdown(data: _firstExample),
              )
            ],
          ),
    );
  }
}

final String _firstExample = """
## counter_model_injector_generic.dart file:

class CounterModelInjectorGeneric extends __StatesRebuilder__ {
  int _counter = 0;
  int get counter => _counter;

  increment() {
    _counter++;
    __rebuildStates()__;
  }
}

## counter_view_injector_generic.dart file:

class CounterViewInjectorGeneric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return __Injector<CounterModelInjectorGeneric>(__ // (1)
      __models: [() => CounterModelInjectorGeneric()],__ // (2)
      __builder: (context,CounterModelInjectorGeneric model) => Column(__ // (3)
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("\${model.counter}"),
                RaisedButton(
                  child: Text("Increment"),
                  onPressed: model.increment,
                ),
               )
              ],
            ),
    );
  }
}

- (1) : _`Injector` is used with generic type. The generic type class must extend `StatesRebuilder`. The generic type class should be the viewModel related to this view._
- (2) : _Alongside width the generic class you can register many models and services. The registered models can be dependent._
        example : 
        ```
        Injector<ViewModelRelatedToThisView>(
          models:[
            ()=>ViewModelRelatedToThisView(),
            ()=>ModelB(),
            ()=>ModelC(Injector.get<ModelA>()),
          ]
          builder(context,ViewModelRelatedToThisView model) => ...
        )
        ```
- (3) :_The `model` parameter of the builder closure of type `CounterModelInjectorGeneric`. If we provide a generic type to the `Injector`, we do not need to used `StateBuilder` to rebuild all the view because it is automatically add to listeners list of the generic viewModel._
""";
