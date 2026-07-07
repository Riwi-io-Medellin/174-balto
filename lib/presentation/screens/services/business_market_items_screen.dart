import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/repositories/business_repository.dart';

/// CRUD screen for a business's Market items (services and/or products).
/// Both kinds share the same BusinessService backend table, distinguished
/// by [BusinessServiceItem.itemKind].
class BusinessMarketItemsScreen extends StatefulWidget {
  const BusinessMarketItemsScreen({super.key, required this.businessId});

  final String businessId;

  @override
  State<BusinessMarketItemsScreen> createState() =>
      _BusinessMarketItemsScreenState();
}

class _BusinessMarketItemsScreenState extends State<BusinessMarketItemsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = AppColors.navWalkers;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF8A93A0);

  late final TabController _tabController;
  bool _loading = true;
  List<BusinessServiceItem> _items = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await sl<BusinessRepository>().getBusinessServices(
        widget.businessId,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      BaltoToast.error(context, 'Failed to load items.');
    }
  }

  Future<void> _openForm({BusinessServiceItem? existing, String? itemKind}) async {
    final typeCtrl = TextEditingController(text: existing?.serviceType ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(2) : '',
    );
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final kind = existing?.itemKind ?? itemKind ?? 'service';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null
                  ? (kind == 'product' ? 'Add Product' : 'Add Service')
                  : (kind == 'product' ? 'Edit Product' : 'Edit Service'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeCtrl,
              decoration: InputDecoration(
                hintText: kind == 'product' ? 'Product name' : 'Service name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: 'Price'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final price = double.tryParse(priceCtrl.text.trim());
                  if (typeCtrl.text.trim().isEmpty || price == null) {
                    BaltoToast.warning(
                      sheetContext,
                      'Please fill in a name and a valid price.',
                    );
                    return;
                  }
                  try {
                    if (existing == null) {
                      await sl<BusinessRepository>().createBusinessService(
                        businessId: widget.businessId,
                        serviceType: typeCtrl.text.trim(),
                        price: price,
                        description: descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim(),
                        itemKind: kind,
                      );
                    } else {
                      await sl<BusinessRepository>().updateBusinessService(
                        businessId: widget.businessId,
                        serviceId: existing.id,
                        serviceType: typeCtrl.text.trim(),
                        price: price,
                        description: descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim(),
                        itemKind: kind,
                      );
                    }
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop(true);
                    }
                  } catch (_) {
                    if (sheetContext.mounted) {
                      BaltoToast.error(sheetContext, 'Failed to save item.');
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );

    if (saved == true) await _load();
  }

  Future<void> _delete(BusinessServiceItem item) async {
    try {
      await sl<BusinessRepository>().deleteBusinessService(
        businessId: widget.businessId,
        serviceId: item.id,
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to delete item.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _items.where((i) => i.itemKind == 'service').toList();
    final products = _items.where((i) => i.itemKind == 'product').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _textDark,
          ),
        ),
        title: const Text(
          'Market Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _accent,
          unselectedLabelColor: _textMuted,
          indicatorColor: _accent,
          tabs: const [Tab(text: 'Services'), Tab(text: 'Products')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(services, 'service'),
                _buildList(products, 'product'),
              ],
            ),
    );
  }

  Widget _buildList(List<BusinessServiceItem> items, String kind) {
    return Stack(
      children: [
        items.isEmpty
            ? _emptyState(
                kind == 'product'
                    ? 'No products yet'
                    : 'No services yet',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return _itemRow(item);
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'add_$kind',
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            onPressed: () => _openForm(itemKind: kind),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _itemRow(BusinessServiceItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serviceType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                if (item.description != null &&
                    item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openForm(existing: item),
            icon: const Icon(Icons.edit_rounded, size: 18, color: _accent),
          ),
          GestureDetector(
            onTap: () => _delete(item),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFFD05A24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 48,
            color: Color(0xFFB0B8C1),
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: _textMuted)),
        ],
      ),
    );
  }
}
