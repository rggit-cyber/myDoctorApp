import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String doctorId;
  final String slot; // Slot format: "YYYY-MM-DD HH:MM"

  const BookingPage({required this.doctorId, required this.slot});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool isChecked = false; // Checkbox state
  String doctorName = "Dr. Unknown"; // Placeholder for doctor name
  String selectedDate = ""; // Extracted Date
  String selectedTime = ""; // Extracted Time

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();

  String gender = "Male";
  String bloodGroup = "";
  String selectedInsurance = "None";

  final List<String> bloodGroups = [
    "A+",
    "O+",
    "B+",
    "AB+",
    "A-",
    "O-",
    "B-",
    "AB-"
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
    _extractDateTime();
  }

  //Zip code validation
  bool isValidZip(String zip) {
    return RegExp(r'^[1-9][0-9]{5}$').hasMatch(zip);
  }
  //Zip code validation

  //Insurance
  void _showInsurancePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Insurance Criteria"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _insuranceRadio("Biju Swasthya Kalyan Yojana (BSKY)"),
              _insuranceRadio("Gopabandhu Jan Arogya Yojana (GJAY)"),
              _insuranceRadio(
                  "Ayushman Bharat Pradhan Mantri Jan Arogya Yojana (AB PM-JAY)"),
              _insuranceRadio("None"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _insuranceRadio(String value) {
    return RadioListTile(
      title: Text(value),
      value: value,
      groupValue: selectedInsurance,
      onChanged: (val) {
        setState(() {
          selectedInsurance = val.toString();
        });
        Navigator.pop(context);
      },
    );
  }
  //Insurance

  // Fetch Doctor Name from Firestore
  void _fetchDoctorDetails() async {
    var doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .get();
    if (doc.exists) {
      setState(() => doctorName = doc['name'] ?? "Dr. Unknown");
    }
  }

  // Extract Date and Time from slot
  void _extractDateTime() {
    try {
      List<String> parts = widget.slot.split(" ");
      if (parts.length == 2) {
        DateTime date = DateFormat("yyyy-MM-dd").parse(parts[0]);
        String formattedDate = DateFormat("dd MMMM yyyy, EEEE").format(date);

        setState(() {
          selectedDate = formattedDate;
          selectedTime = parts[1];
        });
      } else {
        setState(() {
          selectedDate = "Invalid Date Format";
          selectedTime = "";
        });
      }
    } catch (e) {
      setState(() {
        selectedDate = "Invalid Date";
        selectedTime = "";
      });
      print("Error parsing date: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Confirm Booking",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent, // AppBar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Details Section
              Text("Doctor Name: $doctorName",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Doctor ID: ${widget.doctorId}",
                  style: TextStyle(fontSize: 16)),
              Text("Selected Date: $selectedDate",
                  style: TextStyle(fontSize: 16)),
              Text("Selected Time: $selectedTime",
                  style: TextStyle(fontSize: 16)),

              SizedBox(height: 20),

              // Patient Information Section
              Text("Patient Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name")),
              TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Age")),

              Text("Gender",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio(
                      value: "Male",
                      groupValue: gender,
                      onChanged: (value) => setState(() => gender = value!)),
                  Text("Male"),
                  Radio(
                      value: "Female",
                      groupValue: gender,
                      onChanged: (value) => setState(() => gender = value!)),
                  Text("Female"),
                  Radio(
                      value: "Other",
                      groupValue: gender,
                      onChanged: (value) => setState(() => gender = value!)),
                  Text("Other"),
                ],
              ),

              TextField(
                controller: bloodGroupController, // Use controller
                decoration: InputDecoration(labelText: "Blood Group"),
                onChanged: (input) {
                  String match = bloodGroups.firstWhere(
                      (bg) => bg.toLowerCase().startsWith(input.toLowerCase()),
                      orElse: () => "");
                  setState(() {
                    bloodGroup = match;
                    bloodGroupController.text =
                        match; // Autofill the selected blood group
                  });
                },
              ),

// Show dropdown only if a match exists
              if (bloodGroup.isNotEmpty)
                DropdownButton<String>(
                  value: bloodGroups.contains(bloodGroup) ? bloodGroup : null,
                  items: bloodGroups
                      .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      bloodGroup = value!;
                      bloodGroupController.text =
                          value; // Autofill when selected
                    });
                  },
                ),

              TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(labelText: "Phone Number")),

              SizedBox(height: 10),
              Text("Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                  controller: cityController,
                  decoration: InputDecoration(labelText: "City")),
              TextField(
                  controller: stateController,
                  decoration: InputDecoration(labelText: "State")),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: zipController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: "Zip Code",
                        errorText: isValidZip(zipController.text)
                            ? null
                            : "Invalid ZIP Code",
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Space between TextField and Button
                  ElevatedButton(
                    onPressed: () {
                      if (isValidZip(zipController.text)) {
                        print("ZIP Code is valid: ${zipController.text}");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Valid ZIP Code")),
                        );
                      } else {
                        print("Invalid ZIP Code!");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Please enter a valid ZIP code")),
                        );
                      }
                    },
                    child: Text("Verify"),
                  ),
                ],
              ),

              SizedBox(height: 10),
              GestureDetector(
                onTap: _showInsurancePopup,
                child: InputDecorator(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Insurance Criteria"),
                  child:
                      Text(selectedInsurance, style: TextStyle(fontSize: 16)),
                ),
              ),

              SizedBox(height: 20),

              // Terms & Conditions Section
              Text("Terms & Conditions:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("* You must carry a valid ID proof during the visit.",
                  style: TextStyle(fontSize: 14)),
              Text(
                  "* Cancellation or rescheduling is allowed up to 24 hours before the appointment.",
                  style: TextStyle(fontSize: 14)),
              Text(
                  "* Late arrival beyond 15 minutes may lead to appointment cancellation.",
                  style: TextStyle(fontSize: 14)),
              Text(
                  "* Consultation fees are non-refundable after the session starts.",
                  style: TextStyle(fontSize: 14)),

              SizedBox(height: 20),

              // Checkbox for Terms & Conditions
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      "I agree to the Terms & Conditions",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Proceed to Payment Button
              // Sticky Bottom Payment Button
              Container(
                width: double.infinity, // Full width
                padding: EdgeInsets.all(16),
                color: Colors.white, // Background color
                child: ElevatedButton(
                  onPressed: isChecked
                      ? () => _saveBooking(context)
                      : null, // Disabled if checkbox is unchecked
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Proceed to Payment",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBooking(BuildContext context) async {
    // Booking logic...
  }
}
