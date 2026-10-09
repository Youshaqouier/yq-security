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
      title: 'YQ Security',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 1. الشاشة الرئيسية (لوحة التحكم)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YQ Security - SOC Assistant'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Operations Center Toolkit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a tool below to begin your analysis:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(
                    context,
                    'Suricata Rule Generator',
                    'Generate intrusion detection rules quickly',
                    Icons.security,
                    Colors.orangeAccent,
                    const SuricataScreen(),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    'Wireshark Filter Helper',
                    'Convert plain concepts to exact packet filters',
                    Icons.network_check,
                    Colors.lightBlueAccent,
                    const WiresharkScreen(),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    'IOCs & Cheat Sheet',
                    'Quick reference for common security queries',
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
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

// 2. أداة مولد قواعد سوريكاتا
class SuricataScreen extends StatefulWidget {
  const SuricataScreen({Key? key}) : super(key: key);

  @override
  _SuricataScreenState createState() => _SuricataScreenState();
}

class _SuricataScreenState extends State<SuricataScreen> {
  String selectedProtocol = 'alert tcp';
  final TextEditingController msgController = TextEditingController(text: 'Suspicious HTTP Request');
  final TextEditingController contentController = TextEditingController(text: '/admin/login.php');
  final TextEditingController sidController = TextEditingController(text: '100001');

  String generatedRule = '';

  @override
  void initState() {
    super.initState();
    updateRule();
  }

  void updateRule() {
    setState(() {
      generatedRule = '$selectedProtocol any any -> any any '
          '(msg:"${msgController.text}"; '
          'content:"${contentController.text}"; '
          'sid:${sidController.text}; rev:1;)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suricata Rule Generator'), backgroundColor: const Color(0xFF1E1E1E)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedProtocol,
              dropdownColor: const Color(0xFF1E1E1E),
              decoration: const InputDecoration(labelText: 'Action & Protocol', border: OutlineInputBorder()),
              items: ['alert tcp', 'alert udp', 'alert icmp', 'drop tcp']
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedProtocol = val!;
                  updateRule();
                });
              },
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
              decoration: const InputDecoration(labelText: 'Signature Content', border: OutlineInputBorder()),
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
            const Text('Generated Rule:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ القاعدة بنجاح!')));
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

// 3. أداة مساعد فلاتر وايرشاك
class WiresharkScreen extends StatefulWidget {
  const WiresharkScreen({Key? key}) : super(key: key);

  @override
  _WiresharkScreenState createState() => _WiresharkScreenState();
}

class _WiresharkScreenState extends State<WiresharkScreen> {
  String selectedFilterType = 'HTTP POST Requests';
  final TextEditingController paramController = TextEditingController(text: 'POST');
  String resultingFilter = 'http.request.method == "POST"';

  void updateFilter(String type) {
    setState(() {
      selectedFilterType = type;
      if (type == 'HTTP POST Requests') {
        resultingFilter = 'http.request.method == "POST"';
      } else if (type == 'Specific IP Address') {
        resultingFilter = 'ip.addr == 192.168.1.100';
      } else if (type == 'Failed TCP Handshake (SYN-ACK missing)') {
        resultingFilter = 'tcp.flags.syn == 1 and tcp.flags.ack == 0';
      } else if (type == 'DNS Queries') {
        resultingFilter = 'dns.qry.name';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wireshark Filter Helper'), backgroundColor: const Color(0xFF1E1E1E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedFilterType,
              dropdownColor: const Color(0xFF1E1E1E),
              decoration: const InputDecoration(labelText: 'Select Filter Category', border: OutlineInputBorder()),
              items: ['HTTP POST Requests', 'Specific IP Address', 'Failed TCP Handshake (SYN-ACK missing)', 'DNS Queries']
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) {
                if (val != null) updateFilter(val);
              },
            ),
            const SizedBox(height: 20),
            const Text('Calculated Wireshark Filter:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      resultingFilter,
                      style: const TextStyle(fontFamily: 'monospace', color: Colors.lightBlueAccent, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.lightBlueAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: resultingFilter));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الفلتر بنجاح!')));
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

// 4. مرجع مؤشرات الاختراق والأكواد السريعة
class CheatSheetScreen extends StatelessWidget {
  const CheatSheetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> cheatSheetData = [
      {'title': 'Splunk Top IPs', 'code': 'index=_internal | stats count by clientip | sort -count'},
      {'title': 'Suricata Basic TCP Alert', 'code': 'alert tcp any any -> any 80 (msg:"HTTP Traffic"; sid:1001; rev:1;)'},
      {'title': 'Wireshark TCP Reset', 'code': 'tcp.flags.reset == 1'},
      {'title': 'Nmap Quick SYN Scan', 'code': 'nmap -sS -T4 <Target-IP>'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('IOCs & Security Cheat Sheet'), backgroundColor: const Color(0xFF1E1E1E)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cheatSheetData.length,
        itemBuilder: (context, index) {
          final item = cheatSheetData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                    child: Text(item['code']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
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
