import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import '../../../ui/common/localization/localization.dart';

class StatsCounter extends StatelessWidget {
  const StatsCounter();

  @override
  Widget build(BuildContext context) {
    return todosStat.listen(
      child: On.or(
        onWaiting: () => Center(child: CircularProgressIndicator()),
        or: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  i18n.of(context).completedTodos,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  '${todosStat.state.completed}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  i18n.of(context).activeTodos,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  '${todosStat.state.active}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
