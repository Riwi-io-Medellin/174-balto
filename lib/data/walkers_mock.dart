import '../domain/entities/walker.dart';

const List<Walker> kMockWalkers = [
  Walker(
    name: 'Ana García',
    rating: 4.8,
    reviews: 2300,
    description:
        'Professional walker since 2020. Energetic breeds and long hikes. Your pets deserve the best!',
    distance: 0.5,
    imageUrl: 'https://picsum.photos/seed/walker_ana/800/600',
    avatarUrl: 'https://picsum.photos/seed/walker_ana_av/400/400',
    priceLabel: '\$10/walk',
    pricePerWalk: 10.0,
    topRated: true,
    isVerified: true,
    yearsOfExperience: 5,
    biography:
        'Passionate dog lover with 5+ years of experience. I specialize in positive reinforcement and long nature walks. I believe every dog deserves a tailored experience that fits their energy levels and personality.',
    specialties: [
      'Large Dogs',
      'Puppies',
      'First Aid Certified',
      'Reactive Dogs',
    ],
    galleryImages: [
      'https://picsum.photos/seed/ana_g1/400/300',
      'https://picsum.photos/seed/ana_g2/400/300',
      'https://picsum.photos/seed/ana_g3/400/300',
    ],
    serviceArea: 'Downtown, Westside',
    maxDogs: 3,
    completedWalks: 1200,
  ),
  Walker(
    name: 'Carlos López',
    rating: 4.6,
    reviews: 1200,
    description:
        'Experienced with multiple dog breeds and personalities. Safety is always my top priority.',
    distance: 1.2,
    imageUrl: 'https://picsum.photos/seed/walker_carlos/800/600',
    avatarUrl: 'https://picsum.photos/seed/walker_carlos_av/400/400',
    priceLabel: '\$15/walk',
    pricePerWalk: 15.0,
    topRated: false,
    isVerified: true,
    yearsOfExperience: 3,
    biography:
        'Experienced dog walker with a passion for large breeds. I believe every dog deserves a safe, fun, and tiring walk tailored to their energy levels and personality.',
    specialties: ['Large Dogs', 'Puppy Training', 'Senior Care'],
    galleryImages: [
      'https://picsum.photos/seed/carlos_g1/400/300',
      'https://picsum.photos/seed/carlos_g2/400/300',
      'https://picsum.photos/seed/carlos_g3/400/300',
    ],
    serviceArea: 'North Hills, Eastside',
    maxDogs: 2,
    completedWalks: 850,
  ),
  Walker(
    name: 'María Torres',
    rating: 4.9,
    reviews: 3100,
    description:
        'Certified pet first-aid. I treat every dog like my own. Available weekends and evenings.',
    distance: 0.8,
    imageUrl: 'https://picsum.photos/seed/walker_maria/800/600',
    avatarUrl: 'https://picsum.photos/seed/walker_maria_av/400/400',
    priceLabel: '\$12/walk',
    pricePerWalk: 12.0,
    topRated: true,
    isVerified: true,
    yearsOfExperience: 7,
    biography:
        'Certified pet first-aid professional. Every dog I walk gets my full attention and care. I specialize in reactive dogs and anxiety management for a calm, joyful walk every single time.',
    specialties: [
      'First Aid Certified',
      'Reactive Dogs',
      'Senior Dogs',
      'Small Breeds',
    ],
    galleryImages: [
      'https://picsum.photos/seed/maria_g1/400/300',
      'https://picsum.photos/seed/maria_g2/400/300',
      'https://picsum.photos/seed/maria_g3/400/300',
    ],
    serviceArea: 'Brooklyn, NY',
    maxDogs: 4,
    completedWalks: 2100,
  ),
];
