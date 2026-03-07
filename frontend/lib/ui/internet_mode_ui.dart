import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:s2n_quic_flutter/s2n_quic_flutter.dart';

class InternetModeView extends StatefulWidget {
  final Function(String) onConnectRequested;

  const InternetModeView({
    Key? key,
    required this.onConnectRequested,
  }) : super(key: key);

  @override
  State<InternetModeView> createState() => _InternetModeViewState();
}

class _InternetModeViewState extends State<InternetModeView> with SingleTickerProviderStateMixin {
  final TextEditingController _roomIdController = TextEditingController();
  bool _isConnecting = false;

  void _handleJoin() {
    final roomId = _roomIdController.text.trim();
    if (roomId.isNotEmpty) {
      setState(() => _isConnecting = true);
      
      // In a real app, RoomID connects to the Signaling server to fetch endpoint arrays.
      // Pass the fallback structure array natively for test purposes.
      widget.onConnectRequested('["relay.$roomId.oneshare.app:4433", "192.168.1.100:4433"]');
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isConnecting = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 60),
              _buildInputCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remote Transfer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Internet & Relay Mode',
              style: TextStyle(
                color: Colors.purpleAccent.shade100,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.public, color: Colors.purpleAccent, size: 28),
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 20),
                const Text(
                  'Join Room',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the 6-digit room code from the receiver device to start the file transfer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.5),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _roomIdController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "••••••",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isConnecting ? null : _handleJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Connect to Peer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
