part of 'generated.dart';

class CreateFoodItemVariablesBuilder {
  String category;
  Timestamp createdAt;
  String description;
  final Optional<String> _imageUrl = Optional.optional(nativeFromJson, nativeToJson);
  String name;
  double price;

  final FirebaseDataConnect _dataConnect;  CreateFoodItemVariablesBuilder imageUrl(String? t) {
   _imageUrl.value = t;
   return this;
  }

  CreateFoodItemVariablesBuilder(this._dataConnect, {required  this.category,required  this.createdAt,required  this.description,required  this.name,required  this.price,});
  Deserializer<CreateFoodItemData> dataDeserializer = (dynamic json)  => CreateFoodItemData.fromJson(jsonDecode(json));
  Serializer<CreateFoodItemVariables> varsSerializer = (CreateFoodItemVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateFoodItemData, CreateFoodItemVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateFoodItemData, CreateFoodItemVariables> ref() {
    CreateFoodItemVariables vars= CreateFoodItemVariables(category: category,createdAt: createdAt,description: description,imageUrl: _imageUrl,name: name,price: price,);
    return _dataConnect.mutation("CreateFoodItem", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateFoodItemFoodItemInsert {
  final String id;
  CreateFoodItemFoodItemInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateFoodItemFoodItemInsert otherTyped = other as CreateFoodItemFoodItemInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateFoodItemFoodItemInsert({
    required this.id,
  });
}

@immutable
class CreateFoodItemData {
  final CreateFoodItemFoodItemInsert fooditem_insert;
  CreateFoodItemData.fromJson(dynamic json):
        fooditem_insert = CreateFoodItemFoodItemInsert.fromJson(json['foodItem_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateFoodItemData otherTyped = other as CreateFoodItemData;
    return fooditem_insert == otherTyped.fooditem_insert;
    
  }
  @override
  int get hashCode => fooditem_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['foodItem_insert'] = fooditem_insert.toJson();
    return json;
  }

   const CreateFoodItemData({
    required this.fooditem_insert,
  });
}

@immutable
class CreateFoodItemVariables {
  final String category;
  final Timestamp createdAt;
  final String description;
  Optional<String>imageUrl;
  final String name;
  final double price;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateFoodItemVariables.fromJson(Map<String, dynamic> json, {required this.imageUrl}):
  
  category = nativeFromJson<String>(json['category']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  description = nativeFromJson<String>(json['description']),
  name = nativeFromJson<String>(json['name']),
  price = nativeFromJson<double>(json['price']) {
  
  
  
  
  
    imageUrl = Optional.optional(nativeFromJson, nativeToJson);
    imageUrl.value = json['imageUrl'] == null ? null : nativeFromJson<String>(json['imageUrl']);
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateFoodItemVariables otherTyped = other as CreateFoodItemVariables;
    return category == otherTyped.category && 
    createdAt == otherTyped.createdAt && 
    description == otherTyped.description && 
    imageUrl == otherTyped.imageUrl && 
    name == otherTyped.name && 
    price == otherTyped.price;
    
  }
  @override
  int get hashCode => Object.hashAll([category.hashCode, createdAt.hashCode, description.hashCode, imageUrl.hashCode, name.hashCode, price.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['category'] = nativeToJson<String>(category);
    json['createdAt'] = createdAt.toJson();
    json['description'] = nativeToJson<String>(description);
    if(imageUrl.state == OptionalState.set) {
      json['imageUrl'] = imageUrl.toJson();
    }
    json['name'] = nativeToJson<String>(name);
    json['price'] = nativeToJson<double>(price);
    return json;
  }

   CreateFoodItemVariables({
    required this.category,
    required this.createdAt,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
  });
}

