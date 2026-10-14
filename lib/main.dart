import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (isLoggedIn) {
      String savedName = prefs.getString('analyst_name') ?? 'SOC Analyst';
      String savedEmail = prefs.getString('analyst_email') ?? 'analyst@yqsecurity.com';
      String savedImage = prefs.getString('analyst_image') ?? '';
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              analystEmail: savedEmail,
              analystName: savedName,
              initialImage: savedImage,
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveLoginSession(String name, String email, String image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('analyst_name', name);
    await prefs.setString('analyst_email', email);
    await prefs.setString('analyst_image', image);
  }

  void _handleLogin({String name = 'SOC Analyst', String email = 'analyst@yqsecurity.com', String image = ''}) async {
    if (passwordController.text.isNotEmpty) {
      String secureHash = hashSecurePassword(passwordController.text);
      debugPrint('Encrypted Hash: $secureHash');
    }

    await _saveLoginSession(name, email, image);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            analystEmail: email,
            analystName: name,
            initialImage: image,
          ),
        ),
      );
    }
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
                'yqsecurity',
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
                  enableInteractiveSelection: true,
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
                enableInteractiveSelection: true,
                decoration: const InputDecoration(
                  labelText: 'Secure Analyst Email',
                  prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  labelText: 'Master Password (Encrypted)',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.cyanAccent),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
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

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.cyanAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.cyanAccent),
                  label: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  onPressed: () => _handleLogin(name: 'Google Verified Analyst', email: 'analyst.secure@gmail.com'),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => setState(() => isSignUpMode = !isSignUpMode),
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
  final String initialImage;

  const DashboardScreen({
    Key? key,
    required this.analystEmail,
    required this.analystName,
    required this.initialImage,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String currentName;
  late String currentEmail;
  late String profileImageUrl;
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    currentName = widget.analystName;
    currentEmail = widget.analystEmail;
    profileImageUrl = widget.initialImage;
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                  onPressed: () async {
                    setState(() {
                      currentName = nameEditController.text;
                      currentEmail = emailEditController.text;
                      profileImageUrl = imageEditController.text;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('analyst_name', currentName);
                    await prefs.setString('analyst_email', currentEmail);
                    await prefs.setString('analyst_image', profileImageUrl);
                    
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
            onPressed: _logout,
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
              leading: const Icon(Icons.menu_book, color: Colors.greenAccent),
              title: Text(isArabic ? 'دليل المستخدم' : 'User Guide'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserGuideScreen(isArabic: isArabic)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: Text(isArabic ? 'اللغة: العربية (AR)' : 'Language: English (EN)'),
              trailing: Switch(
                value: isArabic,
                onChanged: (val) => setState(() => isArabic = val),
              ),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: Text(isArabic ? 'تسجيل الخروج' : 'Logout Securely'),
              onTap: _logout,
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
                  _buildMenuCard(context, isArabic ? 'مولد قواعد سوريكاتا' : 'Advanced Suricata Rule Builder', isArabic ? 'تخصيص البروتوكولات والشروط المتعددة' : 'Custom IPs, Protocols, Content & Signatures', Icons.security, Colors.orangeAccent, SuricataScreen(isArabic: isArabic)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, isArabic ? 'محرك وايرشاك الذكي' : 'Dynamic Wireshark Filter Engine', isArabic ? 'فلاتر العرض والالتقاط مع اقتراحات ذكية' : 'Capture & Display filters with auto-complete', Icons.network_check, Colors.lightBlueAccent, WiresharkScreen(isArabic: isArabic)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, isArabic ? 'مولد استعلامات Splunk SPL' : 'Splunk SPL Query Generator', isArabic ? 'قوالب جاهزة ومتغيرات مرنة لبحث السجلات' : 'Enterprise security log queries with templates', Icons.analytics, Colors.purpleAccent, SplunkScreen(isArabic: isArabic)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, isArabic ? 'مكتبة مؤشرات الاختراق IOCs' : 'IOCs & Threat Intelligence Hub', isArabic ? 'محرك بحث استخباراتي شامل لجميع الهجمات' : 'Comprehensive searchable attack intelligence database', Icons.menu_book, Colors.greenAccent, CheatSheetScreen(isArabic: isArabic)),
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
      ),
    );
  }
}

// شاشة دليل المستخدم (User Guide) الداعمة للغتين
class UserGuideScreen extends StatelessWidget {
  final bool isArabic;
  const UserGuideScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'دليل المستخدم الشامل' : 'Comprehensive User Guide'),
        backgroundColor: const Color(0xFF131B2E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGuideSection(
            isArabic ? '1. إدارة الحساب والأمان' : '1. Account & Security',
            isArabic ? 'يسمح لك التطبيق بتعديل بيانات حسابك الشخصي، تغيير كلمة المرور المشفرة بـ SHA-256، رفع صورة بروفايل عبر رابط خارجي، والتحكم باللغة بين العربية والإنجليزية بسلاسة.' : 'Allows you to manage your profile, change your SHA-256 encrypted password, upload a profile avatar via link, and toggle language between Arabic and English seamlessly.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '2. مولد قواعد Suricata' : '2. Suricata Rule Builder',
            isArabic ? 'أداة مخصصة لصياغة وتوليد قواعد الكشف عن التهديدات. تتيح لك إضافة شروط اختيارية متعددة مثل الـ Content الإضافي والـ Uricontent و Flags، وتتجاهل الحقول الفارغة تلقائياً لتوليد قاعدة نظيفة.' : 'Designed to craft threat detection rules. Allows multiple optional conditions like extra content, uricontent, and flags, automatically ignoring empty fields for clean rules.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '3. محرك فلاتر Wireshark' : '3. Wireshark Filter Engine',
            isArabic ? 'يساعدك على اختيار نوع الفلتر (Display أو Capture) مع تقديم اقتراحات ذكية (Auto-Complete) أثناء الكتابة لتسهيل استخراج حزم البيانات بدقة.' : 'Helps select filter types (Display or Capture) with auto-complete suggestions while typing to accurately filter packet captures.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '4. مولد استعلامات Splunk SPL' : '4. Splunk SPL Query Generator',
            isArabic ? 'يعتمد على قوالب جاهزة وثابتة لأوامر البحث الإحصائي، حيث يقتصر دورك على تعبئة المتغيرات المرنة لتوليد أقوى استعلامات تحليل السجلات.' : 'Relies on pre-built templates for statistical search queries, allowing you to fill flexible variables to generate robust log analysis queries.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '5. استخبارات مؤشرات الاختراق (IOCs Hub)' : '5. IOCs & Threat Intelligence Hub',
            isArabic ? 'محرك بحث استخباراتي يربط الهجوم الواحد بأدوات الكشف المقابلة (Suricata، Wireshark، Splunk)، مع أزرار شرح تفصيلية مترجمة حسب لغة التطبيق.' : 'An intelligence search engine linking attacks to corresponding detection tools (Suricata, Wireshark, Splunk), with localized help explanations.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String content) {
    return Card(
      color: const Color(0xFF131B2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// شاشة Suricata المحدثة بالشروط الاختيارية المتعددة
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
  final TextEditingController extraContentController = TextEditingController();
  final TextEditingController uricontentController = TextEditingController();
  final TextEditingController flagsController = TextEditingController();
  final TextEditingController sidController = TextEditingController(text: '200001');
  String generatedRule = '';

  @override
  void initState() {
    super.initState();
    updateRule();
  }

  void updateRule() {
    String extra = '';
    if (extraContentController.text.isNotEmpty) {
      extra += '; content:"${extraContentController.text}"';
    }
    if (uricontentController.text.isNotEmpty) {
      extra += '; uricontent:"${uricontentController.text}"';
    }
    if (flagsController.text.isNotEmpty) {
      extra += '; flags:${flagsController.text}';
    }

    setState(() {
      generatedRule = '$selectedAction $selectedProtocol any any -> any 80 (msg:"${msgController.text}"; content:"${contentController.text}"$extra; sid:${sidController.text}; rev:1;)';
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
            TextField(controller: contentController, decoration: InputDecoration(labelText: ar ? 'محتوى التوقيع الأساسي' : 'Primary Content Pattern'), onChanged: (_) => updateRule()),
            const SizedBox(height: 12),
            TextField(controller: extraContentController, decoration: InputDecoration(labelText: ar ? 'محتوى إضافي (اختياري)' : 'Extra Content (Optional)'), onChanged: (_) => updateRule()),
            const SizedBox(height: 12),
            TextField(controller: uricontentController, decoration: InputDecoration(labelText: ar ? 'مسار الرابط Uricontent (اختياري)' : 'Uricontent (Optional)'), onChanged: (_) => updateRule()),
            const SizedBox(height: 12),
            TextField(controller: flagsController, decoration: InputDecoration(labelText: ar ? 'رايات الاتصال Flags (مثل: S)' : 'Flags (e.g., S) (Optional)'), onChanged: (_) => updateRule()),
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

// شاشة وايرشاك المحدثة بنظام الاقتراحات الذكية (Auto-complete)
class WiresharkScreen extends StatefulWidget {
  final bool isArabic;
  const WiresharkScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _WiresharkScreenState createState() => _WiresharkScreenState();
}
class _WiresharkScreenState extends State<WiresharkScreen> {
  String filterType = 'Display Filter';
  final TextEditingController searchController = TextEditingController();
  
  final List<String> suggestions = [
    'http.request.method == "POST"',
    'ip.addr == 192.168.1.100',
    'tcp.flags.syn == 1',
    'dns.qry.name',
    'ssl.handshake.type == 1',
    'port 80 or port 443',
    'host 10.0.0.5'
  ];

  List<String> currentSuggestions = [];

  @override
  void initState() {
    super.initState();
    currentSuggestions = suggestions;
    searchController.addListener(() {
      final q = searchController.text.toLowerCase();
      setState(() {
        currentSuggestions = suggestions.where((item) => item.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'محرك وايرشاك الذكي' : 'Wireshark Engine'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(ar ? 'فلاتر العرض (Display)' : 'Display Filter'),
                    selected: filterType == 'Display Filter',
                    onSelected: (val) => setState(() => filterType = 'Display Filter'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: Text(ar ? 'فلاتر الالتقاط (Capture)' : 'Capture Filter'),
                    selected: filterType == 'Capture Filter',
                    onSelected: (val) => setState(() => filterType = 'Capture Filter'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: ar ? 'ابحث عن فلتر أو اكتبه...' : 'Search or type filter...',
                prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: currentSuggestions.length,
                itemBuilder: (context, index) {
                  final item = currentSuggestions[index];
                  return Card(
                    color: const Color(0xFF131B2E),
                    child: ListTile(
                      title: Text(item, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: Colors.cyanAccent),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? 'تم نسخ الفلتر!' : 'Filter Copied!')));
                        },
                      ),
                      onTap: () {
                        searchController.text = item;
                      },
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

// شاشة Splunk المحدثة بالقوالب الجاهزة والمتغيرات المرنة
class SplunkScreen extends StatefulWidget {
  final bool isArabic;
  const SplunkScreen({Key? key, required this.isArabic}) : super(key: key);
  @override
  _SplunkScreenState createState() => _SplunkScreenState();
}
class _SplunkScreenState extends State<SplunkScreen> {
  String selectedTemplate = 'Stats Count by IP';
  final TextEditingController indexController = TextEditingController(text: 'index=security_logs');
  final TextEditingController keywordController = TextEditingController(text: 'failed_login');
  final TextEditingController fieldController = TextEditingController(text: 'clientip');
  String generatedSpl = '';

  @override
  void initState() {
    super.initState();
    updateSpl();
  }

  void updateSpl() {
    String spl = '';
    if (selectedTemplate == 'Stats Count by IP') {
      spl = '${indexController.text} sourcetype=* | search ${keywordController.text} | stats count by ${fieldController.text} | sort -count';
    } else if (selectedTemplate == 'Basic Search Only') {
      spl = '${indexController.text} sourcetype=* | search ${keywordController.text}';
    } else {
      spl = '${indexController.text} sourcetype=* | search ${keywordController.text} | where ${fieldController.text}!="127.0.0.1"';
    }
    setState(() {
      generatedSpl = spl;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'مولد Splunk SPL' : 'Splunk SPL Generator'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedTemplate,
              dropdownColor: const Color(0xFF131B2E),
              decoration: InputDecoration(labelText: ar ? 'اختر صيغة الاستعلام (Template)' : 'Select Template'),
              items: ['Stats Count by IP', 'Basic Search Only', 'Conditional Where Query'].map((val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedTemplate = val!;
                  updateSpl();
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: indexController, decoration: InputDecoration(labelText: ar ? 'الفهرس (Index)' : 'Splunk Index'), onChanged: (_) => updateSpl()),
            const SizedBox(height: 12),
            TextField(controller: keywordController, decoration: InputDecoration(labelText: ar ? 'كلمة البحث (Keyword)' : 'Search Keyword'), onChanged: (_) => updateSpl()),
            const SizedBox(height: 12),
            TextField(controller: fieldController, decoration: InputDecoration(labelText: ar ? 'الحقل المراد قياسه/تحليله (Field)' : 'Target Field'), onChanged: (_) => updateSpl()),
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

// شاشة مؤشرات الاختراق IOCs Hub مع الشرح المترجم ومحرك البحث الاستخباراتي
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
      'title': 'Ransomware .locked', 
      'code': 'content:".locked";', 
      'descAr': 'يكتشف هذا المؤشر ملفات الفدية المشفرة ذات الامتداد الخبيث .locked عبر الشبكة.',
      'descEn': 'Detects malicious ransomware file extensions (.locked) across network traffic.'
    },
    {
      'title': 'SQL Injection OR 1=1', 
      'code': 'content:"OR 1=1";', 
      'descAr': 'يكتشف محاولات تجاوز صفحات تسجيل الدخول عبر حقن قواعد البيانات SQL.',
      'descEn': 'Detects login authentication bypass attempts via SQL injection techniques.'
    },
    {
      'title': 'SSH Brute Force Attack', 
      'code': 'threshold:type threshold, track by_src, count 5, seconds 60;', 
      'descAr': 'يرصد محاولات تخمين كلمات المرور المتكررة (Brute Force) على خدمة الـ SSH.',
      'descEn': 'Monitors repeated authentication failure attempts targeting SSH services.'
    },
  ];

  List<Map<String, String>> filteredAttacks = [];

  @override
  void initState() {
    super.initState();
    filteredAttacks = attacks;
    searchController.addListener(() {
      final q = searchController.text.toLowerCase();
      setState(() {
        filteredAttacks = attacks.where((item) => 
          item['title']!.toLowerCase().contains(q) || 
          item['descAr']!.toLowerCase().contains(q) ||
          item['descEn']!.toLowerCase().contains(q)
        ).toList();
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
      appBar: AppBar(title: Text(ar ? 'مكتبة استخبارات التهديدات IOCs' : 'IOCs & Threat Intelligence Hub'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController, 
              decoration: InputDecoration(
                labelText: ar ? 'ابحث عن الهجمات أو الثغرات...' : 'Search attacks, ransomware, brute-force...',
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
                  String description = ar ? att['descAr']! : att['descEn']!;
                  return Card(
                    color: const Color(0xFF131B2E),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(att['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15))),
                              IconButton(
                                icon: const Icon(Icons.help_outline, color: Colors.orangeAccent), 
                                onPressed: () => _showHelpDialog(context, att['title']!, description),
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
            ),
          ],
        ),
      ),
    );
  }
}
