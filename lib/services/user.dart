import 'dart:convert';
import 'package:movie_app/models/response_data_map.dart';
import 'package:movie_app/models/user_login.dart';
import 'package:movie_app/services/url.dart' as url;
import 'package:http/http.dart' as http;


class UserService {
  Future registerUser(data) async {
    var uri = Uri.parse("${url.BaseUrl}/register");
    var register = await http.post(uri, body: data);


    if (register.statusCode == 200) {
      var data = json.decode(register.body);
      if (data["status"] == true) {
        ResponseDataMap response = ResponseDataMap(
            status: true, message: "Sukses menambah user", data: data);
        return response;
      } else {
        var message = '';
        for (String key in data["message"].keys) {
          message += '${data["message"][key][0]}\n';
        }
        ResponseDataMap response =
            ResponseDataMap(status: false, message: message);
        return response;
      }
    } else {
      ResponseDataMap response = ResponseDataMap(
          status: false,
          message:
              "gagal menambah user dengan code error ${register.statusCode}");
      return response;
    }
  }
   Future<ResponseDataMap> loginUser(Map<String, String> data) async {
  var uri = Uri.parse("${url.BaseUrl}/login");
  var register = await http.post(
    uri,
    body: jsonEncode(data),
    headers: {"Content-Type": "application/json"}
  );
  if (register.statusCode == 200) {
    var responseData = json.decode(register.body);

    // Pastikan 'data' ada dalam response
    if (!responseData.containsKey("data") || responseData["data"] == null) {
      print("❌ Error: 'data' tidak ditemukan dalam response!");
      return ResponseDataMap(status: false, message: "Gagal login, data user tidak ditemukan");
    }

    var userData = responseData["data"]; // Ambil data user dari 'data'

    UserLogin userLogin = UserLogin(
      status: responseData["status"],
      token: responseData["authorisation"]["token"], // Ambil token dari authorisation
      message: responseData["message"],
      id: userData["id"], // Ambil ID user dari 'data'
      nama_user: userData["name"],
      email: userData["email"],
      role: userData["role"]
    );

    await userLogin.prefs();
    return ResponseDataMap(status: true, message: "Sukses login user", data: responseData);
  } else {
    return ResponseDataMap(
      status: false,
      message: "Gagal login user dengan error code ${register.statusCode}"
    );

}


}}