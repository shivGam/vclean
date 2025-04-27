import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/model/carousel_data.dart';
import '../bloc/carousel_bloc.dart';

class AddCarouselScreen extends StatefulWidget {
  @override
  _AddCarouselScreenState createState() => _AddCarouselScreenState();
}

class _AddCarouselScreenState extends State<AddCarouselScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _discountController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _textColor = 'FFFFFF'; // Default white text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Offer'),
      ),
      body: BlocListener<CarouselBloc, CarouselState>(
        listener: (context, state) {
          if (state is CarouselOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context); // Go back after successful save
          } else if (state is CarouselError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Offer Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _discountController,
                  decoration: InputDecoration(labelText: 'Discount (e.g., 25% OFF)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter discount information';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _textColor,
                  decoration: InputDecoration(labelText: 'Text Color'),
                  items: [
                    DropdownMenuItem(value: 'FFFFFF', child: Text('White')),
                    DropdownMenuItem(value: '000000', child: Text('Black')),
                    DropdownMenuItem(value: 'FFFF00', child: Text('Yellow')),
                    DropdownMenuItem(value: 'FF0000', child: Text('Red')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _textColor = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final carousel = Carousel(
                        title: _titleController.text,
                        discount: _discountController.text,
                        image: _imageUrlController.text,
                        textColor: _textColor,
                      );

                      context.read<CarouselBloc>().add(SaveCarousel(carousel));
                    }
                  },
                  child: Text('Save Offer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}