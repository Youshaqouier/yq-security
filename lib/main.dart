import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  // جلب قائمة الحسابات المخزنة محلياً لتعدد المستخدمين
  Future<List<Map<String, String>>> _getStoredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('registered_users');
    if (usersJson == null) {
      // الحساب الافتراضي التجريبي
      return [
        {
          'email': 'analyst@yqsecurity.com',
          'password': hashSecurePassword('admin123'),
          'name': 'SOC Analyst'
        }
      ];
    }
    List<dynamic> decoded = jsonDecode(usersJson);
    return decoded.map((item) => Map<String, String>.from(item as Map)).toList();
  }

  Future<void> _handleAuthAction() async {
    final prefs = await SharedPreferences.getInstance();
    String email = emailController.text.trim();
    String pass = passwordController.text;
    String name = nameController.text.isNotEmpty ? nameController.text : 'SOC Analyst';

    if (email.isEmpty || pass.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid email and password'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    List<Map<String, String>> users = await _getStoredUsers();
    String hashedInputPass = hashSecurePassword(pass);

    if (isSignUpMode) {
      // التحقق مما إذا كان البريد موجوداً مسبقاً
      bool exists = users.any((u) => u['email'] == email);
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already exists! Please login.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // إضافة الحساب الجديد للقائمة دون مسح الحسابات السابقة
      users.add({
        'email': email,
        'password': hashedInputPass,
        'name': name,
      });

      await prefs.setString('registered_users', jsonEncode(users));
      await prefs.setString('analyst_email', email);
      await prefs.setString('analyst_name', name);
      await prefs.setBool('is_logged_in', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              analystEmail: email,
              analystName: name,
              initialImage: '',
            ),
          ),
        );
      }
    } else {
      // وضع تسجيل الدخول - التحقق من مطابقة الحساب ضمن القائمة أو الحساب الافتراضي
      var matchedUser = users.firstWhere(
        (u) => u['email'] == email && u['password'] == hashedInputPass,
        orElse: () => {},
      );

      if (matchedUser.isNotEmpty) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('analyst_email', email);
        await prefs.setString('analyst_name', matchedUser['name'] ?? 'SOC Analyst');
        
        String image = prefs.getString('analyst_image') ?? '';
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                analystEmail: email,
                analystName: matchedUser['name'] ?? 'SOC Analyst',
                initialImage: image,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid Email or Password! Access Denied.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
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
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Master Password',
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
                  onPressed: _handleAuthAction,
                  child: Text(
                    isSignUpMode ? 'Register Account' : 'Secure Login',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => setState(() => isSignUpMode = !isSignUpMode),
                child: Text(
                  isSignUpMode ? 'Already have an account? Secure Login' : 'Need an analyst account? Sign Up',
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
  late String profileImagePath;
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    currentName = widget.analystName;
    currentEmail = widget.analystEmail;
    profileImagePath = widget.initialImage;
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImagePath = image.path;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('analyst_image', profileImagePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم تحديث الصورة الشخصية بنجاح!' : 'Profile image updated successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () async {
                    setState(() {
                      currentName = nameEditController.text;
                      currentEmail = emailEditController.text;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('analyst_name', currentName);
                    await prefs.setString('analyst_email', currentEmail);
                    
                    // تحديث كلمة المرور في القائمة المخزنة أيضاً
                    if (passEditController.text.isNotEmpty) {
                      String newHash = hashSecurePassword(passEditController.text);
                      String? usersJson = prefs.getString('registered_users');
                      if (usersJson != null) {
                        List<dynamic> decoded = jsonDecode(usersJson);
                        List<Map<String, String>> users = decoded.map((item) => Map<String, String>.from(item as Map)).toList();
                        for (var u in users) {
                          if (u['email'] == currentEmail) {
                            u['password'] = newHash;
                          }
                        }
                        await prefs.setString('registered_users', jsonEncode(users));
                      }
                    }
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'تم تحديث الملف الشخصي بنجاح!' : 'Profile updated successfully!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
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
              currentAccountPicture: GestureDetector(
                onTap: _pickImageFromGallery,
                child: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  backgroundImage: profileImagePath.isNotEmpty 
                      ? (profileImagePath.startsWith('http') ? NetworkImage(profileImagePath) : FileImage(File(profileImagePath)) as ImageProvider)
                      : null,
                  child: profileImagePath.isEmpty ? const Icon(Icons.camera_alt, size: 30, color: Colors.white) : null,
                ),
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
            Text(isArabic ? 'أدوات الاستجابة السيبرانية' : 'SOC Toolkits', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 6),
            Text(isArabic ? 'اختر أداة التحليل المتقدمة أدناه:' : 'Select an advanced security engine below:', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(context, isArabic ? 'مولد قواعد سوريكاتا' : 'Advanced Suricata Rule Builder', isArabic ? 'التحكم الكامل بالبروتوكولات والمنافذ وعناوين IP' : 'Full control over Protocols, IPs, Ports & Signatures', Icons.security, Colors.orangeAccent, SuricataScreen(isArabic: isArabic)),
                  const SizedBox(height: 12),
                  _buildMenuCard(context, isArabic ? 'محرك فلاتر وايرشاك الذكي' : 'Dynamic Wireshark Filter Engine', isArabic ? 'جميع فلاتر العرض والالتقاط مع بحث فوري' : 'All Display & Capture filters with instant search', Icons.network_check, Colors.lightBlueAccent, WiresharkSelectionScreen(isArabic: isArabic)),
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
            isArabic ? 'تسجيل عدة حسابات وتأمين كلمات المرور بـ SHA-256، والنقر على دائرة البروفايل لاختيار صورة من ذاكرة الهاتف.' : 'Register multiple accounts, secure passwords via SHA-256, and tap the profile avatar to pick images from storage.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '2. مولد قواعد Suricata' : '2. Suricata Rule Builder',
            isArabic ? 'تحكم كامل بالعمليات، البروتوكولات، ومنافذ وعناوين IP للمصدر والهدف مع الشروط الإضافية.' : 'Full control over actions, protocols, source/destination IPs and ports with extra conditions.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '3. محرك فلاتر Wireshark' : '3. Wireshark Filter Engine',
            isArabic ? 'اختيار فلاتر العرض أو الالتقاط للوصول إلى قاعدة بيانات شاملة مع بحث فوري.' : 'Choose display or capture filters accessing a comprehensive database with instant search.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '4. مولد استعلامات Splunk SPL' : '4. Splunk SPL Query Generator',
            isArabic ? 'قوالب جاهزة ومتغيرات مرنة لاستخراج الإحصائيات وتحليل السجلات الأمنية.' : 'Pre-built templates and flexible variables for security log analysis.',
          ),
          const SizedBox(height: 12),
          _buildGuideSection(
            isArabic ? '5. استخبارات مؤشرات الاختراق (IOCs Hub)' : '5. IOCs & Threat Intelligence Hub',
            isArabic ? 'محرك بحث استخباراتي شامل لجميع هجمات الأمن السيبراني؛ تظهر النتائج حصراً عند البحث.' : 'Comprehensive intelligence search engine for cyber attacks; results appear upon search.',
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

    String sIp = srcIpController.text.isEmpty ? 'any' : srcIpController.text;
    String sPort = srcPortController.text.isEmpty ? 'any' : srcPortController.text;
    String dIp = dstIpController.text.isEmpty ? 'any' : dstIpController.text;
    String dPort = dstPortController.text.isEmpty ? 'any' : dstPortController.text;

    setState(() {
      generatedRule = '$selectedAction $selectedProtocol $sIp $sPort -> $dIp $dPort (msg:"${msgController.text}"; content:"${contentController.text}"$extra; sid:${sidController.text}; rev:1;)';
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAction,
                    dropdownColor: const Color(0xFF131B2E),
                    decoration: InputDecoration(labelText: ar ? 'العملية (Action)' : 'Action'),
                    items: ['alert', 'drop', 'pass', 'log'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (val) { setState(() { selectedAction = val!; updateRule(); }); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedProtocol,
                    dropdownColor: const Color(0xFF131B2E),
                    decoration: InputDecoration(labelText: ar ? 'البروتوكول' : 'Protocol'),
                    items: ['tcp', 'udp', 'icmp', 'http', 'tls'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (val) { setState(() { selectedProtocol = val!; updateRule(); }); },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: srcIpController, decoration: InputDecoration(labelText: ar ? 'IP المصدر' : 'Source IP'), onChanged: (_) => updateRule())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: srcPortController, decoration: InputDecoration(labelText: ar ? 'منفذ المصدر' : 'Source Port'), onChanged: (_) => updateRule())),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: dstIpController, decoration: InputDecoration(labelText: ar ? 'IP الهدف' : 'Dest IP'), onChanged: (_) => updateRule())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: dstPortController, decoration: InputDecoration(labelText: ar ? 'منفذ الهدف' : 'Dest Port'), onChanged: (_) => updateRule())),
              ],
            ),
            const SizedBox(height: 12),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ar ? 'تم النسخ!' : 'Copied!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
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

class WiresharkSelectionScreen extends StatelessWidget {
  final bool isArabic;
  const WiresharkSelectionScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool ar = isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'محرك فلاتر وايرشاك' : 'Wireshark Engine'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ar ? 'اختر نوع الفلتر للبدء بالبحث والاستكشاف:' : 'Select filter type to begin search & exploration:', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.cyanAccent)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: Text(ar ? 'فلاتر العرض (Display Filters)' : 'Display Filters', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WiresharkSearchScreen(filterType: 'Display', isArabic: ar)));
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                label: Text(ar ? 'فلاتر الالتقاط (Capture Filters)' : 'Capture Filters', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WiresharkSearchScreen(filterType: 'Capture', isArabic: ar)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WiresharkSearchScreen extends StatefulWidget {
  final String filterType;
  final bool isArabic;
  const WiresharkSearchScreen({Key? key, required this.filterType, required this.isArabic}) : super(key: key);

  @override
  _WiresharkSearchScreenState createState() => _WiresharkSearchScreenState();
}

class _WiresharkSearchScreenState extends State<WiresharkSearchScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<String> displayFilters = [
    'http.request.method == "POST"',
    'http.request.method == "GET"',
    'ip.addr == 192.168.1.100',
    'ip.src == 10.0.0.1',
    'ip.dst == 8.8.8.8',
    'tcp.flags.syn == 1',
    'tcp.flags.reset == 1',
    'tcp.port == 443',
    'udp.port == 53',
    'dns.qry.name',
    'ssl.handshake.type == 1',
    'http.uri contains "admin"',
    'arp.opcode == 1',
    'icmp.type == 8',
    'ftp.request.command',
    'smb.cmd == 0xa2',
    'dhcp.id'
  ];

  final List<String> captureFilters = [
    'host 192.168.1.1',
    'src net 192.168.0.0/16',
    'dst port 80',
    'tcp port 443',
    'udp port 53',
    'icmp',
    'broadcast',
    'multicast',
    'not port 22',
    'tcp[tcpflags] & (tcp-syn) != 0'
  ];

  late List<String> allFilters;
  List<String> currentFilters = [];

  @override
  void initState() {
    super.initState();
    allFilters = widget.filterType == 'Display' ? displayFilters : captureFilters;
    currentFilters = allFilters;
    searchController.addListener(() {
      final q = searchController.text.toLowerCase();
      setState(() {
        currentFilters = allFilters.where((item) => item.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool ar = widget.isArabic;
    String title = widget.filterType == 'Display' 
        ? (ar ? 'فلاتر العرض (Display Filters)' : 'Display Filters Hub')
        : (ar ? 'فلاتر الالتقاط (Capture Filters)' : 'Capture Filters Hub');

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: ar ? 'ابحث عن أي فلتر شبكي (اكتب أي حرف)...' : 'Search any filter (type any letter)...',
                prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: currentFilters.length,
                itemBuilder: (context, index) {
                  final item = currentFilters[index];
                  return Card(
                    color: const Color(0xFF131B2E),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: Colors.cyanAccent),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ar ? 'تم نسخ الفلتر!' : 'Filter Copied!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ar ? 'تم النسخ!' : 'Copied!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
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
  
  final List<Map<String, String>> allAttacks = [
    {
      'title': 'Ransomware .locked Detection', 
      'code': 'alert tcp any any -> any any (msg:"Ransomware .locked Extension"; content:".locked"; sid:30001; rev:1;)', 
      'descAr': 'يكتشف هذا المؤشر ملفات الفدية المشفرة ذات الامتداد الخبيث .locked عبر الشبكة.',
      'descEn': 'Detects malicious ransomware file extensions (.locked) across network traffic.'
    },
    {
      'title': 'SQL Injection Bypass (OR 1=1)', 
      'code': 'alert tcp any any -> any 80 (msg:"SQL Injection Attack"; content:"OR 1=1"; sid:30002; rev:1;)', 
      'descAr': 'يكتشف محاولات تجاوز صفحات تسجيل الدخول وبوابات المصادقة عبر حقن SQL.',
      'descEn': 'Detects login authentication bypass attempts via SQL injection techniques.'
    },
    {
      'title': 'SSH Brute Force Attack', 
      'code': 'alert tcp any any -> any 22 (msg:"SSH Brute Force"; threshold:type threshold, track by_src, count 5, seconds 60; sid:30003; rev:1;)', 
      'descAr': 'يرصد محاولات تخمين كلمات المرور المتكررة (Brute Force) على خدمة الـ SSH.',
      'descEn': 'Monitors repeated authentication failure attempts targeting SSH services.'
    },
    {
      'title': 'Cross-Site Scripting (XSS Attack)', 
      'code': 'alert tcp any any -> any 80 (msg:"XSS Injection Attempt"; content:"<script>"; sid:30004; rev:1;)', 
      'descAr': 'يكتشف محاولات حقن سكربتات خبيثة تنفيذية عبر المتصفح (XSS).',
      'descEn': 'Detects malicious script injection attempts targeting web applications.'
    },
    {
      'title': 'Remote Code Execution (RCE / cmd.exe)', 
      'code': 'alert tcp any any -> any 80 (msg:"RCE Web Shell Execution"; content:"cmd.exe"; sid:30005; rev:1;)', 
      'descAr': 'يكتشف محاولات تشغيل أوامر النظام عن بعد عبر ثغرات تنفيذ الأكواد (RCE).',
      'descEn': 'Detects remote system command execution attempts via vulnerable web interfaces.'
    },
    {
      'title': 'DNS Tunneling Suspicious Query', 
      'code': 'alert udp any any -> any 53 (msg: "DNS Tunneling Activity"; content: "|01 00 00 01 00 00 00 00|"; sid:30006; rev:1;)', 
      'descAr': 'يرصد عمليات تسريب البيانات أو الاتصالات المخفية عبر بروتوكول أسماء النطاقات DNS.',
      'descEn': 'Monitors covert data exfiltration and tunneling through DNS queries.'
    },
    {
      'title': 'DDoS SYN Flood Attack', 
      'code': 'alert tcp any any -> any any (msg:"SYN Flood DDoS Attack"; flags:S; threshold:type both, track by_dst, count 100, seconds 10; sid:30007; rev:1;)', 
      'descAr': 'يكتشف هجمات حجب الخدمة الموزعة عبر إغراق الهدف بحزم SYN الوهمية.',
      'descEn': 'Detects Distributed Denial of Service SYN flood flooding targeting infrastructure.'
    },
  ];

  List<Map<String, String>> filteredAttacks = [];

  @override
  void initState() {
    super.initState();
    filteredAttacks = [];
    searchController.addListener(() {
      final q = searchController.text.trim().toLowerCase();
      setState(() {
        if (q.isEmpty) {
          filteredAttacks = [];
        } else {
          filteredAttacks = allAttacks.where((item) => 
            item['title']!.toLowerCase().contains(q) || 
            item['code']!.toLowerCase().contains(q) ||
            item['descAr']!.toLowerCase().contains(q) ||
            item['descEn']!.toLowerCase().contains(q)
          ).toList();
        }
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
                labelText: ar ? 'ابحث عن الهجمة أو الثغرة (مثال: Ransomware, SQL)...' : 'Search attacks (e.g., Ransomware, SQL, XSS)...',
                prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredAttacks.isEmpty 
                  ? Center(
                      child: Text(
                        ar ? 'أدخل اسم الهجمة في خانة البحث أعلاه لعرض المؤشرات...' : 'Enter an attack name above to view threat intelligence indicators...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
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
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(ar ? 'تم النسخ!' : 'Copied!'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
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
