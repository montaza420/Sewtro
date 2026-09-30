import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// আপনার নতুন Google Apps Script Web App URL
const String scriptUrl = "https://script.google.com/macros/s/AKfycbz96NxHFTW_4h1wN40U9IJbQEdqQiqDOglMmQ-oYojHb8mit91J8nh8kDoE52w-nQtu/exec";

// SEWTRON অফিসিয়াল লোগো লিংক
const String logoUrl = "https://i.ibb.co/6P0yN2B/sewtron-logo.png";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SewtronApp());
}

class SewtronApp extends StatelessWidget {
  const SewtronApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEWTRON ENGINEERING',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07070A),
        fontFamily: 'Roboto',
      ),
      home: const AuthenticLampLoginScreen(),
    );
  }
}

// ==================== ১. লক করা অথেন্টিক ঝুলন্ত লাইট লগইন স্ক্রিন ====================
class AuthenticLampLoginScreen extends StatefulWidget {
  const AuthenticLampLoginScreen({super.key});

  @override
  State<AuthenticLampLoginScreen> createState() => _AuthenticLampLoginScreenState();
}

class _AuthenticLampLoginScreenState extends State<AuthenticLampLoginScreen> {
  bool isLightOn = false;
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool isLogging = false;
  String errorMsg = "";

  void toggleLight() {
    setState(() {
      isLightOn = !isLightOn;
      errorMsg = "";
    });
  }

  Future<void> handleLogin() async {
    if (userCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      setState(() => errorMsg = "ইউজারনেম এবং পাসওয়ার্ড দিন!");
      return;
    }

    setState(() {
      isLogging = true;
      errorMsg = "";
    });

    try {
      final res = await http.get(Uri.parse(
        "$scriptUrl?action=login&username=${Uri.encodeComponent(userCtrl.text.trim())}&password=${Uri.encodeComponent(passCtrl.text.trim())}"
      )).timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);
      if (data['status'] == 'SUCCESS') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainDashboardScreen(
              user: data['user']['name'],
              role: data['user']['role'],
            ),
          ),
        );
      } else {
        setState(() => errorMsg = data['message'] ?? "ইউজারনেম বা পাসওয়ার্ড সঠিক নয়!");
      }
    } catch (_) {
      setState(() => errorMsg = "সার্ভারে কানেক্ট করা যাচ্ছে না! ইন্টারনেট চেক করুন।");
    } finally {
      if (mounted) setState(() => isLogging = false);
    }
  }

  void openResetDialog() {
    final rUser = TextEditingController();
    final rPass = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("পাসওয়ার্ড রিসেট", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rUser,
              decoration: const InputDecoration(labelText: "ইউজারনেম", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "নতুন পাসওয়ার্ড", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("বাতিল")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              if (rUser.text.isNotEmpty && rPass.text.isNotEmpty) {
                Navigator.pop(ctx);
                try {
                  final res = await http.get(Uri.parse(
                    "$scriptUrl?action=reset_password&username=${Uri.encodeComponent(rUser.text.trim())}&new_password=${Uri.encodeComponent(rPass.text.trim())}"
                  ));
                  final d = jsonDecode(res.body);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(d['message'] ?? "")));
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পাসওয়ার্ড রিসেট ব্যর্থ হয়েছে")));
                  }
                }
              }
            },
            child: const Text("সংরক্ষণ", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (isLightOn)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.65),
                    radius: 1.25,
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.18),
                      Colors.black.withOpacity(0.85),
                      const Color(0xFF07070A),
                    ],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: toggleLight,
                    child: SizedBox(
                      height: isLightOn ? 130 : 380,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(width: 2.5, height: isLightOn ? 70 : 220, color: const Color(0xFF64748B)),
                          Positioned(
                            top: isLightOn ? 65 : 215,
                            child: Column(
                              children: [
                                Container(
                                  width: 18,
                                  height: 12,
                                  decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(3)),
                                ),
                                Container(
                                  width: isLightOn ? 38 : 48,
                                  height: isLightOn ? 38 : 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isLightOn ? const Color(0xFFFFFBEB) : const Color(0xFFFEF3C7).withOpacity(0.75),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF59E0B).withOpacity(isLightOn ? 0.95 : 0.4),
                                        blurRadius: isLightOn ? 45 : 22,
                                        spreadRadius: isLightOn ? 16 : 6,
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.lightbulb,
                                    color: isLightOn ? const Color(0xFFD97706) : Colors.amber.shade700,
                                    size: isLightOn ? 25 : 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLightOn)
                            Positioned(
                              top: 265,
                              right: MediaQuery.of(context).size.width / 2 - 25,
                              child: Column(
                                children: [
                                  Container(width: 1.5, height: 85, color: const Color(0xFF94A3B8)),
                                  Container(
                                    width: 10,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 6)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (!isLightOn) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "দড়িতে টান দিন বা বাতিতে ট্যাপ করুন",
                      style: TextStyle(color: Color(0xFFFCD34D), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "আলো জ্বলে উঠলে লগইন ইন্টারফেস উন্মোচিত হবে",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],

                  if (isLightOn) ...[
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.4), blurRadius: 18, spreadRadius: 3)
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.settings, size: 55, color: Color(0xFF1E3A8A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text("SEWTRON ENGINEERING", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.8)),
                    const Text("Industrial Electronics & Control", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: TextField(
                        controller: userCtrl,
                        decoration: InputDecoration(
                          labelText: "ইউজার নেম",
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFF59E0B)),
                          filled: true,
                          fillColor: const Color(0xFF121826),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3748))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "পাসওয়ার্ড",
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFFF59E0B)),
                          filled: true,
                          fillColor: const Color(0xFF121826),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3748))),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: TextButton(
                        onPressed: openResetDialog,
                        child: const Text(
                          "🔄 পাসওয়ার্ড ভুলে গেছেন? রিসেট করুন",
                          style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),

                    if (errorMsg.isNotEmpty) ...[
                      Text(errorMsg, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                    ],

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isLogging ? null : handleLogin,
                        child: isLogging
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("লগইন করুন  ➔", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: toggleLight,
                      child: const Text("💡 লাইট অফ করুন", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    )
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ২. ইন-অ্যাপ ড্যাশবোর্ড ও লাইভ সিঙ্ক ====================
class MainDashboardScreen extends StatefulWidget {
  final String user;
  final String role;
  const MainDashboardScreen({super.key, required this.user, required this.role});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with WidgetsBindingObserver {
  int curIndex = 0;
  bool isSyncing = true;
  Map<String, dynamic> summary = {"totalBill": 0, "totalPaid": 0, "totalDue": 0, "customerCount": 0};
  List<dynamic> allEntries = [];
  List<dynamic> customerList = [];
  Timer? autoSyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    syncDatabase();
    autoSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) => syncDatabase(silent: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    autoSyncTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncDatabase();
    }
  }

  Future<void> syncDatabase({bool silent = false}) async {
    if (!silent) setState(() => isSyncing = true);
    try {
      final res = await http.get(Uri.parse(scriptUrl)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'SUCCESS') {
          if (!mounted) return;
          setState(() {
            summary = data['summary'];
            allEntries = data['entries'].reversed.toList();
            customerList = data['customers'];
          });
        }
      }
    } catch (_) {}
    if (!silent && mounted) setState(() => isSyncing = false);
  }

  Future<void> triggerBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("গুগল ড্রাইভে ব্যাকআপ নেওয়া হচ্ছে...")));
    try {
      final res = await http.get(Uri.parse("$scriptUrl?action=backup"));
      final d = jsonDecode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(d['message'] ?? "ব্যাকআপ সম্পন্ন!")));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ব্যাকআপ নেওয়া সম্ভব হয়নি!")));
      }
    }
  }

  void openAddBillDialog() {
    final nameCtrl = TextEditingController();
    final invCtrl = TextEditingController();
    final billCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    final remCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161F30),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("নতুন বিল ও কালেকশন এন্ট্রি", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "কাস্টমারের নাম", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: invCtrl, decoration: const InputDecoration(labelText: "চালান / ইনভয়েস নং", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: billCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "মোট বিল (৳)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "জমা / পেইড (৳)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: remCtrl, decoration: const InputDecoration(labelText: "মন্তব্য (Remarks)", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && billCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    double b = double.tryParse(billCtrl.text) ?? 0;
                    double p = double.tryParse(paidCtrl.text) ?? 0;
                    await http.post(
                      Uri.parse(scriptUrl),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "name": nameCtrl.text,
                        "inv": invCtrl.text,
                        "bill": b,
                        "paid": p,
                        "due": b - p,
                        "remarks": remCtrl.text,
                        "addedBy": widget.user,
                        "date": DateTime.now().toIso8601String().substring(0, 10)
                      }),
                    );
                    syncDatabase();
                  }
                },
                child: const Text("সংরক্ষণ করুন", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74),
        child: Container(
          color: const Color(0xFF161F30),
          padding: const EdgeInsets.only(top: 32, left: 14, right: 14, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.settings, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("SEWTRON V1", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Logged as: ${widget.user} (${widget.role})", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(60, 32),
                    ),
                    onPressed: () => syncDatabase(),
                    child: const Text("Refresh", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(54, 32),
                    ),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthenticLampLoginScreen())),
                    child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 11)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: isSyncing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : curIndex == 0
              ? buildDashboardBody()
              : curIndex == 3
                  ? buildCustomerBody()
                  : Center(child: Text("Tab $curIndex Selected", style: const TextStyle(color: Colors.grey))),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: curIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121826),
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 11,
        unselectedFontSize: 9.5,
        onTap: (idx) {
          if (idx == 1) openAddBillDialog();
          else if (idx == 6) triggerBackup();
          else setState(() => curIndex = idx);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Dash"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), label: "Pay"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Customer"),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload_outlined), label: "Backup"),
        ],
      ),
    );
  }

  Widget buildDashboardBody() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(child: metricCard("Total Bill", "৳ ${summary['totalBill']}", const Color(0xFF38BDF8))),
            const SizedBox(width: 10),
            Expanded(child: metricCard("Total Paid", "৳ ${summary['totalPaid']}", const Color(0xFF4ADE80))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: metricCard("Total Due", "৳ ${summary['totalDue']}", const Color(0xFFF87171))),
            const SizedBox(width: 10),
            Expanded(child: metricCard("Customers", "${summary['customerCount'] ?? customerList.length}", const Color(0xFFFBBF24))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2D3748)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Recent Ledger Transactions", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
              const Divider(height: 16, color: Color(0xFF2D3748)),
              if (allEntries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("কোনো লেনদেন পাওয়া যায়নি")),
                ),
              ...allEntries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF8FAFC))),
                        Text("Inv: ${e['inv']} | ${e['date']} (by: ${e['addedBy'] ?? 'Staff'})", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                      ],
                    ),
                    Text("Due: ৳${e['due']}", style: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCustomerBody() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: customerList.length,
      itemBuilder: (ctx, i) {
        final c = customerList[i];
        return Card(
          color: const Color(0xFF161F30),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text("বিল: ৳${c['billed']} | জমা: ৳${c['paid']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            trailing: Text("বাকি: ৳${c['due']}", style: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        );
      },
    );
  }

  Widget metricCard(String title, String val, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: c, width: 4.5)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
        ],
      ),
    );
  }
}
