import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

// 1. Model: holds name, details, and bought status
class Item {
  Item(this.name, {this.details = ''});

  String name;
  String details;
  bool bought = false;
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

// 4. Screen State and Logic
class _HomeScreenState extends State<HomeScreen> {
  final items = [
    Item('Milk', details: 'almond milk, 4 litres'),
    Item('Bread', details: 'Whole wheat'),
    Item('Rice', details: 'Basmati 1kg'),
    Item('test', details: 'test-detail'),
    Item('cake', details: 'cupcake'),
  ];

  final nameController = TextEditingController();
  final detailsController = TextEditingController();

  void addItem() {
    final name = nameController.text.trim();
    final details = detailsController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item name first')),
      );
      return;
    }

    setState(() {
      items.add(Item(name, details: details));
    });

    nameController.clear();
    detailsController.clear();
  }

  // Opens a pop-up to edit both name and details
  void editItem(int index) {
    final editNameCtrl = TextEditingController(text: items[index].name);
    final editDetailsCtrl = TextEditingController(text: items[index].details);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editDetailsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Details / notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _saveEdit(index, editNameCtrl.text, editDetailsCtrl.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveEdit(int index, String newName, String newDetails) {
    final name = newName.trim();
    if (name.isNotEmpty) {
      setState(() {
        items[index].name = name;
        items[index].details = newDetails.trim();
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftCount = items.where((item) => !item.bought).length;

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
          // Input Section: Name + Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Item name (e.g. Eggs)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: detailsController,
                        decoration: const InputDecoration(
                          hintText: 'Details / notes (e.g. 1 crate, brown)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => addItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List displaying Name and Subtitle Details
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(
                    item.bought ? Icons.check_circle : Icons.shopping_basket,
                    color: item.bought ? Colors.green : null,
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          item.bought ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: item.details.isNotEmpty
                      ? Text(
                          item.details,
                          style: TextStyle(
                            decoration:
                                item.bought ? TextDecoration.lineThrough : null,
                          ),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      item.bought = !item.bought;
                    });
                  },
                  onLongPress: () => editItem(index),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => editItem(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () {
                          setState(() {
                            items.removeAt(index);
                          });
                        },
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
