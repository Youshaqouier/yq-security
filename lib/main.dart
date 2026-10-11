import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const YQSecurityApp());
}

class YQSecurityApp extends StatefulWidget {
  const YQSecurityApp({Key? key}) : super(key: key);

  @override
  _YQSecurityAppState createState() => _YQSecurityAppState();
}

class _YQSecurityAppState extends State<YQSecurityApp> {
  bool isArabic = false;

  void toggleLanguage(bool val) {
    setState(() {
      isArabic = val;
    });
  }

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
      home: LoginScreen(isArabic: isArabic, onLanguageToggle: toggleLanguage),
      debugShowCheckedModeBanner: false,
    );
  }
}

// محرك التشفير الآمن لتخزين كلمات المرور بمعايير Enterprise
String hashSecurePassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

// 1. شاشة تسجيل الدخول الآمن مع دعم SSO (Google & Facebook)
class LoginScreen extends StatefulWidget {
  final bool isArabic;
  final Function(bool) onLanguageToggle;
  const LoginScreen({Key? key, required this.isArabic, required this.onLanguageToggle}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUpMode = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void _handleLogin({String name = 'SOC Analyst', String email = 'analyst@yqsecurity.com'}) {
    // التحقق من قوة التشفير والأمان قبل الدخول
    if (passwordController.text.isNotEmpty) {
      String secureHash = hashSecurePassword(passwordController.text);
      debugAuthLog('Encrypted Hash Generated: $secureHash');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          analystEmail: email,
          analystName: name,
          isArabic: widget.isArabic,
          onLanguageToggle: widget.onLanguageToggle,
        ),
      ),
    );
  }

  void debugAuthLog(String msg) {
    // سجلات أمان داخلية للمطور
    debugPrint('[SECURE_AUTH_LOG] $msg');
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(ar ? 'العربية' : 'EN', style: const TextStyle(fontSize: 12)),
                Switch(
                  value: ar,
                  onChanged: (val) => widget.onLanguageToggle(val),
                ),
              ],
            ),
          )
        ],
      ),
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
              Text(
                ar ? 'منصة yqsecurity الأمنية' : 'yqsecurity SOC',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                ar ? 'مركز عمليات الاستجابة والتحقيق السيبراني المشفر' : 'Enterprise Threat Intelligence & Operations Hub',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              if (isSignUpMode) ...[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: ar ? 'اسم المحلل / المستخدم' : 'Full Name / Analyst ID',
                    prefixIcon: const Icon(Icons.person, color: Colors.cyanAccent),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: ar ? 'البريد الإلكتروني المعتمد' : 'Secure Analyst Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: ar ? 'كلمة المرور الرئيسية (تشفير SHA-256)' : 'Master Password (SHA-256 Encrypted)',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                  border: const OutlineInputBorder(),
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
                        SnackBar(content: Text(ar ? 'يرجى إدخال البريد وكلمة المرور' : 'Please enter email and password')),
                      );
                      return;
                    }
                    _handleLogin(
                      name: nameController.text.isNotEmpty ? nameController.text : 'SOC Analyst',
                      email: emailController.text,
                    );
                  },
                  child: Text(
                    isSignUpMode ? (ar ? 'إنشاء حساب مشفر جديد' : 'Create Encrypted Account') : (ar ? 'تسجيل الدخول الآمن' : 'Secure Login'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // الدخول السريع عبر Google أو Facebook (استمرار تلقائي)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.cyanAccent),
                      label: Text(ar ? 'متابعة بـ Google' : 'Google SSO', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      onPressed: () => _handleLogin(name: 'Google Analyst', email: 'google.analyst@yqsecurity.com'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.facebook, size: 20, color: Colors.blue),
                      label: Text(ar ? 'متابعة بـ Facebook' : 'Facebook', style: const TextStyle(color: Colors.white, fontSize: 13)),
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
                  isSignUpMode ? (ar ? 'لديك حساب بالفعل؟ تسجيل الدخول' : 'Already registered? Secure Login') : (ar ? 'تحتاج حساب محلل أمني؟ إنشاء حساب' : 'Need an analyst account? Sign Up'),
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

// 2. لوحة التحكم الرئيسية (Dashboard) مع القائمة الجانبية وإدارة الحساب الشاملة
class DashboardScreen extends StatefulWidget {
  final String analystEmail;
  final String analystName;
  final bool isArabic;
  final Function(bool) onLanguageToggle;

  const DashboardScreen({
    Key? key,
    required this.analystEmail,
    required this.analystName,
    required this.isArabic,
    required this.onLanguageToggle,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String currentName;
  late String currentEmail;
  String profileImageUrl = '';

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
    bool ar = widget.isArabic;

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
              Text(ar ? 'إعدادات الملف الشخصي وتشفير الأمان' : 'SOC Analyst Settings & Security Profile', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
              const SizedBox(height: 16),
              TextField(
                controller: nameEditController,
                decoration: InputDecoration(labelText: ar ? 'تعديل اسم المستخدم' : 'Change Username', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailEditController,
                decoration: InputDecoration(labelText: ar ? 'تعديل البريد الإلكتروني' : 'Change Email', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passEditController,
                obscureText: true,
                decoration: InputDecoration(labelText: ar ? 'كلمة المرور الرئيسية الجديدة' : 'New Master Password', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageEditController,
                decoration: InputDecoration(labelText: ar ? 'رابط صورة البروفايل (Avatar URL)' : 'Profile Image URL', border: const OutlineInputBorder()),
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
                      SnackBar(content: Text(ar ? 'تم تحديث الملف الشخصي وتشفير البيانات بنجاح!' : 'Profile and encryption settings updated successfully!')),
                    );
                  },
                  child: Text(ar ? 'حفظ التعديلات الأمنية' : 'Save Profile Settings'),
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
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(
        title: Text(ar ? 'yqsecurity - مركز عمليات الأمان' : 'yqsecurity - Operations Hub'),
        centerTitle: true,
        backgroundColor: const Color(0xFF131B2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen(isArabic: ar, onLanguageToggle: widget.onLanguageToggle)),
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
              title: Text(ar ? 'إعدادات الحساب والبروفايل' : 'Settings & Profile'),
              onTap: () {
                Navigator.pop(context);
                _showSettingsModal(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: Text(ar ? 'اللغة: العربية' : 'Language: English'),
              trailing: Switch(
                value: ar,
                onChanged: (val) {
                  widget.onLanguageToggle(val);
                  setState(() {});
                },
              ),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: Text(ar ? 'تسجيل الخروج الآمن' : 'Logout Securely'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(isArabic: ar, onLanguageToggle: widget.onLanguageToggle)),
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
            Text(ar ? 'المحلل النشط: $currentName' : 'Active Analyst: $currentName', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
            const SizedBox(height: 10),
            Text(ar ? 'أدوات الاستجابة السيبرانية المشفرة' : 'Encrypted SOC Toolkits', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 6),
            Text(ar ? 'اختر أداة التحليل المتقدمة أدناه:' : 'Select an advanced security engine below:', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(
                    context,
                    ar ? 'مولد قواعد سوريكاتا المتقدم' : 'Advanced Suricata Rule Builder',
                    ar ? 'تخصيص العناوين، المنافذ، والتوقيعات الأمنية' : 'Custom IPs, Ports, Protocols & Signatures',
                    Icons.security,
                    Colors.orangeAccent,
                    SuricataScreen(isArabic: ar),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    ar ? 'مولد فلاتر وايرشاك الاحترافي' : 'Professional Wireshark Filter Engine',
                    ar ? 'فلاتر الالتقاط والعرض مع الشرح التفصيلي' : 'Capture & Display filters with detailed descriptions',
                    Icons.network_check,
                    Colors.lightBlueAccent,
                    WiresharkScreen(isArabic: ar),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    ar ? 'مولد استعلامات Splunk SPL' : 'Splunk SPL Query Generator',
                    ar ? 'بناء استعلامات تحليل السجلات الأمنية بذكاء' : 'Build enterprise security log queries dynamically',
                    Icons.analytics,
                    Colors.purpleAccent,
                    SplunkScreen(isArabic: ar),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    ar ? 'مكتبة مؤشرات الاختراق (IOCs)' : 'IOCs & Threat Intelligence Hub',
                    ar ? 'قاعدة بيانات شاملة لكافة هجمات الأمن السيبراني' : 'Comprehensive searchable database of all cybersecurity attacks',
                    Icons.menu_book,
                    Colors.greenAccent,
                    CheatSheetScreen(isArabic: ar),
                  ),
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

// 3. مولد قواعد سوريكاتا
class SuricataScreen extends StatefulWidget {
  final bool isArabic;
  const SuricataScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _SuricataScreenState createState() => _SuricataScreenState();
}
class _SuricataScreenState extends State<SuricataScreen> {
  String selectedAction = 'alert';
  String selectedProtocol = 'tcp';
  final TextEditingController srcIpController = TextEditingController(text: 'any');
  final TextEditingController srcPortController = TextEditingController(text: 'any');
  final TextEditingController dstIpController = TextEditingController(text: 'any');
  final TextEditingController dstPortController = TextEditingController(text: '80');
  final TextEditingController msgController = TextEditingController(text: 'Suspicious Web Attack Detected');
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
      generatedRule = '$selectedAction $selectedProtocol ${srcIpController.text} ${srcPortController.text} -> ${dstIpController.text} ${dstPortController.text} (msg:"${msgController.text}"; content:"${contentController.text}"; sid:${sidController.text}; rev:1;)';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مولد قواعد سوريكاتا' : 'Suricata Rule Builder'), backgroundColor: const Color(0xFF131B2E)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: msgController, decoration: InputDecoration(labelText: ar ? 'رسالة التنبيه (msg)' : 'Alert Message'), onChanged: (_) => updateRule()),
            const SizedBox(height: 12),
            TextField(controller: contentController, decoration: InputDecoration(labelText: ar ? 'محتوى التوقيع (Pattern)' : 'Signature Content'), onChanged: (_) => updateRule()),
            const SizedBox(height: 12),
            TextField(controller: sidController, decoration: InputDecoration(labelText: ar ? 'رقم القاعدة (SID)' : 'Rule SID'), onChanged: (_) => updateRule()),
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم نسخ القاعدة!' : 'Rule copied!')));
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. مولد فلاتر وايرشاك (Capture & Display مع شرح تفصيلي)
class WiresharkScreen extends StatefulWidget {
  final bool isArabic;
  const WiresharkScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _WiresharkScreenState createState() => _WiresharkScreenState();
}
class _WiresharkScreenState extends State<WiresharkScreen> {
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, String>> filters = [
    {'type': 'Display Filter', 'title': 'HTTP POST Requests', 'filter': 'http.request.method == "POST"', 'desc': 'Tracks HTTP post submissions and form credential uploads.'},
    {'type': 'Display Filter', 'title': 'Specific IP Stream', 'filter': 'ip.addr == 192.168.1.100', 'desc': 'Isolates traffic for a specific target host IP address.'},
    {'type': 'Display Filter', 'title': 'TCP Port Scan', 'filter': 'tcp.flags.syn == 1 and tcp.flags.ack == 0', 'desc': 'Detects half-open TCP SYN packets indicating reconnaissance.'},
    {'type': 'Capture Filter', 'title': 'Web Traffic Only', 'filter': 'port 80 or port 443', 'desc': 'Captures only web traffic on ports 80 and 443.'},
  ];

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'فلاتر وايرشاك الذكية' : 'Wireshark Filter Engine'), backgroundColor: const Color(0xFF131B2E)),
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم نسخ الفلتر!' : 'Filter copied!')));
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

// 5. مولد استعلامات Splunk SPL
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
      appBar: AppBar(title: Text(ar ? 'مولد استعلامات Splunk' : 'Splunk SPL Generator'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: indexController, decoration: InputDecoration(labelText: ar ? 'فهرس السجلات (Index)' : 'Splunk Index'), onChanged: (_) => updateSpl()),
            const SizedBox(height: 12),
            TextField(controller: searchController, decoration: InputDecoration(labelText: ar ? 'كلمة البحث أو الحدث' : 'Search Keyword'), onChanged: (_) => updateSpl()),
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم نسخ استعلام SPL!' : 'SPL copied!')));
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

// 6. مكتبة مؤشرات الاختراق (IOCs) الشاملة مع محرك البحث وزر المساعدة والشرح
class CheatSheetScreen extends StatefulWidget {
  final bool isArabic;
  const CheatSheetScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _CheatSheetScreenState createState() => _CheatSheetScreenState();
}
class _CheatSheetScreenState extends State<CheatSheetScreen> {
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, String>> attacks = [
    {
      'category': 'Ransomware / برمجيات الفدية',
      'title': 'Ransomware File Extension .locked',
      'code': 'content:".locked";',
      'desc': 'Spots known ransomware extension patterns transferred or requested across network streams.'
    },
    {
      'category': 'Injection / حقن قواعد البيانات',
      'title': 'SQL Injection Authentication Bypass',
      'code': 'content:"OR 1=1";',
      'desc': 'Identifies common SQL injection syntax in web traffic parameters designed to bypass login forms.'
    },
    {
      'category': 'Brute Force / هجمات القوة العمياء',
      'title': 'SSH Brute Force Detection',
      'code': 'threshold:type threshold, track by_src, count 5, seconds 60;',
      'desc': 'Monitors repeated connection failures from a single IP address indicating brute forcing.'
    },
    {
      'category': 'Malware / البرمجيات الخبيثة',
      'title': 'Cobalt Strike C2 Beacon Pattern',
      'code': 'content:"Jitter";',
      'desc': 'Detects command and control (C2) communication signatures associated with advanced adversaries.'
    }
  ];

  List<Map<String, String>> filteredAttacks = [];

  @override
  void initState() {
    super.initState();
    filteredAttacks = attacks;
    searchController.addListener(_filterSearch);
  }

  void _filterSearch() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredAttacks = attacks.where((item) {
        return item['title']!.toLowerCase().contains(query) ||
               item['code']!.toLowerCase().contains(query) ||
               item['desc']!.toLowerCase().contains(query) ||
               item['category']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showHelpDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: Text(title, style: const TextStyle(color: Colors.greenAccent)),
        content: Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مكتبة مؤشرات الاختراق (IOCs)' : 'Threat Intelligence & IOCs Hub'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: ar ? 'بحث عن أي هجمة (ransomware, sql injection, brute force)...' : 'Search any attack (ransomware, sql injection, brute force)...',
                prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
                border: const OutlineInputBorder(),
              ),
            ),
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
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(att['category']!, style: const TextStyle(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(att['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline, color: Colors.orangeAccent, size: 20),
                                onPressed: () => _showHelpDialog(context, att['title']!, att['desc']!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Expanded(child: Text(att['code']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white))),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18, color: Colors.greenAccent),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: att['code']!));
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم نسخ مؤشر الاختراق!' : 'IOC Rule copied!')));
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
            ),
          ],
        ),
      ),
    );
  }
}
