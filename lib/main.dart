import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

class Item {
  Item(this.name, {this.quantity = 1});

  String name;
  int quantity;
  bool bought = false;
}

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = [
    Item('Milk', quantity: 1),
    Item('Bread', quantity: 1),
    Item('Rice', quantity: 1),
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

    setState(() {
      items.add(Item(text));
    });
    controller.clear();
  }

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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftCount = items.where((item) => !item.bought).length;

    // Part 5: filtered list
    List<Item> shown;
    if (filter == 'To buy') {
      shown = items.where((i) => !i.bought).toList();
    } else if (filter == 'Bought') {
      shown = items.where((i) => i.bought).toList();
    } else {
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
          // Part 5: Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'All',
                  onSelected: (_) => setState(() => filter = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: filter == 'To buy',
                  onSelected: (_) => setState(() => filter = 'To buy'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: filter == 'Bought',
                  onSelected: (_) => setState(() => filter = 'Bought'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
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
                          return ListTile(
                            leading: Icon(
                              item.bought ? Icons.check_circle : Icons.shopping_basket,
                              color: item.bought ? Colors.green : null,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                decoration:
                                    item.bought ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                item.bought = !item.bought;
                              });
                            },
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
