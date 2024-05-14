
// List<int> _getRSSValues() {
//     String mantap = '';
//     if (accessPoints.isEmpty) {
//       print("Empty Wifi List");
//       throw ErrorDescription("WiFi List Empty!");
//     }
//     List<String> apBssid = [
//       // "f8:75:88:c4:c5:a4", //Sibayak
//       // "b6:15:e6:39:b6:59", //SMA IT
//       // "76:cf:18:0b:ae:b9", //Redmi 9
//       // "82:8f:c8:09:86:80", //Note 11
//       // "66:48:4d:10:ae:d5", //Redmi Note 11
//       "b0:4e:26:9f:94:42", //GF I New
//       // "2c:73:a0:0f:01:ae" //UGM-Secure Depan N203
//       // "2c:73:a0:0f:26:ae" //UGM-Secure Lab Eldas
//     ];

//     List<String> test = ["00:13:10:85:fe:01"];
//     // print(apBssid.length);
//     var mantapp = <WiFiAccessPoint>[];
//     var rssValue = <int>[];
//     // print(apBssid[2]);
//     // print(apBssid.length);

//     try {
//       for (int i = 0; i < apBssid.length; i++) {
//         // print("$i ======== mantapp");
//         print(apBssid[i]);
//         mantap = apBssid[i];
//         mantapp.add(
//             secureAPs.firstWhere((element) => element.bssid == apBssid[i]));
//         // accessPoints.firstWhere((element) => element.bssid == test[0]));
//         // print("accesspoints loop");
//       }
//       //TESTING
//       mantapp.add(mantapp[0]);
//       mantapp.add(mantapp[0]);
//       //TESTING
//     } catch (e) {
//       print("error while getting RSS Values");
//       throw Exception(mantap);
//     }

//     // try{
//     //   for(int i = 0; i<accessPoints.length;i++){
//     //     if ()
//     //   }
//     // }catch(e){
//     //   throw Exception (e);
//     // }

//     for (int i = 0; i < 3; i++) {
//       // print(mantapp[i].level);
//       // print("rssValue");
//       rssValue.add(mantapp[i].level);
//       // print(rssValue);
//     }
//     // rssValue = [-58, -56, -67]; //For Testing
//     // print(rssValue);

//     // var testValues = <int>[];
//     // return testValues;
//     return rssValue;
//   }

// Future<List<mrx.Vector>> _countTrila(mrx.Vector p1, mrx.Vector p2,
//       mrx.Vector p3, num r1, num r2, num r3) async {
//     mrx.Vector point1 = mrx.Vector.fromList([0, 0, 0]);
//     mrx.Vector point2 =
//         mrx.Vector.fromList([p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]]);
//     mrx.Vector point3 =
//         mrx.Vector.fromList([p3[0] - p1[0], p3[1] - p1[1], p3[2] - p1[2]]);
//     mrx.Vector v1 = point2 - point1;
//     mrx.Vector v2 = point3 - point1;

//     mrx.Vector xn = (v1) / v1.norm();

//     mrx.Vector tmp = v1.cross(v2);

//     mrx.Vector zn = tmp / tmp.norm();

//     mrx.Vector yn = xn.cross(zn);

//     var i = xn.dot(v2);
//     var d = xn.dot(v1);
//     var j = yn.dot(v2);

//     var x = (pow(r1, 2) - pow(r2, 2) + pow(d, 2)) / (2 * d);
//     var y = ((pow(r1, 2) - pow(r3, 2) + pow(i, 2) + pow(j, 2)) / (2 * j)) -
//         ((i / j) * x);
//     var z1 = sqrt(max(0, pow(r1, 2) - pow(x, 2) - pow(y, 2)));
//     var z2 = -z1;

//     mrx.Vector k1 = p1 + xn * x + yn * y + zn * z1;
//     mrx.Vector k2 = p1 + xn * x + yn * y - zn * z2;

//     // print(k1);
//     // print(k2);

//     return [k1, k2];
//   }