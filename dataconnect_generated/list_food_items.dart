part of 'generated.dart';

class ListFoodItemsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListFoodItemsVariablesBuilder(this._dataConnect, );
  Deserializer<ListFoodItemsData> dataDeserializer = (dynamic json)  => ListFoodItemsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListFoodItemsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListFoodItemsData, void> ref() {
    
    return _dataConnect.query("ListFoodItems", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListFoodItemsFoodItems {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final Timestamp createdAt;
  ListFoodItemsFoodItems.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  description = nativeFromJson<String>(json['description']),
  price = nativeFromJson<double>(json['price']),
  imageUrl = json['imageUrl'] == null ? null : nativeFromJson<String>(json['imageUrl']),
  category = nativeFromJson<String>(json['category']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListFoodItemsFoodItems otherTyped = other as ListFoodItemsFoodItems;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    description == otherTyped.description && 
    price == otherTyped.price && 
    imageUrl == otherTyped.imageUrl && 
    category == otherTyped.category && 
    createdAt == otherTyped.createdAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, description.hashCode, price.hashCode, imageUrl.hashCode, category.hashCode, createdAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['description'] = nativeToJson<String>(description);
    json['price'] = nativeToJson<double>(price);
    if (imageUrl != null) {
      json['imageUrl'] = nativeToJson<String?>(imageUrl);
    }
    json['category'] = nativeToJson<String>(category);
    json['createdAt'] = createdAt.toJson();
    return json;
  }

  const ListFoodItemsFoodItems({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.createdAt,
  });
}

@immutable
class ListFoodItemsData {
  final List<ListFoodItemsFoodItems> foodItems;
  ListFoodItemsData.fromJson(dynamic json):
  
  foodItems = (json['foodItems'] as List<dynamic>)
        .map((e) => ListFoodItemsFoodItems.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListFoodItemsData otherTyped = other as ListFoodItemsData;
    return foodItems == otherTyped.foodItems;
    
  }
  @override
  int get hashCode => foodItems.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['foodItems'] = foodItems.map((e) => e.toJson()).toList();
    return json;
  }

  const ListFoodItemsData({
    required this.foodItems,
  });
}

