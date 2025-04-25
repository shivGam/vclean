import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/review_bloc.dart';
import '../components/star_rating.dart';
import '../constants/colors.dart';
import '../data/model/review_data.dart';
import '../data/model/user_data.dart';

class ReviewScreen extends StatefulWidget {
  final UserData userData;

  const ReviewScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentController = TextEditingController();
  double _rating = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(LoadReviews());
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Clear form if review was added successfully
            if (state.message.contains('added')) {
              _commentController.clear();
              setState(() {
                _rating = 0;
              });
            }
          } else if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add review form
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Write a Review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Rating: '),
                          StarRating(
                            rating: _rating,
                            onRatingChanged: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Share your experience...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your review';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_rating == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a rating')),
                              );
                              return;
                            }

                            final review = Review(
                              userId: widget.userData.userId,
                              comment: _commentController.text,
                              rating: _rating,
                            );

                            context.read<ReviewBloc>().add(AddReview(review));
                          }
                        },
                        child: const Text('Submit Review'),
                      ),
                    ],
                  ),
                ),
              ),

              // Divider between form and reviews list
              const Divider(thickness: 1),

              // Reviews list
              Expanded(
                child: _buildReviewsList(state,widget.userData),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewsList(ReviewState state,UserData userdata) {
    if (state is ReviewLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ReviewsLoaded) {
      final reviews = state.reviews;

      if (reviews.isEmpty) {
        return const Center(child: Text('No reviews yet. Be the first to review!'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          final dateFormat = DateFormat('MMM d, yyyy');
          final formattedDate = dateFormat.format(review.timestamp);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        backgroundImage: userdata.photoUrl.isNotEmpty ? NetworkImage(userdata.photoUrl) : null,
                        child: userdata.photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 16,),
                      Text(
                        userdata.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StarRating(
                        rating: review.rating,
                        size: 20,
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: const TextStyle(fontSize: 16),
                  ),

                  // Show delete option if the review belongs to the current user
                  if (review.userId == widget.userData.userId)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Show confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Review'),
                                content: const Text('Are you sure you want to delete your review?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.read<ReviewBloc>().add(DeleteReview(review.userId));
                                    },
                                    child: const Text('Delete'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 4),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Default state or error state
    return const Center(child: Text('Something went wrong. Please try again.'));
  }
}