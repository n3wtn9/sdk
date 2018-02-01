// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';

String flutterPkgLibPath = '/packages/flutter/lib';

/**
 * Add some Flutter libraries and types to the given [provider] and return
 * the `lib` folder.
 */
Folder configureFlutterPackage(MemoryResourceProvider provider) {
  File newFile(String path, String content) =>
      provider.newFile(provider.convertPath(path), content ?? '');

  Folder newFolder(String path) =>
      provider.newFolder(provider.convertPath(path));

  newFile('$flutterPkgLibPath/material.dart', r'''
export 'widgets.dart';
export 'src/material/app_bar.dart';
export 'src/material/gesture_detector.dart';
export 'src/material/icons.dart';
export 'src/material/scaffold.dart';
''');

  newFile('$flutterPkgLibPath/widgets.dart', r'''
export 'src/widgets/basic.dart';
export 'src/widgets/center.dart';
export 'src/widgets/container.dart';
export 'src/widgets/framework.dart';
export 'src/widgets/icon.dart';
export 'src/widgets/text.dart';
''');

  void createSrcMaterial() {
    newFile('$flutterPkgLibPath/src/material/app_bar.dart', r'''
import 'package:flutter/widgets.dart';

class AppBar extends StatefulWidget {
  AppBar({
    Key key,
    title,
    backgroundColor,
  });
}
''');

    newFile('$flutterPkgLibPath/src/material/icons.dart', r'''
import 'package:flutter/widgets.dart';

class Icons {
  static const IconData alarm =
      const IconData(0xe855, fontFamily: 'MaterialIcons');
  static const IconData book =
      const IconData(0xe865, fontFamily: 'MaterialIcons');
  Icons._();
}
''');

    newFile('$flutterPkgLibPath/src/material/scaffold.dart', r'''
import 'package:flutter/widgets.dart';

class Scaffold extends StatefulWidget {
  const Scaffold({
    Key key,
    Widget body,
  });
}
''');

    newFile('$flutterPkgLibPath/src/material/gesture_detector.dart', r'''
import 'package:flutter/widgets.dart';

class GestureDetector extends StatelessWidget {
  GestureDetector({
    Key key,
    Widget child,
    onTap,
  });
''');
  }

  void createSrcWidgets() {
    newFile('$flutterPkgLibPath/src/widgets/basic.dart', r'''
import 'framework.dart';

class Center extends StatelessWidget {
  const Center({Widget child, Key key});
}

class Column extends Flex {
  Column({
    Key key,
    List<Widget> children: const <Widget>[],
  });
}

class Row extends Flex {
  Row({
    Key key,
    List<Widget> children: const <Widget>[],
  });
}

class Flex extends Widget {
  Flex({
    Key key,
    List<Widget> children: const <Widget>[],
  });
}

class ClipRect extends SingleChildRenderObjectWidget {
  const ClipRect({Key key, Widget child}) :
    super(key: key, child: child);
    
  /// Does not actually exist in Flutter.
  const ClipRect.rect({Key key, Widget child}) :
    super(key: key, child: child);
}

class Transform extends SingleChildRenderObjectWidget {
  const Transform({
    Key key,
    @required transform,
    origin,
    alignment,
    transformHitTests: true,
    Widget child,
  });
}

class AspectRatio extends SingleChildRenderObjectWidget {
  const AspectRatio({
    Key key,
    @required aspectRatio,
    Widget child,
  });
}
''');

    newFile('$flutterPkgLibPath/src/widgets/container.dart', r'''
import 'framework.dart';

class Container extends StatelessWidget {
  final Widget child;
  Container({
    Key key,
    double width,
    double height,
    this.child,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}
''');

    newFile('$flutterPkgLibPath/src/widgets/framework.dart', r'''
typedef void VoidCallback();

abstract class BuildContext {
  Widget get widget;
}

abstract class Key {
  const factory Key(String value) = ValueKey<String>;

  const Key._();
}

abstract class LocalKey extends Key {
  const LocalKey() : super._();
}

abstract class State<T extends StatefulWidget> {
  BuildContext get context => null;

  T get widget => null;

  Widget build(BuildContext context) {}

  void dispose() {}

  void setState(VoidCallback fn) {}
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget({Key key}) : super(key: key);

  State createState() => null
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({Key key}) : super(key: key);

  Widget build(BuildContext context) => null;
}

class ValueKey<T> extends LocalKey {
  final T value;

  const ValueKey(this.value);
}

class Widget {
  final Key key;

  const Widget({this.key});
}

abstract class SingleChildRenderObjectWidget extends RenderObjectWidget {
  final Widget child;

  const SingleChildRenderObjectWidget({Key key, this.child}) : super(key: key);
}

abstract class RenderObjectWidget extends Widget {
  const RenderObjectWidget({Key key}) : super(key: key);
}
''');

    newFile('$flutterPkgLibPath/src/widgets/icon.dart', r'''
import 'framework.dart';

class Icon extends StatelessWidget {
  final IconData icon;
  const Icon(
    this.icon, {
    Key key,
  })
      : super(key: key);
}

class IconData {
  final int codePoint;
  final String fontFamily;
  const IconData(
    this.codePoint, {
    this.fontFamily,
  });
}
''');

    newFile('$flutterPkgLibPath/src/widgets/text.dart', r'''
import 'framework.dart';

class DefaultTextStyle extends StatelessWidget {
  DefaultTextStyle({Widget child});
}

class Text extends StatelessWidget {
  final String data;
  const Text(
    this.data, {
    Key key,
  })
      : super(key: key);
}
''');
  }

  createSrcMaterial();
  createSrcWidgets();

  return newFolder(flutterPkgLibPath);
}
