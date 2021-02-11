import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Configuration for a Captain widget
///
/// provide:
/// - list of initial pages
/// - popPage function where you should implement pop logic
/// - shouldPop function to decide whether to handle pop request
/// - actions that are callable via a dynamic key object and individually modify the page stack and make the navigator rebuild ->
/// return a List<Page> depending on current page stack
class CaptainConfig {
  CaptainConfig({
    this.pages,
    this.popPage,
    this.shouldPop,
    this.actions,
  });

  List<Page> pages;
  bool popPageRouterFacing(Route<dynamic> _route, dynamic _result) {
    return popPage(_route, _result, pages);
  }

  @protected
  final bool Function(Route<dynamic>, dynamic, List<Page>) popPage;

  Future<bool> shouldPopRouterFacing() async {
    return await shouldPop(pages);
  }

  @protected
  final Future<bool> Function(List<Page>) shouldPop;

  @protected
  final Map<dynamic, List<Page> Function(List<Page>)> actions;

  StreamController<bool> shouldRebuildMessengerPipe =
      StreamController.broadcast();

  void invokeAction(dynamic actionKey) {
    pages = actions[actionKey](pages);
    shouldRebuildMessengerPipe.add(true);
  }

  void invokeActionFunc(List<Page> Function(List<Page>) actionFunc) {
    pages = actionFunc(pages);
    shouldRebuildMessengerPipe.add(true);
  }
}

extension GetCaptain on NavigatorState {
  /// invoke an action on Captain with the actionKey object
  void action(dynamic actionKey) {
    return Captain.of(this.context).config.invokeAction(actionKey);
  }

  /// invoke a custom actionFunc on Captain with providing a function that takes a List<Page> as input and returns a List<Page> which will be the new page stack
  void actionFunc(List<Page> Function(List<Page>) actionFunc) {
    return Captain.of(this.context).config.invokeActionFunc(actionFunc);
  }
}

/// Captain widget "Router"
///
/// place the Captain widget beneath your MaterialApp and pass it a CaptainConfig
/// - Captain widgets can be nested just like Router
/// - Captain is compatible with Navigator imperative API style of calling
/// ````dart
/// Navigator.of(context).action("myActionKey");
/// Navigator.of(context).actionFunc((pageStack) => pageStack..add(pageToAdd));
/// ````
class Captain extends InheritedWidget {
  Captain({
    @required this.config,
  }) : super(
          child: Router(
            routerDelegate: AppRouterDelegate(
              config: config,
            ),
          ),
        );

  final CaptainConfig config;

  @override
  bool updateShouldNotify(covariant Captain oldWidget) {
    return oldWidget.config != config;
  }

  static Captain of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Captain>();
  }
}

class AppRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  AppRouterDelegate({
    this.config,
  }) {
    config.shouldRebuildMessengerPipe.stream.listen((_) {
      notifyListeners();
    });
  }
  final CaptainConfig config;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: config.pages,
      onPopPage: config.popPageRouterFacing,
    );
  }

  @override
  Future<bool> popRoute() {
    return config.shouldPopRouterFacing();
  }

  @override
  Future<void> setNewRoutePath(configuration) {
    return SynchronousFuture(() {
      config.pages.add(configuration);
      notifyListeners();
    }());
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();
}
