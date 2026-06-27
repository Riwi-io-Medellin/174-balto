import '../domain/entities/walker.dart';

const List<Walker> kMockWalkers = [
  Walker(
    name: 'Ana García',
    rating: 4.8,
    reviews: 2300,
    description:
        'Professional walker since 2020. Energetic breeds and long hikes. Your pets deserve the best!',
    distance: 0.5,
    imageUrl: 'https://picsum.photos/seed/walker_ana/800/400',
    priceLabel: '\$10/walk',
    topRated: true,
  ),
  Walker(
    name: 'Carlos López',
    rating: 4.6,
    reviews: 1200,
    description:
        'Experienced with multiple dog breeds and personalities. Safety is always my top priority.',
    distance: 1.2,
    imageUrl: 'https://picsum.photos/seed/walker_carlos/800/400',
    priceLabel: '\$15/walk',
    topRated: false,
  ),
  Walker(
    name: 'María Torres',
    rating: 4.9,
    reviews: 3100,
    description:
        'Certified pet first-aid. I treat every dog like my own. Available weekends and evenings.',
    distance: 0.8,
    imageUrl: 'https://picsum.photos/seed/walker_maria/800/400',
    priceLabel: '\$12/walk',
    topRated: true,
  ),
];
