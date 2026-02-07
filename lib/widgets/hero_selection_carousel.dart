import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart'; // For SpriteAnimation
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hero_data.dart';
import '../core/enums.dart';

class HeroSelectionCarousel extends StatefulWidget {
  final Function(HeroData) onHeroSelected;
  final VoidCallback onPlay;

  const HeroSelectionCarousel({
    super.key,
    required this.onHeroSelected,
    required this.onPlay,
  });

  @override
  State<HeroSelectionCarousel> createState() => _HeroSelectionCarouselState();
}

class _HeroSelectionCarouselState extends State<HeroSelectionCarousel> {
  List<HeroData> _heroes = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  Sprite? _currentSprite; // Use Sprite instead of Animation for stability
  Set<String> _unlockedHeroes = {'gino', 'wizard', 'robot'}; // Default unlocked

  int _userGold = 0; // Added

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _heroes = HeroData.getRoster();

    // Load persistence
    final prefs = await SharedPreferences.getInstance();
    _currentIndex = prefs.getInt('selected_hero_index') ?? 0;

    // Safety check for index
    if (_heroes.isEmpty) {
      debugPrint('Critical: Hero Roster is empty!');
      return;
    }
    if (_currentIndex >= _heroes.length) {
      _currentIndex = 0;
    }

    // Load unlocked heroes (simple list of IDs)
    final savedUnlocked = prefs.getStringList('unlocked_heroes');
    if (savedUnlocked != null) {
      _unlockedHeroes.addAll(savedUnlocked);
    }

    // Load gold
    _userGold = prefs.getInt('gold_balance') ?? 0;

    // Load initial sprite
    await _loadHeroSprite(_currentIndex);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      widget.onHeroSelected(_heroes[_currentIndex]);
    }
  }

  Future<void> _loadHeroSprite(int index) async {
    final hero = _heroes[index];
    setState(() {
      _isLoading = true;
      _currentSprite = null;
    });

    try {
      Sprite sprite;

      if (hero.assetType == HeroAssetType.frames) {
        // Legacy "Frames" type (Gino) - load first frame
        // Assuming path like 'heroes/gino/run' -> loads 'heroes/gino/run_1.png' or similar
        // Based on original code, it was loading index 1
        String path = '${hero.previewPath}_1.png';
        if (hero.id == 'gino')
          path =
              'heroes/gino/run/idle01.png'; // Corrected path based on file system audit

        sprite = await Sprite.load(path);
      } else {
        // SpriteSheet Type (Wizard, Knight, etc)
        // Need to slice the first frame!
        final image = await Flame.images.load(hero.previewPath);

        // Calculate single frame width
        // Assumes horizontal strip
        final frameWidth = image.width / hero.previewFrameCount;
        final frameHeight = image.height.toDouble();

        sprite = Sprite(
          image,
          srcPosition: Vector2.zero(),
          srcSize: Vector2(frameWidth, frameHeight),
        );
      }

      if (mounted) {
        setState(() {
          _currentSprite = sprite;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sprite for ${hero.name}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cycleHero(int direction) {
    int newIndex = _currentIndex + direction;
    if (newIndex < 0) newIndex = _heroes.length - 1;
    if (newIndex >= _heroes.length) newIndex = 0;

    setState(() {
      _currentIndex = newIndex;
    });

    // Check unlock status for new hero
    if (isHeroUnlocked(_heroes[newIndex])) {
      // If unlocked, select it immediately
      widget.onHeroSelected(_heroes[newIndex]);
      // Update persistence
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('selected_hero_index', _currentIndex);
      });
    }

    _loadHeroSprite(newIndex);
  }

  bool isHeroUnlocked(HeroData hero) {
    // Free heroes check
    if (hero.price == 0) return true;
    return _unlockedHeroes.contains(hero.id);
  }

  Future<void> _unlockHero(HeroData hero) async {
    if (_userGold < hero.price) {
      // Not enough gold feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough Gold! Need ${hero.price - _userGold} more.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Deduct gold
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userGold -= hero.price;
      _unlockedHeroes.add(hero.id);
    });

    await prefs.setInt('gold_balance', _userGold);
    await prefs.setStringList('unlocked_heroes', _unlockedHeroes.toList());

    // Select the new hero
    await prefs.setInt('selected_hero_index', _currentIndex);
    widget.onHeroSelected(hero);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${hero.name} Unlocked!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const CircularProgressIndicator(color: Colors.white);

    final hero = _heroes[_currentIndex];
    final isLocked = !isHeroUnlocked(hero);
    final size = MediaQuery.of(context).size;
    final carouselHeight = size.height * 0.4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gold Display
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10, right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_userGold G',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Carousel Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildArrow(Icons.arrow_back_ios, () => _cycleHero(-1)),

            SizedBox(
              width: size.width * 0.6, // Wider container
              height: carouselHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Magic Seal
                  Container(
                    width: carouselHeight * 0.8, // Bigger seal
                    height: carouselHeight * 0.25,
                    margin: EdgeInsets.only(top: carouselHeight * 0.7),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: (hero.tint ?? Colors.purple).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(
                          carouselHeight * 0.8,
                          carouselHeight * 0.25,
                        ),
                      ),
                    ),
                  ),

                  // Hero Sprite
                  if (_currentSprite != null)
                    Transform.scale(
                      scale: 1.5,
                      filterQuality: FilterQuality.none,
                      child: ColorFiltered(
                        colorFilter: isLocked
                            ? const ColorFilter.mode(
                                Colors.black54,
                                BlendMode.srcATop,
                              )
                            : ColorFilter.mode(
                                hero.tint ?? Colors.transparent,
                                BlendMode.srcATop,
                              ),
                        child: SizedBox(
                          width: carouselHeight * 0.8,
                          height: carouselHeight * 0.8,
                          child: SpriteWidget(sprite: _currentSprite!),
                        ),
                      ),
                    )
                  else
                    const CircularProgressIndicator(),

                  if (isLocked)
                    const Icon(Icons.lock, color: Colors.white70, size: 48),
                ],
              ),
            ),

            _buildArrow(Icons.arrow_forward_ios, () => _cycleHero(1)),
          ],
        ),

        // Hero Name
        Text(
          hero.name,
          style: TextStyle(
            fontSize: size.height * 0.04,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: (hero.tint ?? Colors.purple), blurRadius: 10),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Action Button
        _buildActionButton(hero, isLocked),
      ],
    );
  }

  Widget _buildArrow(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 32),
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black26,
        highlightColor: Colors.purpleAccent,
      ),
    );
  }

  Widget _buildActionButton(HeroData hero, bool isLocked) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocked ? Colors.grey : const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: isLocked ? 0 : 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          debugPrint('Button Pressed: ${hero.name}, Locked: $isLocked');
          if (isLocked) {
            _unlockHero(hero);
          } else {
            debugPrint('Triggering onPlay callback...');
            widget.onPlay();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLocked ? 'UNLOCK' : 'START QUEST',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (isLocked) ...[
              const SizedBox(width: 8),
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              Text(' ${hero.price}'),
            ],
          ],
        ),
      ),
    );
  }
}
