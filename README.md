# Introduction
This package provides a flexible bottom sheet, built on top of the flutter_appbar package, that syncs with scroll events instead of relying only on gestures.

## Preview
The gif image below may appear distorted and choppy due to compression.

![preview](https://github.com/user-attachments/assets/8d61d51f-249a-4fd6-802c-32c1a04f10c6)

## Usage
This section covers the basic usage of this package and how to integrate it into your application.

### How to open?
To open a bottom sheet, use the `BottomSheet.open` method with a vertically Scrollable widget like ListView.

> [!NOTE]
> The bottom sheet requires a vertically scrollable widget inside to function properly. Without one, it may not behave as expected.

```dart
BottomSheet.open(context, ListView.builder(
    padding: EdgeInsets.all(20),
    itemCount: 100,
    itemBuilder: (context, index) {
        return Text("Hello, World!");
    },
));
```

### How to close?
To close the currently open bottom sheet, use the BottomSheet.close method with the same BuildContext.

```dart
BottomSheet.close(context);
```

### How to customize?
You can customize the behavior and appearance of the bottom sheet by setting the global `BottomSheet.config` before calling `open`. This includes initial height, fade animation, color, and layout wrapper.

```dart
BottomSheet.config = BottomSheetConfig(
    initialFraction: 0.6,
    fadeInDuration: Duration(seconds: 1),
    fadeInCurve: Curves.ease,
    barrierColor: Colors.red,
    builder: ...
);
```