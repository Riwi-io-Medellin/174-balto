import '../domain/entities/business.dart';

const List<Business> kMockBusinesses = [
  Business(
    id: 'paws_wellness',
    name: 'Paws & Wellness Center',
    isVeterinary: true,
    isStore: true,
    rating: 4.9,
    reviewCount: 2400,
    distance: 1.2,
    isOpen: true,
    description:
        'Your one-stop destination for expert medical care and premium pet supplies. Combining a state-of-the-art veterinary clinic with a curated boutique pet store.',
    coverImage: 'https://picsum.photos/seed/biz_paws_cover/800/400',
    logoImage: 'https://picsum.photos/seed/biz_paws_logo/200/200',
    features: ['24/7 Emergency', 'Free Delivery', 'Grooming', 'Vaccination'],
    address: '123 Wellness Ave, Suite 400, San Francisco, CA',
    phone: '+1 (415) 555-0101',
    openingHours: {
      'Monday - Friday': '08:00 - 20:00',
      'Saturday': '09:00 - 18:00',
      'Sunday': '10:00 - 16:00',
    },
    services: [
      ServiceItem(
        name: 'Comprehensive General Checkup',
        description:
            'Full body scan, vaccinations, health monitoring and expert consultation.',
        price: 89.0,
        imageUrl: 'https://picsum.photos/seed/svc_paws1/400/200',
        tags: ['POPULAR', 'RECOMMENDED'],
      ),
    ],
    products: [
      ProductItem(
        name: 'PurePaws Organic Adult Food',
        price: 54.99,
        description: 'Grain-free salmon & sweet potato formula for sensitive digestion.',
        imageUrl: 'https://picsum.photos/seed/prod_paws1/200/200',
      ),
    ],
    facilities: ['Free Parking', 'Free WiFi', 'Accessible', 'Cafe Area'],
  ),
  Business(
    id: 'city_vet',
    name: 'City Vet Clinic',
    isVeterinary: true,
    isStore: false,
    rating: 4.7,
    reviewCount: 950,
    distance: 2.1,
    isOpen: false,
    description:
        'Professional veterinary care with experienced specialists. We offer comprehensive medical services for all types of pets.',
    coverImage: 'https://picsum.photos/seed/biz_city_cover/800/400',
    logoImage: 'https://picsum.photos/seed/biz_city_logo/200/200',
    features: ['Vaccination', 'Surgery', 'Dental Care'],
    address: '45 Medical Drive, San Francisco, CA',
    phone: '+1 (415) 555-0202',
    openingHours: {
      'Monday - Friday': '09:00 - 18:00',
      'Saturday': '10:00 - 14:00',
    },
    services: [
      ServiceItem(
        name: 'Annual Vaccination Package',
        description: 'Complete vaccination schedule with health certificate.',
        price: 120.0,
        imageUrl: 'https://picsum.photos/seed/svc_city1/400/200',
        tags: ['ESSENTIAL'],
      ),
    ],
    facilities: ['Free Parking', 'Accessible'],
  ),
  Business(
    id: 'happy_paws_store',
    name: 'Happy Paws Store',
    isVeterinary: false,
    isStore: true,
    rating: 4.5,
    reviewCount: 640,
    distance: 0.7,
    isOpen: true,
    description:
        'Your neighborhood pet supplies store. Everything your pet needs, from premium food to fun toys and accessories.',
    coverImage: 'https://picsum.photos/seed/biz_happy_cover/800/400',
    logoImage: 'https://picsum.photos/seed/biz_happy_logo/200/200',
    features: ['Free Delivery', 'Pet Supplies', 'Accessories'],
    address: '88 Park Street, San Francisco, CA',
    phone: '+1 (415) 555-0303',
    openingHours: {
      'Monday - Saturday': '09:00 - 21:00',
      'Sunday': '11:00 - 18:00',
    },
    products: [
      ProductItem(
        name: 'Royal Canin Adult Food',
        price: 39.99,
        description: 'Specially formulated for adult dogs, optimal digestion.',
        imageUrl: 'https://picsum.photos/seed/prod_happy1/200/200',
      ),
      ProductItem(
        name: 'Kong Classic Toy',
        price: 14.99,
        description: 'Durable rubber toy for mental stimulation.',
        imageUrl: 'https://picsum.photos/seed/prod_happy2/200/200',
      ),
    ],
    facilities: ['Free WiFi', 'Accessible', 'Pet Friendly'],
  ),
];
