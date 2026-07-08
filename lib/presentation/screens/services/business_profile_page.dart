import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/business.dart';
import '../../bloc/business/business_cubit.dart';
import '../../bloc/business/business_state.dart';
import '../../bloc/feedback/feedback_cubit.dart';
import '../../bloc/feedback/feedback_state.dart';
import '../../widgets/rating_summary.dart';
import '../../widgets/review_card.dart';
import '../../widgets/review_sheet.dart';
import 'widgets/business_overview_tab.dart';
import 'widgets/business_profile_header.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key, required this.business});

  final Business business;

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: images.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) => ClipRRect(
            borderRadius: AppRadius.radius14,
            child: Image.network(
              images[i],
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 96,
                height: 96,
                color: const Color(0xFFE9ECF1),
                child: const Icon(
                  Icons.image_outlined,
                  size: 28,
                  color: Color(0xFFB0B8C1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple image-first card for a service/product — no tap target or detail
/// view by design, since the Market feature doesn't handle payments yet.
class _MarketItemCard extends StatelessWidget {
  const _MarketItemCard({required this.item});

  final BusinessServiceItem item;

  @override
  Widget build(BuildContext context) {
    final isProduct = item.isProduct;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
        border: Border.all(color: const Color(0xFFEDEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: _MarketItemImage(
              photoUrl: item.photoUrl,
              isProduct: isProduct,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serviceType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold.copyWith(
                    fontSize: 13.5,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navWalkers,
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

/// Shows the item's photo, or a soft default illustration matching its kind
/// (service vs product) so a card is never left blank.
class _MarketItemImage extends StatelessWidget {
  const _MarketItemImage({required this.photoUrl, required this.isProduct});

  final String? photoUrl;
  final bool isProduct;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultImage(),
      );
    }
    return _defaultImage();
  }

  Widget _defaultImage() {
    return Container(
      color: isProduct
          ? const Color(0xFFFCEFE0)
          : AppColors.navWalkers.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Icon(
        isProduct ? Icons.shopping_bag_rounded : Icons.storefront_rounded,
        size: 34,
        color: isProduct ? const Color(0xFFE8A84C) : AppColors.navWalkers,
      ),
    );
  }
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  int _tab = 0;
  late final BusinessCubit _businessCubit;
  late final FeedbackCubit _feedbackCubit;

  @override
  void initState() {
    super.initState();
    _businessCubit = sl<BusinessCubit>();
    _feedbackCubit = sl<FeedbackCubit>();
    if (widget.business.id.isNotEmpty) {
      _businessCubit.loadBusinessDetail(widget.business.id);
      _feedbackCubit.loadBusinessReviews(widget.business.id);
    }
  }

  @override
  void dispose() {
    _businessCubit.close();
    _feedbackCubit.close();
    super.dispose();
  }

  List<String> _tabsFor(Business b) => [
    'Overview',
    if (b.isVeterinary || b.isStore || b.hasMarket) 'Services',
    'Reviews',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _businessCubit),
        BlocProvider.value(value: _feedbackCubit),
      ],
      child: BlocBuilder<BusinessCubit, BusinessState>(
        builder: (context, state) {
          final b = state is BusinessDetailLoaded
              ? state.business
              : widget.business;
          final isLoadingDetail = state is BusinessLoading;
          final tabs = _tabsFor(b);
          if (_tab >= tabs.length) _tab = 0;

          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: [
                _buildSliverAppBar(b),
                SliverToBoxAdapter(child: BusinessProfileHeader(business: b)),
                if (b.gallery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _GalleryStrip(
                      images: b.gallery.map((g) => g.fileUrl).toList(),
                    ),
                  ),
                if (isLoadingDetail)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.navWalkers,
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: _buildTabBar(tabs)),
                SliverToBoxAdapter(child: _buildTabContent(b, tabs)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Business b) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.navWalkers,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              b.photoUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF3A80C2),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 80,
              child: Text(
                b.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(List<String> tabs) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F6))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = i == _tab;
            return GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? AppColors.navWalkers : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? AppColors.navWalkers
                        : const Color(0xFF8A93A0),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent(Business b, List<String> tabs) {
    final label = tabs[_tab];
    switch (label) {
      case 'Services':
        return _buildServicesTab(b);
      case 'Reviews':
        return _buildReviewsTab(b);
      default:
        return BusinessOverviewTab(business: b);
    }
  }

  Widget _buildServicesTab(Business b) {
    if (b.services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'No services listed yet.',
            style: TextStyle(color: Color(0xFF8A93A0)),
          ),
        ),
      );
    }
    final services = b.serviceItems;
    final products = b.productItems;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (services.isNotEmpty) ...[
            if (products.isNotEmpty) _marketSectionLabel('Services'),
            _marketItemsList(services),
          ],
          if (services.isNotEmpty && products.isNotEmpty)
            const SizedBox(height: 20),
          if (products.isNotEmpty) ...[
            if (services.isNotEmpty) _marketSectionLabel('Products'),
            _marketItemsList(products),
          ],
        ],
      ),
    );
  }

  Widget _marketSectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFF8A93A0),
      ),
    ),
  );

  Widget _marketItemsList(List<BusinessServiceItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, i) => _MarketItemCard(item: items[i]),
    );
  }

  Widget _buildReviewsTab(Business b) {
    return BlocBuilder<FeedbackCubit, FeedbackState>(
      builder: (context, state) {
        if (state is FeedbackLoading) {
          return const Padding(
            padding: EdgeInsets.all(60),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.navWalkers),
            ),
          );
        }
        if (state is FeedbackError) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Color(0xFF8A93A0), fontSize: 14),
              ),
            ),
          );
        }
        if (state is FeedbackLoaded) {
          final summary = state.summary;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingSummary(summary: summary),
                const SizedBox(height: 24),
                if (summary.reviews.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No reviews yet.',
                        style: TextStyle(color: Color(0xFF8A93A0)),
                      ),
                    ),
                  )
                else
                  ...summary.reviews.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReviewCard(review: r),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showReviewSheet(
                      context: context,
                      targetId: b.id,
                      targetType: 'business',
                      targetName: b.name,
                      title: 'Rate this business',
                      subtitle: 'How was your experience with ${b.name}?',
                    ),
                    icon: const Icon(Icons.star_outline_rounded, size: 18),
                    label: const Text('Write a Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navWalkers,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radius12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
