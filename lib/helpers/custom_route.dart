import 'package:flutter/material.dart';

//<T> indicates generic data
class CustomRoute<T> extends MaterialPageRoute<T> {
  //takes builder and setting
  CustomRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  //add build transition method, this controls how page transition is animated and by overriding we can get own animation
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    /*// TODO: implement buildTransitions
    return super.buildTransitions(context, animation, secondaryAnimation, child);*/

    //first route return in app
    if (settings.isInitialRoute) {
      //if that is first route then only show widget
      return child;
    }

    //if it is not first then
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {

  //get different route that load different pages, which will return different values when they are poped of
  @override
  Widget buildTransitions<T> (PageRoute<T> route,BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {

    //first route return in app
    if (route.settings.isInitialRoute) {
      //if that is first route then only show widget
      return child;
    }

    //if it is not first then
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

}
