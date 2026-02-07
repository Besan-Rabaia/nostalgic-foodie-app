part of 'generated.dart';

class CreateUserVariablesBuilder {
  final Optional<String> _address = Optional.optional(nativeFromJson, nativeToJson);
  Timestamp createdAt;
  String email;
  final Optional<String> _phoneNumber = Optional.optional(nativeFromJson, nativeToJson);
  String username;

  final FirebaseDataConnect _dataConnect;
  CreateUserVariablesBuilder address(String? t) {
   _address.value = t;
   return this;
  }
  CreateUserVariablesBuilder phoneNumber(String? t) {
   _phoneNumber.value = t;
   return this;
  }

  CreateUserVariablesBuilder(this._dataConnect, {required  this.createdAt,required  this.email,required  this.username,});
  Deserializer<CreateUserData> dataDeserializer = (dynamic json)  => CreateUserData.fromJson(jsonDecode(json));
  Serializer<CreateUserVariables> varsSerializer = (CreateUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateUserData, CreateUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateUserData, CreateUserVariables> ref() {
    CreateUserVariables vars= CreateUserVariables(address: _address,createdAt: createdAt,email: email,phoneNumber: _phoneNumber,username: username,);
    return _dataConnect.mutation("CreateUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateUserUserInsert {
  final String id;
  CreateUserUserInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserUserInsert otherTyped = other as CreateUserUserInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateUserUserInsert({
    required this.id,
  });
}

@immutable
class CreateUserData {
  final CreateUserUserInsert user_insert;
  CreateUserData.fromJson(dynamic json):
  
  user_insert = CreateUserUserInsert.fromJson(json['user_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserData otherTyped = other as CreateUserData;
    return user_insert == otherTyped.user_insert;
    
  }
  @override
  int get hashCode => user_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_insert'] = user_insert.toJson();
    return json;
  }

  const CreateUserData({
    required this.user_insert,
  });
}

@immutable
class CreateUserVariables {
   Optional<String>address;
  final Timestamp createdAt;
  final String email;
   Optional<String>phoneNumber;
  final String username;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateUserVariables.fromJson(Map<String, dynamic> json, this.address, this.phoneNumber):
  
  createdAt = Timestamp.fromJson(json['createdAt']),
  email = nativeFromJson<String>(json['email']),
  username = nativeFromJson<String>(json['username']) {
  
  
    address = Optional.optional(nativeFromJson, nativeToJson);
    address.value = json['address'] == null ? null : nativeFromJson<String>(json['address']);
  
  
  
  
    phoneNumber = Optional.optional(nativeFromJson, nativeToJson);
    phoneNumber.value = json['phoneNumber'] == null ? null : nativeFromJson<String>(json['phoneNumber']);
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserVariables otherTyped = other as CreateUserVariables;
    return address == otherTyped.address && 
    createdAt == otherTyped.createdAt && 
    email == otherTyped.email && 
    phoneNumber == otherTyped.phoneNumber && 
    username == otherTyped.username;
    
  }
  @override
  int get hashCode => Object.hashAll([address.hashCode, createdAt.hashCode, email.hashCode, phoneNumber.hashCode, username.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if(address.state == OptionalState.set) {
      json['address'] = address.toJson();
    }
    json['createdAt'] = createdAt.toJson();
    json['email'] = nativeToJson<String>(email);
    if(phoneNumber.state == OptionalState.set) {
      json['phoneNumber'] = phoneNumber.toJson();
    }
    json['username'] = nativeToJson<String>(username);
    return json;
  }

   CreateUserVariables({
    required this.address,
    required this.createdAt,
    required this.email,
    required this.phoneNumber,
    required this.username,
  });
}

