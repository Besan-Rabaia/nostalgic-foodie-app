import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nostalgic_foodie/widgets/widgets_support.dart';
import 'package:flutter/material.dart';
import 'package:nostalgic_foodie/service/database.dart';
import 'package:image_picker/image_picker.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String>items = ['Ice-cream','Burger','Salad','Pizza','SideDish','Drinks'];
  String? value;
  TextEditingController namecontroller =  TextEditingController();
  TextEditingController pricecontroller =  TextEditingController();
  TextEditingController detailcontroller =  TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    // Using gallery source for all phones
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery
    );


    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }
  uploadItem() async {
    if (selectedImage != null &&
        namecontroller.text != "" &&
        pricecontroller.text != "" &&
        detailcontroller.text != "" &&
        value != null) {
      try {
        String uploadPreset = "food_app";
        var request = http.MultipartRequest(
            'POST',
            Uri.parse('https://api.cloudinary.com/v1_1/fooddeliver/image/upload') // Use this!
        );
        request.fields['upload_preset'] = uploadPreset;

        request.files.add(
            await http.MultipartFile.fromPath('file', selectedImage!.path)
        );

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);

        if (response.statusCode == 200) {
          String downloadUrl = jsonData['secure_url'];

          Map<String, dynamic> addItem = {
            "Image": downloadUrl,
            "Name": namecontroller.text,
            "Price": pricecontroller.text,
            "Detail": detailcontroller.text
          };

          await DatabaseMethods().addFoodItem(addItem, value!).then((result) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.orangeAccent,
                content: Text(
                  "Food Item has been added Successfully",
                  style: TextStyle(fontSize: 18.0),
                )));
          });
        }
      }catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new_outlined, color: Color(0xFF373866),)),
        centerTitle: true,
        title: Text("Add Item",
          style: AppWidget.headlineTextFieldStyle(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin:
            const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Upload the Item Picture",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(height: 20.0,),
                selectedImage ==null?GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: Center(
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined, color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ):Center(
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            selectedImage!, fit: BoxFit.cover,
                          ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text("Item Name",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: namecontroller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Item Name",
                        hintStyle: AppWidget.lightTextFieldStyle()),
                  ),
                ),
                const SizedBox(height: 30),
                Text("Item Price",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: pricecontroller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Item Price",
                        hintStyle: AppWidget.lightTextFieldStyle()),
                  ),
                ),
                const SizedBox(height: 30),
                Text("Item Detail",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    maxLines: 6,
                    controller: detailcontroller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Item Detail",
                        hintStyle: AppWidget.lightTextFieldStyle()),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Select Category",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: MediaQuery.of(context).size.width,
                  decoration:  BoxDecoration(color:const Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items:items
                            .map((item)=> DropdownMenuItem<String>(
                          value: item,
                            child: Text(
                              item,style: const TextStyle(fontSize: 18.0,color: Colors.black),
                            )))
                            .toList(),
                        onChanged:((value)=>setState(() {
                          this.value = value;
                        })),dropdownColor:Colors.white,
                          hint: const Text("Select Category"),iconSize: 36,
                          icon: const Icon(Icons.arrow_drop_down,color:Colors.black),value: value,),),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: (){
                    uploadItem();
                  },
                  child: Center(
                    child: Material(
                      elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        width: 150,
                        decoration: BoxDecoration(color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                          child: Text("Add",style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
