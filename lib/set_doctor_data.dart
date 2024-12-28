import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addDoctorData() async {
  final doctorData = {
    "doctorId": "1",
    "name": "Dr. John Doe",
    "specialization": "Cardiologist",
    "experience_years": 15,
    "availability": {
      "slots": [
        "2024-12-30 10:00 AM",
        "2024-12-30 11:00 AM",
        "2024-12-31 02:00 PM"
      ]
    }
  };

  await FirebaseFirestore.instance
      .collection('doctors')
      .doc('doctor1') // Replace 'doctor1' with a unique ID for each doctor
      .set(doctorData);
}
