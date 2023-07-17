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
    if (val != null) {
      List<{{enumClassName.pascalCase()}}> list = values.where((element) => element.value == val).toList();
      if(list.isNotEmpty){
        return list.first;
      }
    }
    return null;
  }

  const {{enumClassName.pascalCase()}}._(int value, String name, {Color? color}) : super(value, name, color: color);
}