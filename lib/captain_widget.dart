import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
}

extension GetCaptain on NavigatorState {
  void action(BuildContext context, dynamic actionKey) {
    return Captain.of(context).config.invokeAction(actionKey);
  }
}

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
