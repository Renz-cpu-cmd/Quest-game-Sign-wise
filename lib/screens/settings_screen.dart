import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Volume State
  double _bgmVolume = 0.5;
  double _sfxVolume = 0.5;

  @override
  void initState() {
    super.initState();
    // Load current values from AudioManager
    _bgmVolume = AudioManager.instance.bgmVolume;
    _sfxVolume = AudioManager.instance.sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Reuse Parallax Background
          Image.asset(
            'assets/images/environment/parallax/bg_layer1.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
          ),
          Image.asset(
            'assets/images/environment/parallax/bg_layer2.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
          ),

          // Dark Overlay
          Container(color: Colors.black87),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Header
                  const Center(
                    child: Text(
                      'Arcane Archives',
                      style: TextStyle(
                        fontFamily: 'Pixel',
                        fontSize: 40,
                        color: Colors.amberAccent,
                        shadows: [Shadow(color: Colors.purple, blurRadius: 20)],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- Audio Settings ---
                  _buildSectionHeader('Magical Resonance (Audio)'),
                  const SizedBox(height: 16),

                  _buildSlider('Background Music', _bgmVolume, (val) {
                    setState(() => _bgmVolume = val);
                    AudioManager.instance.setBgmVolume(val);
                  }),
                  _buildSlider('Sound Effects', _sfxVolume, (val) {
                    setState(() => _sfxVolume = val);
                    AudioManager.instance.setSfxVolume(val);
                  }),

                  const SizedBox(height: 40),

                  // --- Instructions ---
                  _buildSectionHeader('Grimoire of Control'),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.purpleAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInstruction(Icons.touch_app, 'Tap Left', 'JUMP'),
                        _buildInstruction(Icons.swipe, 'Swipe Down', 'DUCK'),
                        _buildInstruction(
                          Icons.touch_app,
                          'Tap Right',
                          'ATTACK',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- Data Management ---
                  _buildSectionHeader('Flux Control (Data)'),
                  const SizedBox(height: 16),

                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('RESET ALL PROGRESS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      onPressed: _showResetConfirmation,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'v1.0.0 - Crystal Quest Build',
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Pixel',
        fontSize: 20,
        color: Color(0xFFC084FC),
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8B5CF6),
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.amber,
            overlayColor: Colors.amber.withOpacity(0.2),
          ),
          child: Slider(value: value, onChanged: onChanged, min: 0.0, max: 1.0),
        ),
      ],
    );
  }

  Widget _buildInstruction(IconData icon, String action, String description) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          action,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          description,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pixel',
          ),
        ),
      ],
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a1f3d),
        title: const Text(
          'Reset All Progress?',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'This will delete all Gold, unlocked Heroes, and High Scores. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text(
              'CONFIRM RESET',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _performReset();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Wipe everything

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Universe Reset! Please restart the app for full effect.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      // Optionally reset local state logic or force navigation back to splash
      // For now, simpler is safer: user sees clean slate next time logic loads
    }
  }
}
