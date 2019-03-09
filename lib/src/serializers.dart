library serializers;

import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_collection/built_collection.dart';
import 'article.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  Article,
])
final Serializers serializers = _$serializers;

final standardSerializers =
    (serializers.toBuilder()..addPlugin(new StandardJsonPlugin())).build();
