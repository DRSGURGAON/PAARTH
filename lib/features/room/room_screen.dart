import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/shop_catalog.dart';
import '../../game/models/room_profile.dart';
import '../../game/models/shop_item.dart';
import '../../game/repositories/hero_repository.dart';
import '../../game/repositories/room_repository.dart';
import '../../game/repositories/shop_repository.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../player/hero_avatar_preview.dart';

/// The Player Room (design brief section 11): 4 decoration slots —
/// wall art, rug, plant, lamp — each equippable with an owned Shop
/// item or left empty. Nothing here can be bought directly; Shop
/// purchases are what fill the "owned" list a slot picks from.
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => RoomScreenState();
}

/// Distinguishes an explicit "None" tap (clear the slot) from the
/// sheet being dismissed without a choice (`null`, meaning "no
/// change") — both would otherwise resolve to the same `null` value.
const String _clearSlotSentinel = '__clear_slot__';

@visibleForTesting
class RoomScreenState extends State<RoomScreen> {
  late HeroRepository _heroRepository;
  late RoomRepository _roomRepository;
  late ShopRepository _shopRepository;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _heroRepository = HeroRepository(storage);
    _roomRepository = RoomRepository(storage);
    _shopRepository = ShopRepository(storage);
    _loaded = true;
  }

  Future<void> _openShop() async {
    await Navigator.of(context).pushNamed(RouteNames.shop);
    if (mounted) setState(() {});
  }

  Future<void> _customizeHero() async {
    await Navigator.of(context).pushNamed(RouteNames.heroSelection);
    if (mounted) setState(() {});
  }

  Future<void> _pickSlot(ShopCategory slot) async {
    final owned = _shopRepository.ownedItemIds();
    final ownedItems =
        ShopCatalog.itemsFor(slot).where((item) => owned.contains(item.id)).toList();
    final profile = _roomRepository.load();
    final currentId = _roomRepository.itemIdFor(profile, slot);

    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => _SlotPickerSheet(
        slot: slot,
        items: ownedItems,
        currentId: currentId,
      ),
    );
    if (result == null) return; // Dismissed without choosing — no change.

    final newId = result == _clearSlotSentinel ? null : result;
    if (newId == currentId) return;
    await _roomRepository.setSlot(slot, newId);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final heroProfile = _heroRepository.load();
    final roomProfile = _roomRepository.load();
    final owned = _shopRepository.ownedItemIds();

    return Scaffold(
      appBar: AppBar(title: const Text('My Room')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _RoomSlotTile(
                      slot: ShopCategory.wallArt,
                      label: 'Wall Art',
                      item: _equippedItem(roomProfile, ShopCategory.wallArt),
                      onTap: () => _pickSlot(ShopCategory.wallArt),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _RoomSlotTile(
                            slot: ShopCategory.lamp,
                            label: 'Lamp',
                            item: _equippedItem(roomProfile, ShopCategory.lamp),
                            onTap: () => _pickSlot(ShopCategory.lamp),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _RoomSlotTile(
                            slot: ShopCategory.plant,
                            label: 'Plant',
                            item: _equippedItem(roomProfile, ShopCategory.plant),
                            onTap: () => _pickSlot(ShopCategory.plant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      key: const ValueKey('customize_hero'),
                      onTap: _customizeHero,
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          HeroAvatarPreview(profile: heroProfile, size: 160),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to customize',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.inkNavy.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RoomSlotTile(
                      slot: ShopCategory.rug,
                      label: 'Rug',
                      item: _equippedItem(roomProfile, ShopCategory.rug),
                      onTap: () => _pickSlot(ShopCategory.rug),
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${owned.where((id) => ShopCatalog.all.any((i) => i.id == id && i.isRoomItem)).length} '
                      'room item(s) owned',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: BigRoundedButton(
                label: 'Visit Shop',
                icon: Icons.storefront_rounded,
                backgroundColor: AppColors.coral,
                onPressed: _openShop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ShopItem? _equippedItem(RoomProfile profile, ShopCategory slot) {
    final id = _roomRepository.itemIdFor(profile, slot);
    if (id == null) return null;
    for (final item in ShopCatalog.itemsFor(slot)) {
      if (item.id == id) return item;
    }
    return null;
  }
}

class _RoomSlotTile extends StatelessWidget {
  const _RoomSlotTile({
    required this.slot,
    required this.label,
    required this.item,
    required this.onTap,
    this.height = 96,
  });

  final ShopCategory slot;
  final String label;
  final ShopItem? item;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('room_slot_${slot.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: item == null ? Colors.white : item!.color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item == null ? Colors.grey.shade300 : item!.color,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          item == null ? '$label — tap to add' : item!.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _SlotPickerSheet extends StatelessWidget {
  const _SlotPickerSheet({
    required this.slot,
    required this.items,
    required this.currentId,
  });

  final ShopCategory slot;
  final List<ShopItem> items;
  final String? currentId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            ListTile(
              key: const ValueKey('slot_option_none'),
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.close_rounded, color: Colors.white),
              ),
              title: const Text('None'),
              trailing: currentId == null
                  ? const Icon(Icons.check_rounded, color: AppColors.leafGreen)
                  : null,
              onTap: () => Navigator.of(context).pop(_clearSlotSentinel),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Buy something for this spot in the Shop!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            for (final item in items)
              ListTile(
                key: ValueKey('slot_option_${item.id}'),
                leading: CircleAvatar(backgroundColor: item.color),
                title: Text(item.label),
                trailing: currentId == item.id
                    ? const Icon(Icons.check_rounded, color: AppColors.leafGreen)
                    : null,
                onTap: () => Navigator.of(context).pop(item.id),
              ),
          ],
        ),
      ),
    );
  }
}
