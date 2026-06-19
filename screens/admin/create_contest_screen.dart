import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../data/admin_contest_service.dart';

class CreateContestScreen extends StatefulWidget {
  const CreateContestScreen({super.key});

  @override
  State<CreateContestScreen> createState() => _CreateContestScreenState();
}

class _CreateContestScreenState extends State<CreateContestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminContestService();
  
  late String _contestId;
  bool _isLoading = false;

  final _titleCtrl = TextEditingController();
  final _gameCtrl = TextEditingController(text: 'Free Fire');
  final _modeCtrl = TextEditingController();
  final _playerSizeCtrl = TextEditingController(text: 'Solo');
  final _mapCtrl = TextEditingController();
  final _entryFeeCtrl = TextEditingController(text: '0');
  final _prizePoolCtrl = TextEditingController(text: '0');
  final _totalSlotsCtrl = TextEditingController(text: '100');
  final _upiIdCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController(text: 'No emulators allowed.\nScreenshot mandatory for win validation.');

  DateTime _matchTime = DateTime.now().add(const Duration(days: 1));
  int _revealMinutesBefore = 15;

  Uint8List? _qrBytes;
  String? _qrExt;

  final List<String> _games = ['Free Fire', 'BGMI', 'Valorant', 'EA FC', 'Clash Royale', 'Apex Legends', 'Real Cricket 26'];

  @override
  void initState() {
    super.initState();
    _contestId = _adminService.generateContestId();
  }

  Future<void> _pickQrCode() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _qrBytes = bytes;
        _qrExt = pickedFile.name.split('.').last;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(context: context, initialDate: _matchTime, firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (date == null) return;
    
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_matchTime));
    if (time == null) return;

    setState(() {
      _matchTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submitContest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final matchTime = Timestamp.fromDate(_matchTime);
      final revealTime = Timestamp.fromDate(_matchTime.subtract(Duration(minutes: _revealMinutesBefore)));

      final contestData = {
        'title': _titleCtrl.text.trim(),
        'gameName': _gameCtrl.text,
        'mode': _modeCtrl.text.trim(),
        'playerSize': _playerSizeCtrl.text.trim(),
        'mapName': _mapCtrl.text.trim(),
        'matchTime': matchTime,
        'roomRevealTime': revealTime,
        'status': 'Upcoming',
        'entryFee': int.parse(_entryFeeCtrl.text),
        'prizePool': int.parse(_prizePoolCtrl.text),
        'totalSlots': int.parse(_totalSlotsCtrl.text),
        'filledSlots': 0,
        'roomId': '',
        'roomPassword': '',
        'rules': _rulesCtrl.text.split('\n').where((r) => r.isNotEmpty).toList(),
        'paymentConfig': {
          'upiId': _upiIdCtrl.text.trim(),
          'qrImageUrl': '', 
        }
      };

      await _adminService.createContest(
        contestId: _contestId,
        contestData: contestData,
        qrImageBytes: _qrBytes,
        qrImageExt: _qrExt,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contest Created Successfully!'), backgroundColor: EsportsColors.success));
        Navigator.pop(context); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: EsportsColors.live));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg2,
      appBar: AppBar(
        backgroundColor: EsportsColors.card,
        title: const Text('Create New Contest', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: EsportsColors.cyan)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('GENERATED CONTEST ID', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
                        Text(_contestId, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: EsportsColors.cyan),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _contestId));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Copied!')));
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('Basic Information', style: TextStyle(color: EsportsColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Contest Title', _titleCtrl)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gameCtrl.text,
                      dropdownColor: EsportsColors.card,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Game', filled: true, fillColor: EsportsColors.card, border: OutlineInputBorder()),
                      items: _games.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) => setState(() => _gameCtrl.text = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Mode (e.g. Battle Royale, TDM)', _modeCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Player Size (e.g. Solo, Squad, 5v5)', _playerSizeCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Map (e.g. Bermuda, Ascent)', _mapCtrl)),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Financials & Capacity', style: TextStyle(color: EsportsColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Entry Fee (₹)', _entryFeeCtrl, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Prize Pool (₹)', _prizePoolCtrl, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Total Slots', _totalSlotsCtrl, isNumber: true)),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Scheduling', style: TextStyle(color: EsportsColors.neonPurple, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      tileColor: EsportsColors.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      title: const Text('Match Date & Time', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
                      subtitle: Text(_matchTime.toString().substring(0, 16), style: const TextStyle(color: Colors.white, fontSize: 16)),
                      trailing: const Icon(Icons.calendar_month, color: EsportsColors.neonPurple),
                      onTap: () => _selectDateTime(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Room Reveal (Minutes before start)', 
                      TextEditingController(text: _revealMinutesBefore.toString()), 
                      isNumber: true,
                      onChanged: (v) => _revealMinutesBefore = int.tryParse(v) ?? 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Payment Configuration', style: TextStyle(color: EsportsColors.success, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTextField('Admin UPI ID', _upiIdCtrl)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.card, padding: const EdgeInsets.all(16)),
                          icon: const Icon(Icons.qr_code, color: Colors.white),
                          label: const Text('Upload QR Image', style: TextStyle(color: Colors.white)),
                          onPressed: _pickQrCode,
                        ),
                        if (_qrBytes != null) ...[
                          const SizedBox(height: 8),
                          const Text('QR Image Selected!', style: TextStyle(color: EsportsColors.success, fontSize: 12))
                        ]
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              const Text('Match Rules (One rule per line)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rulesCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(filled: true, fillColor: EsportsColors.card, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.electricBlue),
                  onPressed: _isLoading ? null : _submitContest,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('PUBLISH CONTEST', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isNumber = false, Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: EsportsColors.textMuted),
        filled: true,
        fillColor: EsportsColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}