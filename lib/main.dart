import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

const kRouteHome = '/';
const kRouteSummary = '/summary';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter v.3 Cross',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: kRouteHome,
      routes: {
        kRouteHome: (_) => const HomePage(),
        kRouteSummary: (_) => const SummaryPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _newsletter = false;
  double _favNumber = 7;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = sp.getString('name') ?? '';
      _newsletter = sp.getBool('newsletter') ?? false;
      _favNumber = sp.getDouble('favNumber') ?? 7;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('name', _nameCtrl.text.trim());
    await sp.setBool('newsletter', _newsletter);
    await sp.setDouble('favNumber', _favNumber);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sparat!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                  semanticLabel: 'Appens logotyp (asset)',
                ),
                const SizedBox(height: 16),
                Image.network(
                  'https://picsum.photos/seed/flutterv3/600/200',
                  height: 120,
                  fit: BoxFit.cover,
                  semanticLabel: 'Nätbild (URI)',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ditt namn',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ange ett namn' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Nyhetsbrev'),
                    const Spacer(),
                    Switch(
                      value: _newsletter,
                      onChanged: (v) => setState(() => _newsletter = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Favoritnummer: ${_favNumber.round()}'),
                    Slider(
                      min: 0,
                      max: 100,
                      divisions: 100,
                      value: _favNumber,
                      onChanged: (v) => setState(() => _favNumber = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Spara'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, kRouteSummary);
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Nästa sida'),
                    ),
                  ],
                ),
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter v.3 – Hem')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(child: content),
          ),
        ),
      ),
    );
  }
}

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String _name = '';
  bool _newsletter = false;
  double _favNumber = 7;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _name = sp.getString('name') ?? '';
      _newsletter = sp.getBool('newsletter') ?? false;
      _favNumber = sp.getDouble('favNumber') ?? 7;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sammanfattning')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Namn'),
                  subtitle: Text(_name.isEmpty ? '–' : _name),
                ),
                ListTile(
                  leading: const Icon(Icons.mark_email_unread),
                  title: const Text('Nyhetsbrev'),
                  subtitle: Text(_newsletter ? 'Ja' : 'Nej'),
                ),
                ListTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text('Favoritnummer'),
                  subtitle: Text(_favNumber.round().toString()),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Tillbaka'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
