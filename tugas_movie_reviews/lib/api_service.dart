import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://crudcrud.com/api/a6bbc3a2daee4b188f4ea77e8bed07';

  Future<bool> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        return users.any((user) => user['username'] == username);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        return users.any((user) =>
            user['username'] == username && user['password'] == password);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getReviews(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews'));
      if (response.statusCode == 200) {
        final List reviews = jsonDecode(response.body);
        return reviews
            .where((review) => review['username'] == username)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addReview(String username, String title, int rating,
      String comment, String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'title': title,
          'rating': rating,
          'comment': comment,
          'imageUrl': imageUrl,
          'likes': 0,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  Future<bool> updateReview(String id, String username, String title, int rating, String comment, String imageUrl, int likes) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
		  'title': title,
          'rating': rating,
          'comment': comment,
          'imageUrl': imageUrl,
          'likes': likes,
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/reviews/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

//   Future<bool> likeReview(String reviewId) async {
//   try {
//     // Ambil data review dari server
//     final response = await http.get(Uri.parse('$baseUrl/reviews/$reviewId'));
//     if (response.statusCode == 200) {
//       final review = jsonDecode(response.body);

//       // Tambah 1 pada likes
//       final newLikes = (review['likes'] ?? 0) + 1;

//       // Kirim semua data yang ada (pastikan semua properti tetap)
//       final updateResponse = await http.put(
//         Uri.parse('$baseUrl/reviews/$reviewId'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': review['username'], // Pertahankan username
//           'title': review['title'],      // Pertahankan judul
//           'rating': review['rating'],    // Pertahankan rating
//           'comment': review['comment'],  // Pertahankan komentar
//           'imageUrl': review['imageUrl'], // Pertahankan URL gambar
//           'likes': newLikes,             // Update likes
//         }),
//       );
//       return updateResponse.statusCode == 200;
//     }
//     return false;
//   } catch (e) {
//     print('Error liking review: $e');
//     return false;
//   }
// }
 Future<bool> likeReview(String reviewId) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/reviews/$reviewId'));
    if (response.statusCode == 200) {
      final review = jsonDecode(response.body);

 // Pastikan review memiliki data yang diperlukan
      if (review == null || review['_id'] == null) {
        print('Error: Review data is invalid.');
        return false;
      }

      final newLikes = (review['likes'] ?? 0) + 1;

      final updateResponse = await http.put(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          '_id': review['_id'],
          'username': review['username'],
          'title': review['title'],
          'rating': review['rating'],
          'comment': review['comment'],
          'imageUrl': review['imageUrl'],
          'likes': newLikes,
        }),
      );

      print('Update Response Status Code: ${updateResponse.statusCode}');
      print('Update Response Body: ${updateResponse.body}');

      return updateResponse.statusCode == 200;
    } else {
      print('Failed to fetch review with ID: $reviewId');
      return false;
    }
  } catch (e) {
    print('Error liking review: $e');
    return false;
  }
}

  }












