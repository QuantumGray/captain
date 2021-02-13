# Captain

*an imperative way to navigate declaratively*

## Placing it in the widget tree

place the `Captain()`widget at the same postition inside your widget tree where your Router or Navigator widget would reside. Best practice is placing the main Router beneath the Material/Cupertino/WidgetsApp like:

````dart

...
    MaterialApp(
        home: Captain(
            pages: ...,
            ...
        ),
    ),

````
---

## Navigate with Captain

Captain supports imperative navigation style by complying to the `Navigator.of(context)` format

Use either:
- `.action(Object actionKey)`for invoking predefined actions that have been registered to the Captain Widget
- `.actionFunc(List<Page> Function(List<Page>))` which takes a List<Page> and returns a List<Page> which will be the new Page stack for the App

### Example

````dart

Navigator.of(context).action("myActionKey");
Navigator.of(context).actionFunc((pageStack) => pageStack..add(pageToAdd));

````
