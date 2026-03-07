import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:s2n_quic_flutter/s2n_quic_flutter.dart';

class LocalModeView extends StatefulWidget {
  final String myPeerId;
  final Function(String, String) onSendRequested; // (peerId, address)

  const LocalModeView({
    Key? key,
    required this.myPeerId,
    required this.onSendRequested,
  }) : super(key: key);

  @override
  State<LocalModeView> createState() => _LocalModeViewState();
}

class _LocalModeViewState extends State<LocalModeView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final PeerManager _peerManager = PeerManager();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    S2nQuicEngine().startDiscovery(widget.myPeerId);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    S2nQuicEngine().stopDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Modern deep slate
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 60),
            _buildRadar(),
            const SizedBox(height: 40),
            Expanded(child: _buildPeersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nearby Devices',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'LAN Discovery Active',
                style: TextStyle(
                  color: Colors.blueAccent.shade100,
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
            child: const Icon(Icons.radar, color: Colors.blueAccent, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildRadar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 200 + (_pulseController.value * 50),
              height: 200 + (_pulseController.value * 50),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.4),
                    Colors.blueAccent.withOpacity(0.0),
                  ],
                ),
              ),
            );
          },
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.smartphone, color: Colors.white, size: 36),
        ),
      ],
    );
  }

  Widget _buildPeersList() {
    return StreamBuilder<List<PeerModel>>(
      stream: _peerManager.peerListStream,
      initialData: _peerManager.activePeers,
      builder: (context, snapshot) {
        final peers = snapshot.data ?? [];
        if (peers.isEmpty) {
          return Center(
            child: Text(
              'Searching for devices...\nEnsure both are on the same WiFi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: peers.length,
          itemBuilder: (context, index) {
            final peer = peers[index];
            return _buildPeerCard(peer);
          },
        );
      },
    );
  }

  Widget _buildPeerCard(PeerModel peer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              radius: 24,
              child: const Icon(Icons.laptop_mac, color: Colors.blueAccent),
            ),
            title: Text(
              peer.id,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              'Ready to receive',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
            trailing: ElevatedButton(
              onPressed: () => widget.onSendRequested(peer.id, peer.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Foreground replaced manually if needed
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
