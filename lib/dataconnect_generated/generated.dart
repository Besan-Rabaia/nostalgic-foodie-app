library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_food_item.dart';

part 'list_food_items.dart';

part 'create_user.dart';

part 'get_user.dart';







class ExampleConnector {
  
  
  CreateFoodItemVariablesBuilder createFoodItem ({required String category, required Timestamp createdAt, required String description, required String name, required double price, }) {
    return CreateFoodItemVariablesBuilder(dataConnect, category: category,createdAt: createdAt,description: description,name: name,price: price,);
  }
  
  
  ListFoodItemsVariablesBuilder listFoodItems () {
    return ListFoodItemsVariablesBuilder(dataConnect, );
  }
  
  
  CreateUserVariablesBuilder createUser ({required Timestamp createdAt, required String email, required String username, }) {
    return CreateUserVariablesBuilder(dataConnect, createdAt: createdAt,email: email,username: username,);
  }
  
  
  GetUserVariablesBuilder getUser ({required String id, }) {
    return GetUserVariablesBuilder(dataConnect, id: id,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'ecommerceapp',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
