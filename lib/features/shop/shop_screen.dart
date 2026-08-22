import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/shop_catalog.dart';
import '../../game/models/shop_item.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/shop_repository.dart';

/// The coin shop (design brief section 11): every item from
/// [ShopCatalog], grouped by slot, with a Buy button that only ever
/// enables when the child can actually afford it. Buying spends real
/// coins through [CoinRepository.spendCoins] — no gambling, no loot
/// boxes, every purchase is a specific named item at a fixed price.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => ShopScreenState();
}

@visibleForTesting
class ShopScreenState extends State<ShopScreen> {
  late CoinRepository _coinRepository;
  late ShopRepository _shopRepository;
  late FeedbackService _feedbackService;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _coinRepository = CoinRepository(storage);
    _shopRepository = ShopRepository(storage);
    _feedbackService = FeedbackService(storage);
    _loaded = true;
  }

  Future<void> _buy(ShopItem item) async {
    final spent = await _coinRepository.spendCoins(item.price);
    if (!spent) return;
    await _shopRepository.markOwned(item.id);
    if (!mounted) return;
    _feedbackService.play(SoundEvent.purchase);
    setState(() {});
  }

  static const List<(String, List<ShopCategory>)> _sections = [
    ('Hero', [
      ShopCategory.hair,
      ShopCategory.outfit,
      ShopCategory.shoes,
      ShopCategory.backpack,
    ]),
    ('Room', [
      ShopCategory.wallArt,
      ShopCategory.rug,
      ShopCategory.plant,
      ShopCategory.lamp,
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final coins = _coinRepository.coins;
    final ownedIds = _shopRepository.ownedItemIds();

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _CoinBalance(coins: coins),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final (sectionTitle, categories) in _sections) ...[
                    Text(
                      sectionTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final category in categories) ...[
                      Text(
                        _categoryLabel(category),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final item in ShopCatalog.itemsFor(category)) ...[
                        _ShopItemTile(
                          item: item,
                          owned: ownedIds.contains(item.id),
                          affordable: coins >= item.price,
                          onBuy: () => _buy(item),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(ShopCategory category) => switch (category) {
        ShopCategory.hair => 'Hair',
        ShopCategory.outfit => 'Outfit',
        ShopCategory.shoes => 'Shoes',
        ShopCategory.backpack => 'Backpack',
        ShopCategory.wallArt => 'Wall Art',
        ShopCategory.rug => 'Rug',
        ShopCategory.plant => 'Plant',
        ShopCategory.lamp => 'Lamp',
      };
}

class _CoinBalance extends StatelessWidget {
  const _CoinBalance({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: AppColors.coin),
          const SizedBox(width: 8),
          Text('$coins', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ShopItemTile extends StatelessWidget {
  const _ShopItemTile({
    required this.item,
    required this.owned,
    required this.affordable,
    required this.onBuy,
  });

  final ShopItem item;
  final bool owned;
  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final canBuy = !owned && affordable;

    return Card(
      key: ValueKey('shop_item_${item.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    '${item.price} 🪙',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            FilledButton(
              key: ValueKey('buy_${item.id}'),
              onPressed: canBuy ? onBuy : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                backgroundColor: owned ? Colors.grey.shade300 : AppColors.leafGreen,
              ),
              child: Text(owned ? 'Owned' : 'Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
