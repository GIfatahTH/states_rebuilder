import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../logic/viewModels/counter_model_injector.dart';

class CounterViewInjector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterModelInjector()],
      builder: (context, _) {
        final model = Injector.get<CounterModelInjector>();
        return StateBuilder(
          viewModels: [model],
          builder: (context, _) => Column(
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
      },
    );
  }
}

final String _firstExample = """
## counter_model_injector.dart file:

class CounterModelInjector extends __StatesRebuilder__ {
  int _counter = 0;
  int get counter => _counter;

  increment() {
    _counter++;
    __rebuildStates()__;
  }
}

## counter_view_injector.dart file:

class CounterViewInjector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return __Injector(__ //(1)
      __models: [() => CounterModel()],__ // (2)
      __builder: (context, _) {__
        __final model = Injector.get<CounterModel>();__// (3)
        return StateBuilder(
          viewModels: [model],
          __builder: (context, model) => Column(__ // (4)
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("\${model.counter}"),
                    RaisedButton(
                      child: Text("Increment"),
                      onPressed: model.increment,
                    )
                  ],
                ),
        );
      },
    );
  }
}

- (1) : _`Injector` is a widget and it is used to register models. It has to be add to the widget tree wherever any of its registered models is first needed._
- (2) : _You can register many models and services. The registered models can be dependent.
        example : 
        ```
        Injector(
          models:[
            ()=>ModelA(),
            ()=>ModelB(Injector.get<ModelA>()) 
            // ModelA is injected in the constructor of ModelB
          ]
          builder(context,model) => ...
        )
        ```
- (3) :_To get any of the registered models use `(Injector.get<RegisteredModel>()`_
       _To get a new instance of registered models use `(Injector.getNew<RegisteredModel>()`_
- (4) :_The `model` parameter of the builder closure is null and is not used for this particular case. It should be the registered instance of provided generic type which is not provided here._
""";
