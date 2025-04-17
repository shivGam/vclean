import 'package:flutter/material.dart';

class OfferCarousel extends StatefulWidget {
  const OfferCarousel({Key? key}) : super(key: key);

  @override
  _OfferCarouselState createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<OfferCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildOfferCard("Special Summer Offer", "40% OFF"),
              _buildOfferCard("Winter Special", "30% OFF"),
              _buildOfferCard("Weekend Deal", "20% OFF"),
              _buildOfferCard("New User Offer", "50% OFF"),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
                (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF4355B9)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(String title, String discount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage("https://via.placeholder.com/400x200"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  discount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}