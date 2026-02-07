import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:nostalgic_foodie/pages/bottom_nav.dart';
import 'package:nostalgic_foodie/service/database.dart';
import 'package:nostalgic_foodie/service/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CheckoutPage extends StatefulWidget {
  final String total;
  const CheckoutPage({super.key, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? name, email, id;
  TextEditingController addressController = TextEditingController();
  TextEditingController flatController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  String selectedPayment = "Card";
  String fullPhoneNumber = "";
  bool isLeaveAtDoor = false;
  bool _isLoading = false;
  bool _isLocating = false;
  int codFee = 0;

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  getthesharedpref() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    id = currentUser?.uid ?? await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserName();
    email = currentUser?.email ?? await SharedPreferenceHelper().getUserEmail();

    if (id != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(id).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          name = name ?? data["Name"] ?? "";
          email = email ?? data["Email"] ?? "";

          // --- AUTO-FILL SAVED DATA ---
          addressController.text = data["SavedAddress"] ?? "";
          flatController.text = data["SavedFlat"] ?? "";
          fullPhoneNumber = data["SavedPhone"] ?? "";

          // --- AUTO-FILL CARD (EXCEPT CVV) ---
          cardNumberController.text = data["SavedCardNumber"] ?? "";
          expiryController.text = data["SavedExpiry"] ?? "";
          // cvvController.text stays empty for security!
        });
      }
    }
    setState(() {});
  }

  // --- LOCATION PERMISSION LOGIC ---
  Future<void> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location services are disabled.")));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permissions denied.")));
        return;
      }
    }
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    setState(() => _isLocating = true);
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        addressController.text = "${place.street}, ${place.subLocality}, ${place.locality}";
        _isLocating = false;
      });
    } catch (e) {
      setState(() => _isLocating = false);
    }
  }

  void _submitOrder(int finalTotal) async {
    // Basic validation
    if (addressController.text.isEmpty || fullPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill address and phone number")));
      return;
    }

    // Card validation
    if (selectedPayment == "Card" && (cardNumberController.text.isEmpty || cvvController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter full card details and CVV")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String uniqueOrderNumber = "${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond.toString().substring(0, 1)}";
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance.collection("users").doc(id).collection("Cart").get();

      List<Map<String, dynamic>> itemsOrdered = cartSnapshot.docs.map((doc) => {
        "Name": doc["Name"],
        "Quantity": doc["Quantity"],
        "Total": doc["Total"],
      }).toList();

      // --- PERMANENTLY SAVE DETAILS TO FIRESTORE ---
      await FirebaseFirestore.instance.collection("users").doc(id).update({
        "SavedAddress": addressController.text,
        "SavedFlat": flatController.text,
        "SavedPhone": fullPhoneNumber,
        "SavedCardNumber": cardNumberController.text, // Encrypt in production!
        "SavedExpiry": expiryController.text,
        // We NEVER save the CVV to Firebase
      });

      Map<String, dynamic> orderInfo = {
        "OrderNumber": uniqueOrderNumber,
        "Address": "${addressController.text}, Flat: ${flatController.text}",
        "Amount": finalTotal.toString(),
        "Email": email,
        "Status": "In Progress",
        "UserId": id,
        "Payment": selectedPayment,
        "Phone": fullPhoneNumber,
        "Items": itemsOrdered,
        "LeaveAtDoor": isLeaveAtDoor,
        "Time": DateTime.now().toString(),
        "hasRated": false,
      };

      await DatabaseMethods().placeOrder(orderInfo);
      await DatabaseMethods().clearCart(id!);
      _success();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAmount = int.parse(widget.total) + codFee;

    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            _sectionLabel("Delivery Address"),
            _whiteCard(
                child: Column(children: [
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: "Street / Location",
                      border: InputBorder.none,
                      icon: const Icon(Icons.location_on),
                      suffixIcon: _isLocating
                          ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                          : IconButton(icon: const Icon(Icons.my_location, color: Colors.blue), onPressed: _handleLocationPermission),
                    ),
                  ),
                  const Divider(),
                  TextField(controller: flatController, decoration: const InputDecoration(hintText: "Flat / Villa", border: InputBorder.none, icon: Icon(Icons.apartment))),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Leave at my door"),
                    Switch(
                        value: isLeaveAtDoor,
                        onChanged: (v) => setState(() {
                          isLeaveAtDoor = v;
                          if (v) {
                            selectedPayment = "Card";
                            codFee = 0;
                          }
                        })),
                  ]),
                ])),
            _sectionLabel("Receiver Details"),
            _whiteCard(
                child: Column(children: [
                  _detailRow("Customer", name != null && name!.isNotEmpty ? name! : "Loading..."),
                  const Divider(),
                  _detailRow("Email", email != null && email!.isNotEmpty ? email! : "Loading..."),
                  const SizedBox(height: 15),
                  IntlPhoneField(
                    key: Key(fullPhoneNumber),
                    initialCountryCode: 'AE',
                    initialValue: (fullPhoneNumber.isNotEmpty && fullPhoneNumber.contains('+971')) ? fullPhoneNumber.replaceFirst('+971', '') : fullPhoneNumber,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    onChanged: (phone) {
                      fullPhoneNumber = phone.completeNumber;
                    },
                  ),
                ])),
            _sectionLabel("Payment Method"),
            _paymentTile("Card", Icons.credit_card, Colors.blue, "Credit Card"),
            if (selectedPayment == "Card")
              _whiteCard(
                  child: Column(children: [
                    // --- CARD NUMBER FIELD ---
                    TextField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Allow only numbers
                        CardNumberFormatter(), // Add our dash formatter
                      ],
                      decoration: const InputDecoration(hintText: "0000-0000-0000-0000", border: InputBorder.none),
                    ),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: expiryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ExpiryDateFormatter(), // Add our slash formatter
                          ],
                          decoration: const InputDecoration(hintText: "MM/YY", border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(width: 10, child: VerticalDivider()),
                      Expanded(child: TextField(controller: cvvController, keyboardType: TextInputType.number, obscureText: true, decoration: const InputDecoration(hintText: "CVV", border: InputBorder.none))),
                    ]),
                  ])),
            _paymentTile("COD", Icons.money, Colors.green, "Cash on Delivery", enabled: !isLeaveAtDoor),
            _sectionLabel("Summary"),
            _whiteCard(
                child: Column(children: [
                  _summaryRow("Subtotal", "AED ${widget.total}"),
                  if (selectedPayment == "COD") _summaryRow("COD Fee", "AED 5"),
                  const Divider(),
                  _summaryRow("Total Pay", "AED $totalAmount", bold: true),
                ])),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
        child: SafeArea(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Pay", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("AED $totalAmount", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: _isLoading ? null : () => _submitOrder(totalAmount),
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("PLACE ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ]),
        ),
      ),
    );
  }

  void _success() => showDialog(context: context, builder: (c) => AlertDialog(title: const Text("Success"), content: const Text("Order placed!"), actions: [TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const BottomNav()), (r) => false), child: const Text("OK"))]));
  Widget _sectionLabel(String t) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Align(alignment: Alignment.centerLeft, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold))));
  Widget _whiteCard({required Widget child}) => Container(margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: child);
  Widget _detailRow(String l, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]);
  Widget _summaryRow(String l, String v, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)), Text(v, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 14))]));
  Widget _paymentTile(String v, IconData i, Color c, String t, {bool enabled = true}) => RadioListTile<String>(value: v, groupValue: selectedPayment, onChanged: enabled ? (val) => setState(() { selectedPayment = val!; codFee = val == "COD" ? 5 : 0; }) : null, title: Row(children: [Icon(i, color: c), const SizedBox(width: 10), Text(t)]));
}
// Formats card number: 1234-5678-9012-3456
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('-', '');
    if (text.length > 16) text = text.substring(0, 16);
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('-');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 1) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}