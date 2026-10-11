import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const YQSecurityApp());
}

class YQSecurityApp extends StatelessWidget {
  const YQSecurityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yqsecurity',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        cardColor: const Color(0xFF131B2E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

String hashSecurePassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUpMode = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void _handleLogin({String name = 'SOC Analyst', String email = 'analyst@yqsecurity.com'}) {
    if (passwordController.text.isNotEmpty) {
      String secureHash = hashSecurePassword(passwordController.text);
      debugPrint('Encrypted Hash: $secureHash');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          analystEmail: email,
          analystName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.8), width: 2),
                  color: Colors.blue.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 3,
                    )
                  ],
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.shield_rounded, size: 70, color: Colors.blueAccent),
                    Text(
                      'YQ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'yqsecurity SOC',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enterprise Threat Intelligence & Operations Hub',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              if (isSignUpMode) ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name / Analyst ID',
                    prefixIcon: Icon(Icons.person, color: Colors.cyanAccent),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Secure Analyst Email',
                  prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Master Password (Encrypted)',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () {
                    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter email and password')),
                      );
                      return;
                    }
                    _handleLogin(
                      name: nameController.text.isNotEmpty ? nameController.text : 'SOC Analyst',
                      email: emailController.text,
                    );
                  },
                  child: Text(
                    isSignUpMode ? 'Create Encrypted Account' : 'Secure Login',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.cyanAccent),
                      label: const Text('Google SSO', style: TextStyle(color: Colors.white, fontSize: 13)),
                      onPressed: () => _handleLogin(name: 'Google Analyst', email: 'google.analyst@yqsecurity.com'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.facebook, size: 20, color: Colors.blue),
                      label: const Text('Facebook', style: TextStyle(color: Colors.white, fontSize: 13)),
                      onPressed: () => _handleLogin(name: 'Facebook Analyst', email: 'fb.analyst@yqsecurity.com'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  setState(() {
                    isSignUpMode = !isSignUpMode;
                  });
                },
                child: Text(
                  isSignUpMode ? 'Already registered? Secure Login' : 'Need an analyst account? Sign Up',
                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String analystEmail;
  final String analystName;

  const DashboardScreen({
    Key? key,
    required this.analystEmail,
    required this.analystName,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String currentName;
  late String currentEmail;
  String profileImageUrl = '';
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    currentName = widget.analystName;
    currentEmail = widget.analystEmail;
  }

  void _showSettingsModal(BuildContext context) {
    final TextEditingController nameEditController = TextEditingController(text: currentName);
    final TextEditingController emailEditController = TextEditingController(text: currentEmail);
    final TextEditingController passEditController = TextEditingController();
    final TextEditingController imageEditController = TextEditingController(text: profileImageUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isArabic ? 'إعدادات الملف الشخصي والأمان' : 'SOC Analyst Settings & Profile', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
              const SizedBox(height: 16),
              TextField(
                controller: nameEditController,
                decoration: InputDecoration(labelText: isArabic ? 'تعديل اسم المستخدم' : 'Change Username', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailEditController,
                decoration: InputDecoration(labelText: isArabic ? 'تعديل البريد الإلكتروني' : 'Change Email', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passEditController,
                obscureText: true,
                decoration: InputDecoration(labelText: isArabic ? 'كلمة المرور الجديدة' : 'New Master Password', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageEditController,
                decoration: InputDecoration(labelText: isArabic ? 'رابط صورة البروفايل (Avatar URL)' : 'Profile Image URL', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () {
                    setState(() {
                      currentName = nameEditController.text;
                      currentEmail = emailEditController.text;
                      profileImageUrl = imageEditController.text;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isArabic ? 'تم تحديث الملف الشخصي بنجاح!' : 'Profile updated successfully!')),
                    );
                  },
                  child: Text(isArabic ? 'حفظ التعديلات' : 'Save Profile Settings'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'yqsecurity - مركز العمليات' : 'yqsecurity - Operations Hub'),
        centerTitle: true,
        backgroundColor: const Color(0xFF131B2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0A0F1D),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF131B2E)),
              accountName: Text(currentName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              accountEmail: Text(currentEmail, style: const TextStyle(color: Colors.cyanAccent)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                child: profileImageUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.cyanAccent),
              title: Text(isArabic ? 'الإعدادات والملف الشخصي' : 'Settings & Profile'),
              onTap: () {
                Navigator.pop(context);
                _showSettingsModal(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: Text(isArabic ? 'اللغة: العربية' : 'Language: English'),
              trailing: Switch(
                value: isArabic,
                onChanged: (val) {
                  setState(() {
                    isArabic = val;
                  });
                },
              ),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: Text(isArabic ? 'تسجيل الخروج' : 'Logout Securely'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isArabic ? 'المحلل النشط: $currentName' : 'Active Analyst: $currentName', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
            const SizedBox(height: 10),
            Text(isArabic ? 'أدوات الاستجابة السيبرانية المشفرة' : 'Encrypted SOC Toolkits', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 6),
            Text(isArabic ? 'اختر أداة التحليل المتقدمة أدناه:' : 'Select an advanced security engine below:', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(context, 'Advanced Suricata Rule Builder', 'Custom IPs, Protocols & Signatures', Icons.security, Colors.orangeAccent, SuricataScreen(isArabic: isArabic)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, 'Professional Wireshark Filter Engine', 'Capture & Display filters with descriptions', Icons.network_check, Colors.lightBlueAccent, WiresharkScreen(isArabic: isArabic)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, 'Splunk SPL Query Generator', 'Build enterprise security log queries dynamically', Icons.analytics, Colors.purpleAccent, SplunkScreen(isArabic: isArabic)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, 'IOCs & Threat Intelligence Hub', 'Searchable database of all cybersecurity attacks', Icons.menu_book, Colors.greenAccent, CheatSheetScreen(isArabic: isArabic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget targetScreen) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, color: color, size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        },
      ),
    );
  }
}

class SuricataScreen extends StatefulWidget {
  final bool isArabic;
  const SuricataScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _SuricataScreenState createState() => _SuricataScreenState();
}
class _SuricataScreenState extends State<SuricataScreen> {
  String selectedAction = 'alert';
  String selectedProtocol = 'tcp';
  final TextEditingController msgController = TextEditingController(text: 'Suspicious Web Attack');
  final TextEditingController contentController = TextEditingController(text: '/admin/shell.php');
  final TextEditingController sidController = TextEditingController(text: '200001');
  String generatedRule = '';

  @override
  void initState() {
    super.initState();
    updateRule();
  }

  void updateRule() {
    setState(() {
      generatedRule = '$selectedAction $selectedProtocol any any -> any 80 (msg:"${msgController.text}"; content:"${contentController.text}"; sid:${sidController.text}; rev:1;)';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مولد قواعد سوريكاتا' : 'Suricata Rule Builder'), backgroundColor: const Color(0xFF131B2E)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: msgController, decoration: InputDecoration(labelText: ar ? 'رسالة التنبيه' : 'Alert Message'), onChanged: (_) => updateRule()),
            const SizedBox(height: 12),
            TextField(controller: contentController, decoration: InputDecoration(labelText: ar ? 'محتوى التوقيع' : 'Content Pattern'), onChanged: (_) => updateRule()),
            const SizedBox(height: 12),
            TextField(controller: sidController, decoration: InputDecoration(labelText: ar ? 'رقم القاعدة SID' : 'Rule SID'), onChanged: (_) => updateRule()),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF131B2E), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(child: Text(generatedRule, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.orangeAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: generatedRule));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم النسخ!' : 'Copied!')));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WiresharkScreen extends StatefulWidget {
  final bool isArabic;
  const WiresharkScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _WiresharkScreenState createState() => _WiresharkScreenState();
}
class _WiresharkScreenState extends State<WiresharkScreen> {
  final List<Map<String, String>> filters = [
    {'type': 'Display Filter', 'title': 'HTTP POST', 'filter': 'http.request.method == "POST"', 'desc': 'Tracks HTTP post requests and forms.'},
    {'type': 'Display Filter', 'title': 'IP Address', 'filter': 'ip.addr == 192.168.1.100', 'desc': 'Isolates traffic for specific IP.'},
    {'type': 'Capture Filter', 'title': 'Web Traffic', 'filter': 'port 80 or port 443', 'desc': 'Captures web traffic only.'},
  ];

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'فلاتر وايرشاك' : 'Wireshark Filter Engine'), backgroundColor: const Color(0xFF131B2E)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f['title']!, style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(f['desc']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Expanded(child: Text(f['filter']!, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 12))),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.lightBlueAccent),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: f['filter']!));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم النسخ!' : 'Copied!')));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SplunkScreen extends StatefulWidget {
  final bool isArabic;
  const SplunkScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _SplunkScreenState createState() => _SplunkScreenState();
}
class _SplunkScreenState extends State<SplunkScreen> {
  final TextEditingController indexController = TextEditingController(text: 'index=security_logs');
  final TextEditingController searchController = TextEditingController(text: 'failed_login');
  String generatedSpl = '';

  @override
  void initState() {
    super.initState();
    updateSpl();
  }

  void updateSpl() {
    setState(() {
      generatedSpl = '${indexController.text} sourcetype=* | search ${searchController.text} | stats count by clientip | sort -count';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مولد Splunk' : 'Splunk SPL Generator'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: indexController, decoration: InputDecoration(labelText: ar ? 'الفهرس' : 'Splunk Index'), onChanged: (_) => updateSpl()),
            const SizedBox(height: 12),
            TextField(controller: searchController, decoration: InputDecoration(labelText: ar ? 'كلمة البحث' : 'Search Keyword'), onChanged: (_) => updateSpl()),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF131B2E), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(child: Text(generatedSpl, style: const TextStyle(fontFamily: 'monospace', color: Colors.purpleAccent, fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.purpleAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: generatedSpl));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم النسخ!' : 'Copied!')));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheatSheetScreen extends StatefulWidget {
  final bool isArabic;
  const CheatSheetScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _CheatSheetScreenState createState() => _CheatSheetScreenState();
}
class _CheatSheetScreenState extends State<CheatSheetScreen> {
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, String>> attacks = [
    {'title': 'Ransomware .locked', 'code': 'content:".locked";', 'desc': 'Detects ransomware file extensions.'},
    {'title': 'SQL Injection OR 1=1', 'code': 'content:"OR 1=1";', 'desc': 'Detects login bypass attempts.'},
    {'title': 'SSH Brute Force', 'code': 'threshold:type threshold, track by_src, count 5, seconds 60;', 'desc': 'Detects brute forcing.'},
  ];

  List<Map<String, String>> filteredAttacks = [];

  @override
  void initState() {
    super.initState();
    filteredAttacks = attacks;
    searchController.addListener(() {
      final q = searchController.text.toLowerCase();
      setState(() {
        filteredAttacks = attacks.where((item) => item['title']!.toLowerCase().contains(q) || item['desc']!.toLowerCase().contains(q)).toList();
      });
    });
  }

  void _showHelpDialog(BuildContext context, String title, String desc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: Text(title, style: const TextStyle(color: Colors.greenAccent)),
        content: Text(desc, style: const TextStyle(color: Colors.white70)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مكتبة مؤشرات الاختراق' : 'IOCs Hub'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: searchController, decoration: InputDecoration(labelText: ar ? 'بحث عن الهجمات...' : 'Search attacks...')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredAttacks.length,
                itemBuilder: (context, index) {
                  final att = filteredAttacks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(att['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15)),
                              IconButton(icon: const Icon(Icons.help_outline, color: Colors.orangeAccent), onPressed: () => _showHelpDialog(context, att['title']!, att['desc']!)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Expanded(child: Text(att['code']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white))),
                                IconButton(icon: const Icon(Icons.copy, size: 18, color: Colors.greenAccent), onPressed: () => Clipboard.setData(ClipboardData(text: att['code']!))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
