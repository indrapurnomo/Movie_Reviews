import 'package:flutter/material.dart';
import '../api_service.dart';

class AddEditReviewScreen extends StatefulWidget {
  final String username;
  final Map<String, dynamic>? review;

  const AddEditReviewScreen({super.key, required this.username, this.review});

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final _titleController = TextEditingController();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  final _apiService = ApiService();
  //tambah image
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _titleController.text = widget.review!['title']??'';
      _ratingController.text = widget.review!['rating'].toString();
      _commentController.text = widget.review!['comment']??'';
      //image
       _imageUrlController.text = widget.review?['imageUrl']??'';
    }
  }

  void _saveReview() async {
    final title = _titleController.text.trim();
    final rating = int.tryParse(_ratingController.text) ?? 0;
    final comment = _commentController.text.trim();
    //image dan like
    final imageUrl = _imageUrlController.text.isNotEmpty ? _imageUrlController.text : widget.review?['imageUrl'] ?? '';
    final likes = widget.review?['likes'] ?? 0; 
    
    //debugging save
    print('Saving Review: {'
    'ID: ${widget.review?["_id"]}, '
    'Title: $title, '
    'Rating: $rating, '
    'Comment: $comment, '
    'ImageURL: $imageUrl, '
    'Likes: $likes}');

    // Validasi input
    if (title.isEmpty || rating < 1 || rating > 10 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tidak valid. Judul, komentar, dan rating (1-10) harus diisi.')),
      );
      return;
    }

    bool success;
    if (widget.review == null) {
      // Tambah review baru
      success = await _apiService.addReview(widget.username, title, rating, comment, imageUrl);
    } else {
      // Edit review --> tambah widget username
      success = await _apiService.updateReview(widget.review!["_id"], widget.username, title, rating, comment, imageUrl, likes);
    }

    if (success) {
      Navigator.pop(context, true); // Berhasil, kembali ke layar sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.review != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Review' : 'Tambah Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Film'),
             // readOnly: isEditMode, // Nonaktifkan input jika dalam mode edit
			),
            TextField(
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Rating (1-10)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Komentar'),
            ),
            //textfile gambar
             TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL Gambar (opsional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReview,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}