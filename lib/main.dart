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
      title: 'YQSecurity Enterprise',
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

String hashPassword(String password) {
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

  void _handleSecureAuth(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security Error: Email and Password cannot be empty!')),
      );
      return;
    }

    String secureHashedPassword = hashPassword(password);
    debugPrint('Secure Hash Generated: $secureHashedPassword');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          analystEmail: email,
          analystName: nameController.text.isNotEmpty ? nameController.text : 'SOC Analyst',
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
                'YQSECURITY SOC',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white, 
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Encrypted Threat Intelligence & Operations Hub',
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
                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _handleSecureAuth(context),
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.cyanAccent),
                      label: const Text('Google SSO', style: TextStyle(color: Colors.white, fontSize: 13)),
                      onPressed: () => _handleSecureAuth(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.facebook, size: 20, color: Colors.blue),
                      label: const Text('Facebook', style: TextStyle(color: Colors.white, fontSize: 13)),
                      onPressed: () => _handleSecureAuth(context),
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
  const DashboardScreen({Key? key, required this.analystEmail, required this.analystName}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String currentLanguage = 'English (EN)';

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SOC Analyst Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blueAccent),
                title: const Text('Language / اللغة'),
                subtitle: Text(currentLanguage),
                trailing: TextButton(
                  onPressed: () {
                    setState(() {
                      currentLanguage = currentLanguage.contains('EN') ? 'العربية (AR)' : 'English (EN)';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Switch', style: TextStyle(color: Colors.cyanAccent)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.greenAccent),
                title: const Text('Analyst ID & Email'),
                subtitle: Text(widget.analystEmail),
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: Colors.orangeAccent),
                title: const Text('Update Master Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password update link sent securely!')));
                },
              ),
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
        title: const Text('YQSecurity - Operations Hub'),
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
              accountName: Text(widget.analystName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              accountEmail: Text(widget.analystEmail, style: const TextStyle(color: Colors.cyanAccent)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.security, size: 36, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.cyanAccent),
              title: const Text('Settings & Profile'),
              onTap: () {
                Navigator.pop(context);
                _showSettingsModal(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: Text('Language: $currentLanguage'),
              onTap: () {
                setState(() {
                  currentLanguage = currentLanguage.contains('EN') ? 'العربية (AR)' : 'English (EN)';
                });
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: const Text('Logout Securely'),
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
            Text(
              'Active Analyst: ${widget.analystName}',
              style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
            ),
            const SizedBox(height: 10),
            const Text(
              'Encrypted SOC Toolkits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select an advanced security engine below:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(
                    context,
                    'Advanced Suricata Rule Builder',
                    'Custom IPs, Ports, Protocols & Signatures',
                    Icons.security,
                    Colors.orangeAccent,
                    const SuricataScreen(),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    'Dynamic Wireshark Filter Builder',
                    'Describe your packet filter requirements freely',
                    Icons.network_check,
                    Colors.lightBlueAccent,
                    const WiresharkScreen(),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    'Splunk SPL Query Generator',
                    'Build enterprise security log queries dynamically',
                    Icons.analytics,
                    Colors.purpleAccent,
                    const SplunkScreen(),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    'IOCs & Threat Intelligence Hub',
                    'Searchable database with detailed analysis & help',
                    Icons.menu_book,
                    Colors.greenAccent,
                    const CheatSheetScreen(),
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

class SuricataScreen extends StatefulWidget {
  const SuricataScreen({Key? key}) : super(key: key);

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
      generatedRule = '$selectedAction $selectedProtocol '
          '${srcIpController.text} ${srcPortController.text} -> '
          '${dstIpController.text} ${dstPortController.text} '
          '(msg:"${msgController.text}"; '
          'content:"${contentController.text}"; '
          'sid:${sidController.text}; rev:1;)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Suricata Builder'), backgroundColor: const Color(0xFF131B2E)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAction,
                    dropdownColor: const Color(0xFF131B2E),
                    decoration: const InputDecoration(labelText: 'Action', border: OutlineInputBorder()),
                    items: ['alert', 'drop', 'pass', 'reject']
                        .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                        .toList(),
                    onChanged: (val) { setState(() { selectedAction = val!; updateRule(); }); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedProtocol,
                    dropdownColor: const Color(0xFF131B2E),
                    decoration: const InputDecoration(labelText: 'Protocol', border: OutlineInputBorder()),
                    items: ['tcp', 'udp', 'icmp', 'ip']
                        .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                        .toList(),
                    onChanged: (val) { setState(() { selectedProtocol = val!; updateRule(); }); },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: srcIpController,
                    decoration: const InputDecoration(labelText: 'Source IP', border: OutlineInputBorder()),
                    onChanged: (_) => updateRule(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: srcPortController,
                    decoration: const InputDecoration(labelText: 'Source Port', border: OutlineInputBorder()),
                    onChanged: (_) => updateRule(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dstIpController,
                    decoration: const InputDecoration(labelText: 'Dest IP', border: OutlineInputBorder()),
                    onChanged: (_) => updateRule(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: dstPortController,
                    decoration: const InputDecoration(labelText: 'Dest Port', border: OutlineInputBorder()),
                    onChanged: (_) => updateRule(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgController,
              decoration: const InputDecoration(labelText: 'Alert Message (msg)', border: OutlineInputBorder()),
              onChanged: (_) => updateRule(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Signature Content (Pattern)', border: OutlineInputBorder()),
              onChanged: (_) => updateRule(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sidController,
              decoration: const InputDecoration(labelText: 'Rule SID', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (_) => updateRule(),
            ),
            const SizedBox(height: 20),
            const Text('Generated Signature:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      generatedRule,
                      style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.orangeAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: generatedRule));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rule copied securely!')));
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
  const WiresharkScreen({Key? key}) : super(key: key);

  @override
  _WiresharkScreenState createState() => _WiresharkScreenState();
}

class _WiresharkScreenState extends State<WiresharkScreen> {
  final TextEditingController reqController = TextEditingController(text: 'http.request.method == "POST"');
  final TextEditingController ipFilterController = TextEditingController(text: '192.168.1.50');
  String dynamicFilter = '';

  @override
  void initState() {
    super.initState();
    updateFilter();
  }

  void updateFilter() {
    setState(() {
      dynamicFilter = '${reqController.text} and ip.addr == ${ipFilterController.text}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Wireshark Engine'), backgroundColor: const Color(0xFF131B2E)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Describe & Build Packet Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 12),
            TextField(
              controller: reqController,
              decoration: const InputDecoration(labelText: 'Packet Field / HTTP / TCP Flag', border: OutlineInputBorder()),
              onChanged: (_) => updateFilter(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ipFilterController,
              decoration: const InputDecoration(labelText: 'Target IP Address', border: OutlineInputBorder()),
              onChanged: (_) => updateFilter(),
            ),
            const SizedBox(height: 20),
            const Text('Generated Wireshark Display Filter:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dynamicFilter,
                      style: const TextStyle(fontFamily: 'monospace', color: Colors.lightBlueAccent, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.lightBlueAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: dynamicFilter));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display filter copied!')));
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

class SplunkScreen extends StatefulWidget {
  const SplunkScreen({Key? key}) : super(key: key);

  @override
  _SplunkScreenState createState() => _SplunkScreenState();
}

class _SplunkScreenState extends State<SplunkScreen> {
  final TextEditingController indexController = TextEditingController(text: 'index=security_logs');
  final TextEditingController searchParamController = TextEditingController(text: 'failed_login');
  final TextEditingController statsController = TextEditingController(text: 'clientip');
  String generatedSpl = '';

  @override
  void initState() {
    super.initState();
    updateSpl();
  }

  void updateSpl() {
    setState(() {
      generatedSpl = '${indexController.text} sourcetype=* | search ${searchParamController.text} | stats count by ${statsController.text} | sort -count';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Splunk SPL Query Generator'), backgroundColor: const Color(0xFF131B2E)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: indexController,
              decoration: const InputDecoration(labelText: 'Splunk Index & Source', border: OutlineInputBorder()),
              onChanged: (_) => updateSpl(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchParamController,
              decoration: const InputDecoration(labelText: 'Search Keyword / Event', border: OutlineInputBorder()),
              onChanged: (_) => updateSpl(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: statsController,
              decoration: const InputDecoration(labelText: 'Stats Group Field (e.g., clientip, user)', border: OutlineInputBorder()),
              onChanged: (_) => updateSpl(),
            ),
            const SizedBox(height: 20),
            const Text('Generated Splunk SPL Query:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      generatedSpl,
                      style: const TextStyle(fontFamily: 'monospace', color: Colors.purpleAccent, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.purpleAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: generatedSpl));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SPL query copied!')));
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
  const CheatSheetScreen({Key? key}) : super(key: key);

  @override
  _CheatSheetScreenState createState() => _CheatSheetScreenState();
}

class _CheatSheetScreenState extends State<CheatSheetScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allItems = [
    {
      'title': 'Splunk Top IPs Analysis',
      'code': 'index=_internal | stats count by clientip | sort -count',
      'desc': 'Aggregates and sorts internal log sources to identify top talking IP addresses for anomaly detection.'
    },
    {
      'title': 'Suricata Brute-Force HTTP Login',
      'code': 'alert tcp any any -> any 80 (msg:"Possible HTTP Brute-Force"; content:"POST"; content:"password="; sid:30001; rev:1;)',
      'desc': 'Detects repeated HTTP POST requests containing password parameters indicative of credential stuffing or brute-force attacks.'
    },
    {
      'title': 'Wireshark TCP Port Scan Detection',
      'code': 'tcp.flags.syn == 1 and tcp.flags.ack == 0',
      'desc': 'Isolates half-open TCP SYN packets which are standard indicators of network reconnaissance and port scanning.'
    },
    {
      'title': 'Ransomware File Extension Indicator',
      'code': 'alert tcp any any -> any any (msg:"Suspicious Ransomware Extension Request"; content:".locked"; sid:30002; rev:1;)',
      'desc': 'Spots known ransomware extension patterns transferred or requested across network streams.'
    },
    {
      'title': 'Nmap Stealth SYN Scan',
      'code': 'nmap -sS -T4 -p- <Target-IP>',
      'desc': 'Executes a fast multi-threaded TCP SYN port scan without completing the full TCP handshake.'
    },
  ];

  List<Map<String, String>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems;
    searchController.addListener(_filterSearch);
  }

  void _filterSearch() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = allItems.where((item) {
        return item['title']!.toLowerCase().contains(query) ||
               item['code']!.toLowerCase().contains(query) ||
               item['desc']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(title: const Text('IOCs & Threat Intel Hub'), backgroundColor: const Color(0xFF131B2E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search rules, ransomware, brute-force...',
                prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
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
                              Expanded(
                                child: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline, color: Colors.orangeAccent, size: 20),
                                onPressed: () => _showHelpDialog(context, item['title']!, item['desc']!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(item['code']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18, color: Colors.greenAccent),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: item['code']!));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IOC / Rule copied!')));
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
