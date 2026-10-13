import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

// 1. Model
class Item {
  Item(
    this.name, {
    this.quantity = 1,
    this.note = '',
    this.category = 'Food',
    this.bought = false,
  });

  String name;
  int quantity;
  String note;
  String category;
  bool bought;
}

// 2. Main App Widget
class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

// 3. Screen Widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 4. Main Screen State
class _HomeScreenState extends State<HomeScreen> {
  final List<Item> items = [
    Item('Milk', quantity: 1, note: 'the 1 litre bottle', category: 'Drinks'),
    Item('Bread', quantity: 2, note: 'Whole wheat', category: 'Food'),
    Item('Rice', quantity: 1, note: '1 kg bag', category: 'Food'),
  ];

  final controller = TextEditingController();
  String filter = 'All'; // 'All', 'To buy', 'Bought'

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }

    // Part 3: Duplicate check (case-insensitive & trimmed)
    final existingIndex = items.indexWhere(
      (item) => item.name.trim().toLowerCase() == text.toLowerCase(),
    );

    if (existingIndex != -1) {
      setState(() {
        items[existingIndex].quantity += 1;
      });
      controller.clear();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${items[existingIndex].name} is already on the list: now ×${items[existingIndex].quantity}',
          ),
        ),
      );
      return;
    }

    // Add new item (Part 6: starts as Food with no note)
    setState(() {
      items.add(Item(text, quantity: 1, category: 'Food', note: ''));
    });
    controller.clear();
  }

  // Part 4: Delete with Undo
  void deleteItem(Item item) {
    final originalIndex = items.indexOf(item);
    setState(() {
      items.remove(item);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              items.insert(originalIndex, item);
            });
          },
        ),
      ),
    );
  }

  // Part 6: Open DetailsScreen
  void openDetails(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsScreen(item: item)),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftCount = items.where((item) => !item.bought).length;

    // Part 5: Filter list
    List<Item> shown;
    if (filter == 'To buy') {
      shown = items.where((i) => !i.bought).toList();
    } else if (filter == 'Bought') {
      shown = items.where((i) => i.bought).toList();
    } else {
      // 'All': bought items always at the bottom
      shown = [
        ...items.where((i) => !i.bought),
        ...items.where((i) => i.bought),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} ($leftCount left)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Clear bought items',
            onPressed: () {
              setState(() {
                items.removeWhere((item) => item.bought);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Input row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Add an item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          // Part 5: Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'All',
                  onSelected: (_) {
                    setState(() => filter = 'All');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: filter == 'To buy',
                  onSelected: (_) {
                    setState(() => filter = 'To buy');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: filter == 'Bought',
                  onSelected: (_) {
                    setState(() => filter = 'Bought');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // List Area or Empty states
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Your list is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : shown.isEmpty
                    ? const Center(
                        child: Text(
                          'Nothing here',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final item = shown[index];
                          // Part 6: Subtitle shows category and note
                          final subtitleText = item.note.isNotEmpty
                              ? '${item.category} · ${item.note}'
                              : item.category;

                          return ListTile(
                            leading: Icon(
                              item.bought
                                  ? Icons.check_circle
                                  : Icons.shopping_basket,
                              color: item.bought ? Colors.green : null,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                decoration: item.bought
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              subtitleText,
                              style: TextStyle(
                                color: Colors.grey[600],
                                decoration: item.bought
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                item.bought = !item.bought;
                              });
                            },
                            // Part 6: Long press opens details
                            onLongPress: () => openDetails(item),
                            // Part 2: Quantities (− qty +) and bin
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  iconSize: 18,
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      setState(() {
                                        item.quantity -= 1;
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  iconSize: 18,
                                  onPressed: () {
                                    setState(() {
                                      item.quantity += 1;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => deleteItem(item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// 5. Part 6: Details Screen
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.item});

  final Item item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final nameController = TextEditingController();
  final noteController = TextEditingController();
  late String category;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.name;
    noteController.text = widget.item.note;
    category = widget.item.category;
  }

  void save() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    widget.item.name = name;
    widget.item.note = noteController.text.trim();
    widget.item.category = category;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (e.g. the 1 litre bottle)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Food'),
                  selected: category == 'Food',
                  onSelected: (_) => setState(() => category = 'Food'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Drinks'),
                  selected: category == 'Drinks',
                  onSelected: (_) => setState(() => category = 'Drinks'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Home'),
                  selected: category == 'Home',
                  onSelected: (_) => setState(() => category = 'Home'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: save,
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
