import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';

class GroceryPlannerScreen extends StatefulWidget {
  const GroceryPlannerScreen({super.key});

  @override
  State<GroceryPlannerScreen> createState() => _GroceryPlannerScreenState();
}

class _GroceryPlannerScreenState extends State<GroceryPlannerScreen> {
  static const _storageKey = 'provida_grocery_plan';
  final List<_GroceryItem> _items = [];
  bool _loading = true;

  double get _plannedTotal => _items.fold(0, (total, item) => total + item.price * item.quantity);
  double get _basketTotal => _items.where((item) => item.purchased).fold(0, (total, item) => total + item.price * item.quantity);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw != null) {
      try {
        final rows = jsonDecode(raw) as List<dynamic>;
        _items.addAll(rows.map((row) => _GroceryItem.fromJson(Map<String, dynamic>.from(row as Map))));
      } catch (_) {
        // A damaged local list starts clean instead of blocking the planner.
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(_items.map((item) => item.toJson()).toList()));
  }

  Future<void> _showItemEditor({_GroceryItem? item}) async {
    final name = TextEditingController(text: item?.name ?? '');
    final quantity = TextEditingController(text: item?.quantity.toString() ?? '1');
    final price = TextEditingController(text: item == null ? '' : item.price.toStringAsFixed(2));
    final result = await showModalBottomSheet<_GroceryItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item == null ? 'Add grocery item' : 'Edit grocery item', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(controller: name, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Item', hintText: 'e.g. Rice, milk, tomatoes')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Est. unit price'))),
            ]),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final itemName = name.text.trim();
                  if (itemName.isEmpty) return;
                  Navigator.pop(sheetContext, _GroceryItem(
                    id: item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    name: itemName,
                    quantity: int.tryParse(quantity.text) ?? 1,
                    price: double.tryParse(price.text) ?? 0,
                    purchased: item?.purchased ?? false,
                  ));
                },
                child: Text(item == null ? 'Add to plan' : 'Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    quantity.dispose();
    price.dispose();
    if (result == null || !mounted) return;
    setState(() {
      final index = _items.indexWhere((entry) => entry.id == result.id);
      if (index == -1) {
        _items.add(result);
      } else {
        _items[index] = result;
      }
    });
    await _save();
  }

  Future<void> _remove(_GroceryItem item) async {
    setState(() => _items.removeWhere((entry) => entry.id == item.id));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Grocery plan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showItemEditor,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add item'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(gradient: AppColors.electricGradient, borderRadius: BorderRadius.circular(22)),
                child: Row(children: [
                  const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 34),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_items.where((item) => item.purchased).length} of ${_items.length} items in basket', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 3),
                    Text('Estimated total  ${_plannedTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Basket  ${_basketTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                  ])),
                ]),
              ),
              Expanded(
                child: _items.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Your grocery plan is empty.\nAdd items before your next shopping trip.', textAlign: TextAlign.center)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: _items.length,
                        itemBuilder: (_, index) {
                          final item = _items[index];
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _remove(item),
                            background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: AppColors.expense, child: const Icon(Icons.delete_outline_rounded, color: Colors.white)),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: CheckboxListTile(
                                value: item.purchased,
                                activeColor: AppColors.primary,
                                onChanged: (value) async {
                                  setState(() => item.purchased = value ?? false);
                                  await _save();
                                },
                                secondary: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(dark ? 0.22 : 0.1), child: Icon(Icons.local_grocery_store_outlined, color: dark ? AppColors.accentLight : AppColors.primary)),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          decoration: item.purchased ? TextDecoration.lineThrough : null,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit item',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _showItemEditor(item: item),
                                      icon: const Icon(Icons.edit_outlined, size: 19),
                                    ),
                                  ],
                                ),
                                subtitle: Text('${item.quantity} × ${item.price.toStringAsFixed(2)}  •  ${(item.quantity * item.price).toStringAsFixed(2)}'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ]),
    );
  }
}

class _GroceryItem {
  _GroceryItem({required this.id, required this.name, required this.quantity, required this.price, required this.purchased});
  final String id;
  final String name;
  final int quantity;
  final double price;
  bool purchased;

  factory _GroceryItem.fromJson(Map<String, dynamic> json) => _GroceryItem(
        id: json['id'].toString(),
        name: json['name'].toString(),
        quantity: json['quantity'] as int? ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        purchased: json['purchased'] == true,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'quantity': quantity, 'price': price, 'purchased': purchased};
}
