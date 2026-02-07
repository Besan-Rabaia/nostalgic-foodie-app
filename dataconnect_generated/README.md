# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### ListFoodItems
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listFoodItems().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListFoodItemsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listFoodItems();
ListFoodItemsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listFoodItems().ref();
ref.execute();

ref.subscribe(...);
```


### GetUser
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getUser(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetUserData, GetUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getUser(
  id: id,
);
GetUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getUser(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CreateFoodItem
#### Required Arguments
```dart
String category = ...;
Timestamp createdAt = ...;
String description = ...;
String name = ...;
double price = ...;
ExampleConnector.instance.createFoodItem(
  category: category,
  createdAt: createdAt,
  description: description,
  name: name,
  price: price,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreateFoodItem, we created `CreateFoodItemBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateFoodItemVariablesBuilder {
  ...
   CreateFoodItemVariablesBuilder imageUrl(String? t) {
   _imageUrl.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createFoodItem(
  category: category,
  createdAt: createdAt,
  description: description,
  name: name,
  price: price,
)
.imageUrl(imageUrl)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreateFoodItemData, CreateFoodItemVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createFoodItem(
  category: category,
  createdAt: createdAt,
  description: description,
  name: name,
  price: price,
);
CreateFoodItemData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String category = ...;
Timestamp createdAt = ...;
String description = ...;
String name = ...;
double price = ...;

final ref = ExampleConnector.instance.createFoodItem(
  category: category,
  createdAt: createdAt,
  description: description,
  name: name,
  price: price,
).ref();
ref.execute();
```


### CreateUser
#### Required Arguments
```dart
Timestamp createdAt = ...;
String email = ...;
String username = ...;
ExampleConnector.instance.createUser(
  createdAt: createdAt,
  email: email,
  username: username,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreateUser, we created `CreateUserBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateUserVariablesBuilder {
  ...
 
  CreateUserVariablesBuilder address(String? t) {
   _address.value = t;
   return this;
  }
  CreateUserVariablesBuilder phoneNumber(String? t) {
   _phoneNumber.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createUser(
  createdAt: createdAt,
  email: email,
  username: username,
)
.address(address)
.phoneNumber(phoneNumber)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreateUserData, CreateUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createUser(
  createdAt: createdAt,
  email: email,
  username: username,
);
CreateUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
Timestamp createdAt = ...;
String email = ...;
String username = ...;

final ref = ExampleConnector.instance.createUser(
  createdAt: createdAt,
  email: email,
  username: username,
).ref();
ref.execute();
```

