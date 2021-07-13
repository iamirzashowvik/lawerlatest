import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:get/get.dart';

class CallX {
  Future<void> _launched;
  Future<void> makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  var lat, lng;
  getLatlangfromSharedpref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    lat = preferences.getDouble('lat');
    lng = preferences.getDouble('lng');
    print(lat);

    // lat = 23.761730;
    // lng = 90.411439;
    calc();
  }

  List<double> lats = [23.763345,23.828059,23.785110,23.746416,23.764000,23.712634,23.854321,23.793674,  23.875541, ];
  List<double> lang = [90.418517,90.419823,90.390065,90.376553,90.361014,90.422795,90.406389,90.410434,90.387360,];
  List<String> phn = ['০১১৯৯৮৮৩৭৩৮','০১১৯৯৮৮৩৬১১','০১১৯৯৮৬৪০২২','০১১৯৯৮৮৩৬২২','০১১৯৯৮৮৩৭৪২','০১১৯৯৮৮৩৭৩১','০১১৯১০০১১৬৬','০১১৯১০০১১৪৪','০১৭১৩৩৭৩১৬০'];
  List<String> station = ['Rampura Police Station','খিলক্ষেত থানা','কাফরুল থানা','ধানমন্ডি থানা','মোহাম্মদপুর থানা',
    'সূত্রাপুর থানা','বিমানবন্দর থানা','গুলশান থানা','উত্তারা পশ্চিম থানা',];

  int i = 0;
  calc() {
    String g = '';
    for (i = 0; i < lats.length; i++) {
      var distance = calculateDistance(lat, lng, lats[i], lang[i]);
      print(distance);
      if (distance < 15.00) {
        g = phn[i];
        Get.snackbar('Calling', station[i]);
        _launched = makePhoneCall('tel:$g');
      }
    }
    if (g == '') {
      g = '999';
      Get.snackbar('Calling', g);
      _launched = makePhoneCall('tel:$g');
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
