import 'dart:ui';

import 'package:fm2/model/enum_class.dart';
class {{enumClassName.pascalCase()}} extends EnumClass{
  {{#enumValues}}
  {{#color}}
  static const {{enumItem}} = {{enumClassName.pascalCase()}}._({{enumVal}}, '{{enumLabel}}', color: {{color}});
  {{/color}}
  {{^color}}
  static const {{enumItem}} = {{enumClassName.pascalCase()}}._({{enumVal}}, '{{enumLabel}}');
  {{/color}}
  {{/enumValues}}
  static const List<{{enumClassName.pascalCase()}}> values = <{{enumClassName.pascalCase()}}>[
    {{#enumValues}}
    {{enumItem}},
    {{/enumValues}}
  ];

  static {{enumClassName.pascalCase()}}? fromValue(int? val){
    int index = values.indexWhere((e) => e.value == val);
    if(index >= 0) return values[index];
    return null;
  }

  const {{enumClassName.pascalCase()}}._(int value, String name, {Color? color}) : super(value, name, color: color);
}
