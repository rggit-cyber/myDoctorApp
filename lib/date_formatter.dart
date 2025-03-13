String formatDate(String date) {
  // Extract the parts of the date (assuming it's in "YYYY-MM-DD" format)
  List<String> parts = date.split('-');
  if (parts.length != 3) return date; // Return as is if format is incorrect

  String year = parts[0]; // YYYY
  String month = parts[1]; // MM
  String day = parts[2]; // DD

  // Month mapping
  Map<String, String> monthNames = {
    "01": "January",
    "02": "February",
    "03": "March",
    "04": "April",
    "05": "May",
    "06": "June",
    "07": "July",
    "08": "August",
    "09": "September",
    "10": "October",
    "11": "November",
    "12": "December",
  };

  // Get month name
  String monthName =
      monthNames[month] ?? month; // Default to number if not found

  return "$day $monthName $year"; // Return formatted date
}
