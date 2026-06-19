import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../data/contest_service.dart';
import '../data/user_service.dart';
import '../widgets/components.dart';

class JoinContestScreen extends StatefulWidget {
  final ExtendedMatchData match;
  final UserProfile currentUser;

  const JoinContestScreen({
    super.key,
    required this.match,
    required this.currentUser,
  });

  @override
  State<JoinContestScreen> createState() => _JoinContestScreenState();
}

class _JoinContestScreenState extends State<JoinContestScreen> {
  final _gameIdController = TextEditingController();
  File? _paymentScreenshot;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentUser.gameIds.containsKey(widget.match.gameName)) {
      _gameIdController.text = widget.currentUser.gameIds[widget.match.gameName]!;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _paymentScreenshot = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPayment() async {
    final gameId = _gameIdController.text.trim();
    if (gameId.isEmpty) {
      _showError('Please enter your Game ID.');
      return;
    }

    if (!widget.match.isFree && _paymentScreenshot == null) {
      _showError('Please upload your payment screenshot.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await UserService().updateGameId(widget.currentUser.uid, widget.match.gameName, gameId);

      await ContestService().joinContest(
        contestId: widget.match.id,
        uid: widget.currentUser.uid,
        username: widget.currentUser.name,
        gameIdUsed: gameId,
        paymentScreenshot: _paymentScreenshot,
        isFree: widget.match.isFree,
      );

      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Check My Matches.'),
            backgroundColor: EsportsColors.success,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: EsportsColors.live));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Join ${widget.match.gameName}', style: const TextStyle(color: EsportsColors.cyan)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: glassDecoration(opacity: 0.1, borderColor: Color(widget.match.gradientColors.first)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.match.matchType, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Map: ${widget.match.mapName}', style: const TextStyle(color: EsportsColors.textSecondary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Entry Fee', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
                      Text(
                        widget.match.isFree ? 'FREE' : '₹${widget.match.entryFee}',
                        style: TextStyle(color: widget.match.isFree ? EsportsColors.success : EsportsColors.gold, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Your ${widget.match.gameName} ID', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _gameIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter exact In-Game UID or Name',
                hintStyle: const TextStyle(color: EsportsColors.textMuted),
                filled: true,
                fillColor: EsportsColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            if (!widget.match.isFree) ...[
              const Text('Payment Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: glassDecoration(opacity: 0.05),
                child: Column(
                  children: [
                    if (widget.match.qrImageUrl.isNotEmpty) ...[
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          widget.match.qrImageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: EsportsColors.cyan));
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('UPI / PhonePe ID', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
                              Text(
                                widget.match.upiId.isNotEmpty ? widget.match.upiId : 'Admin has not set UPI', 
                                style: const TextStyle(color: EsportsColors.cyan, fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: EsportsColors.textSecondary),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.match.upiId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('UPI ID Copied to Clipboard!'), backgroundColor: EsportsColors.cyan)
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: EsportsColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _paymentScreenshot != null ? EsportsColors.success : EsportsColors.border, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _paymentScreenshot != null ? Icons.check_circle : Icons.upload_file, 
                        color: _paymentScreenshot != null ? EsportsColors.success : EsportsColors.textSecondary, 
                        size: 32
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _paymentScreenshot != null ? 'Screenshot Attached' : 'Upload Payment Screenshot',
                        style: TextStyle(
                          color: _paymentScreenshot != null ? EsportsColors.success : EsportsColors.textSecondary, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EsportsColors.electricBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : _submitPayment,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.match.isFree ? 'JOIN FOR FREE' : 'CONFIRM & JOIN', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}