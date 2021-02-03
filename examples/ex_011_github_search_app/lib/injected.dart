import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/github_search_repository.dart';
import 'domain/entities/github_user.dart';
import 'service/github_search_service.dart';
import 'service/interfaces/i_github_search_repository.dart';

bool isTestMode = false;
//Inject the repository throw the interface IGitHubSearchRepository so
//It can be mocked
final gitHubSearchRepository = RM.inject<IGitHubSearchRepository>(
  () => GitHubSearchRepository(),
);

//Inject the service
final gitHubSearchService = RM.inject(
  () => GitHubSearchService(
    gitHubSearchRepository: gitHubSearchRepository.state,
  ),
);

//Inject the query
//Here the query is a String but it can be any Class with multiple parameters
final Injected<String> userNameQuery = RM.inject(
  () => '',
  //OnData is invoked when the userNameQuery is changed without error
  //Each time the state of userNameQuery is changed we refresh the fetchedGitHubUser,
  //so the current future is canceled and a new fetch request is established.
  onData: (_) => fetchedGitHubUser.refresh(),
);

//Inject The fetched list of github user. it is the result of calling
//searchUser method and the parameter is obtained from userNameQuery.
final Injected<List<GitHubUser>> fetchedGitHubUser = RM.injectFuture(
  () => gitHubSearchService.state.searchUser(userNameQuery.state),
);
