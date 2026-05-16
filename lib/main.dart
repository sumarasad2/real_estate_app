import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  final days = const ["السبت","الأحد","الاثنين","الثلاثاء","الأربعاء","الخميس","الجمعة"];

  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مواعيد العقارات")),
      body: ListView(
        children: days.map((d) {
          return Card(
            child: ListTile(
              title: Text(d),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => Day(d)));
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Day extends StatefulWidget {
  final String day;
  const Day(this.day, {super.key});

  @override
  State<Day> createState() => _DayState();
}

class _DayState extends State<Day> {
  List<Map<String, String>> items = [];

  final property = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();

  String area = "عمارة برانية";

  final areas = const [
    "عمارة برانية","عمارة جوانية","قيمرية","عقيبة","ساروجة","باب بريد"
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  void save() async {
    final p = await SharedPreferences.getInstance();
    p.setString(widget.day, jsonEncode(items));
  }

  void load() async {
    final p = await SharedPreferences.getInstance();
    final data = p.getString(widget.day);
    if (data != null) {
      setState(() {
        items = List<Map<String, String>>.from(jsonDecode(data));
      });
    }
  }

  void add() {
    setState(() {
      items.add({
        "area": area,
        "property": property.text,
        "name": name.text,
        "phone": phone.text,
      });
    });

    save();

    property.clear();
    name.clear();
    phone.clear();

    Navigator.pop(context);
  }

  void delete(int i) {
    setState(() {
      items.removeAt(i);
    });
    save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.day)),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (c, i) {
          final x = items[i];
          return Card(
            child: ListTile(
              title: Text(x["area"] ?? ""),
              subtitle: Text(
                "رقم العقار: ${x["property"]}\n"
                "الاسم: ${x["name"]}\n"
                "الهاتف: ${x["phone"]}"
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => delete(i),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("إضافة موعد"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton(
                    value: area,
                    items: areas.map((e) =>
                      DropdownMenuItem(value: e, child: Text(e))
                    ).toList(),
                    onChanged: (v) => setState(() => area = v!),
                  ),
                  TextField(controller: property, decoration: const InputDecoration(labelText: "رقم العقار")),
                  TextField(controller: name, decoration: const InputDecoration(labelText: "الاسم")),
                  TextField(controller: phone, decoration: const InputDecoration(labelText: "الهاتف")),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
                ElevatedButton(onPressed: add, child: const Text("حفظ")),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
