import 'package:flutter/material.dart';
import '../api_service.dart';
import 'add_edit_review_screen.dart';

class MovieReviewsScreen extends StatefulWidget {
  final String username;

  const MovieReviewsScreen({super.key, required this.username});

  //add get review
  get review => null;

  @override
  _MovieReviewsScreenState createState() => _MovieReviewsScreenState();
}

class _MovieReviewsScreenState extends State<MovieReviewsScreen> {
  final _apiService = ApiService();
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await _apiService.getReviews(widget.username);
    setState(() {
      _reviews = reviews;
    });
  }

//tambahan like
  void _likeReview(String id, int likes) async {
    final updatedLikes = likes + 1;
    final success =
        await _apiService.updateReview(id, '', '', 0, '', '', updatedLikes);
    if (success) {
      print('Review updated successfully!');
      _loadReviews();
    } else {
      print('Failed to update review.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memberi like pada review')),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (ScaffoldMessenger.maybeOf(context) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _deleteReview(String id) async {
    final success = await _apiService.deleteReview(id);
    if (success) {
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Film Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditReviewScreen(username: widget.username),
                ),
              );
              if (result == true) _loadReviews();
            },
          ),
        ],
      ),
      body: _reviews.isEmpty
          ? const Center(child: Text('Belum ada review. Tambahkan sekarang!'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  // images
                  leading: review['imageUrl'] != null
                      ? Image.network(review['imageUrl'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                  title: Text(review['title']),
                  subtitle:
                      Text('${review['rating']} / 10\n${review['comment']}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //tampilkan jumlah like
                      Text(
                          '${review['likes'] ?? 0}'), // Menampilkan jumlah likes
                      // tombol like
                      IconButton(
                        icon: const Icon(Icons.thumb_up),
                        onPressed: () async {
                          final reviewId = review["_id"];
                          if (reviewId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('ID ulasan tidak valid')),
                            );
                            return;
                          }

                          final newLikes =
                              await _apiService.likeReview(reviewId);

                          if (newLikes != null) {
                            setState(() {
                              _reviews[index]['likes'] =
                                  newLikes; // Update jumlah likes di UI
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Berhasil memberi like')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Gagal memberi like pada review')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditReviewScreen(
                                username: widget.username,
                                review: review,
                              ),
                            ),
                          );
                          if (result == true) _loadReviews();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteReview(review['_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
