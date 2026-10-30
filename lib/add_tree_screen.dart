import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

class AddTreeScreen extends StatefulWidget {
  const AddTreeScreen({super.key});

  @override
  State<AddTreeScreen> createState() => _AddTreeScreenState();
}

class _AddTreeScreenState extends State<AddTreeScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController treeNameController = TextEditingController();

  final TextEditingController speciesController = TextEditingController();

  final TextEditingController heightController = TextEditingController();

  final FocusNode treeNameFocus = FocusNode();
  final FocusNode speciesFocus = FocusNode();
  final FocusNode heightFocus = FocusNode();

  late AnimationController _pageController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  // ============================================================
  // VARIABLES
  // ============================================================

  DateTime? selectedDate;

  String healthStatus = 'Healthy';

  double? latitude;
  double? longitude;

  String locationText = 'Location not selected';

  bool isGettingLocation = false;
  bool isSelectingPhoto = false;
  bool isSaving = false;

  Uint8List? selectedPhotoBytes;

  String photoText = 'No photo selected';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    treeNameFocus.addListener(_refresh);
    speciesFocus.addListener(_refresh);
    heightFocus.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // FORM PROGRESS
  // ============================================================

  double get formProgress {
    int completed = 0;

    if (treeNameController.text.trim().isNotEmpty) {
      completed++;
    }

    if (speciesController.text.trim().isNotEmpty) {
      completed++;
    }

    if (heightController.text.trim().isNotEmpty) {
      completed++;
    }

    if (selectedDate != null) {
      completed++;
    }

    if (healthStatus.isNotEmpty) {
      completed++;
    }

    if (selectedPhotoBytes != null) {
      completed++;
    }

    if (latitude != null && longitude != null) {
      completed++;
    }

    return completed / 7;
  }

  String get progressMessage {
    if (formProgress == 0) {
      return 'Start adding your tree 🌱';
    }

    if (formProgress < 0.4) {
      return 'Good start! Keep going 🌿';
    }

    if (formProgress < 0.7) {
      return 'Your tree is growing! 🌳';
    }

    if (formProgress < 1) {
      return 'Almost ready! 🍃';
    }

    return 'Tree ready to be planted! 🌳';
  }

  IconData get treeIcon {
    if (formProgress >= 1) {
      return Icons.park;
    }

    if (formProgress >= 0.5) {
      return Icons.spa;
    }

    return Icons.eco_outlined;
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 175, 76, 160),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<void> getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;

        locationText =
            '${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)}';

        isGettingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Location captured successfully!'),
            backgroundColor: Color.fromARGB(255, 76, 158, 175),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isGettingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e'),
            backgroundColor: const Color.fromARGB(255, 162, 54, 244),
          ),
        );
      }
    }
  }

  // ============================================================
  // PHOTO
  // ============================================================

  Future<void> selectPhoto() async {
    setState(() {
      isSelectingPhoto = true;
    });

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 35,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();

        if (bytes.length > 500 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Photo is too large for the server. Please choose a smaller image.',
                ),
                backgroundColor: Color.fromARGB(255, 244, 54, 143),
              ),
            );
          }

          setState(() {
            selectedPhotoBytes = null;
            photoText = 'No photo selected';
            isSelectingPhoto = false;
          });
          return;
        }

        setState(() {
          selectedPhotoBytes = bytes;
          photoText = image.name;
          isSelectingPhoto = false;
        });
      } else {
        setState(() {
          isSelectingPhoto = false;
        });
      }
    } catch (e) {
      setState(() {
        isSelectingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo error: $e'),
            backgroundColor: const Color.fromARGB(255, 244, 54, 143),
          ),
        );
      }
    }
  }

  // ============================================================
  // SAVE TREE
  // ============================================================

  Future<void> saveTree() async {
    final String treeName = treeNameController.text.trim();

    final String species = speciesController.text.trim();

    final String heightText = heightController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (treeName.isEmpty) {
      _showMessage('Please enter tree name');
      return;
    }

    if (species.isEmpty) {
      _showMessage('Please enter tree species');
      return;
    }

    if (heightText.isEmpty) {
      _showMessage('Please enter tree height');
      return;
    }

    final double? height = double.tryParse(heightText);

    if (height == null) {
      _showMessage('Please enter a valid height');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // --------------------------------------------------------
      // DATE
      // --------------------------------------------------------

      final DateTime date = selectedDate ?? DateTime.now();

      final String plantedDate = date.toIso8601String();

      final saved = await ApiService.addTree(
        treeName: treeName,
        species: species,
        height: height,
        plantationDate: plantedDate,
        treeHealth: healthStatus,
        treePhoto: selectedPhotoBytes == null
            ? ''
            : base64Encode(selectedPhotoBytes!),
        treeLocation: locationText,
        latitude: latitude,
        longitude: longitude,
      );
      if (!saved) {
        throw Exception('The server could not save this tree.');
      }

      // --------------------------------------------------------
      // FINISH
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      await _showSuccessAnimation();

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      _showMessage('Failed to save tree: $e');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // SUCCESS ANIMATION
  // ============================================================

  Future<void> _showSuccessAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            76,
                            142,
                            175,
                          ).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color.fromARGB(255, 76, 142, 175),
                          size: 70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tree Added! 🌳',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your tree has been successfully '
                        'added to the tracker.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ANIMATED TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final bool focused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    76,
                    142,
                    175,
                  ).withOpacity(0.18),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: focused
                ? const Color.fromARGB(255, 175, 76, 120)
                : Colors.grey,
          ),
          filled: true,
          fillColor: focused
              ? const Color.fromARGB(255, 76, 119, 175).withOpacity(0.05)
              : Colors.grey.withOpacity(0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: focused
                  ? const Color.fromARGB(255, 76, 175, 165)
                  : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 145, 175, 76),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FLOATING BACKGROUND
  // ============================================================

  Widget _buildFloatingBackground() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          final double value = _floatingController.value;

          return Stack(
            children: [
              Positioned(
                top: 90 + math.sin(value * 2 * math.pi) * 15,
                right: 20,
                child: Transform.rotate(
                  angle: value * math.pi,
                  child: Icon(
                    Icons.eco,
                    size: 28,
                    color: const Color.fromARGB(
                      255,
                      76,
                      132,
                      175,
                    ).withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                top: 280 + math.sin(value * 2 * math.pi + 1) * 20,
                left: 15,
                child: Transform.rotate(
                  angle: -value * math.pi,
                  child: Icon(
                    Icons.eco,
                    size: 35,
                    color: const Color.fromARGB(
                      255,
                      195,
                      74,
                      159,
                    ).withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                top: 500 + math.sin(value * 2 * math.pi + 2) * 15,
                right: 15,
                child: Icon(
                  Icons.energy_savings_leaf,
                  size: 32,
                  color: const Color.fromARGB(
                    255,
                    142,
                    76,
                    175,
                  ).withOpacity(0.10),
                ),
              ),
              Positioned(
                top: 700 + math.sin(value * 2 * math.pi + 3) * 20,
                left: 20,
                child: Icon(
                  Icons.eco,
                  size: 25,
                  color: const Color.fromARGB(
                    255,
                    175,
                    76,
                    135,
                  ).withOpacity(0.12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard() {
    final int percentage = (formProgress * 100).round();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: formProgress),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.white],
            ),
            border: Border.all(
              color: const Color.fromARGB(255, 76, 140, 175).withOpacity(0.15),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      treeIcon,
                      key: ValueKey(treeIcon),
                      color: const Color.fromARGB(255, 137, 76, 175),
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Plantation Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          progressMessage,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 175, 76, 170),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: const Color.fromARGB(
                    255,
                    76,
                    122,
                    175,
                  ).withOpacity(0.10),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 175, 76, 167),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // TREE PREVIEW
  // ============================================================

  Widget _buildTreePreview() {
    final String name = treeNameController.text.trim();

    final String species = speciesController.text.trim();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey('$name-$species-$healthStatus'),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color.fromARGB(255, 155, 76, 175).withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  175,
                  76,
                  107,
                ).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.park,
                color: Color.fromARGB(255, 175, 76, 130),
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Your Tree' : name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    species.isEmpty ? 'Species not entered' : species,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            _healthIcon(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEALTH ICON
  // ============================================================

  Widget _healthIcon() {
    IconData icon;
    Color color;

    switch (healthStatus) {
      case 'Needs Attention':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;

      case 'Unhealthy':
        icon = Icons.health_and_safety_outlined;
        color = Colors.red;
        break;

      case 'Dead':
        icon = Icons.remove_circle_outline;
        color = Colors.grey;
        break;

      default:
        icon = Icons.favorite;
        color = const Color.fromARGB(255, 168, 76, 175);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Icon(icon, key: ValueKey(healthStatus), color: color, size: 28),
    );
  }

  // ============================================================
  // HEALTH SELECTOR
  // ============================================================

  Widget _buildHealthSelector() {
    final List<Map<String, dynamic>> options = [
      {
        'name': 'Healthy',
        'icon': Icons.favorite,
        'color': const Color.fromARGB(255, 76, 99, 175),
      },
      {
        'name': 'Needs Attention',
        'icon': Icons.warning_amber,
        'color': Colors.orange,
      },
      {'name': 'Unhealthy', 'icon': Icons.sick_outlined, 'color': Colors.red},
      {
        'name': 'Dead',
        'icon': Icons.remove_circle_outline,
        'color': Colors.grey,
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((option) {
        final String name = option['name'] as String;

        final IconData icon = option['icon'] as IconData;

        final Color color = option['color'] as Color;

        final bool selected = healthStatus == name;

        return AnimatedScale(
          scale: selected ? 1.03 : 1,
          duration: const Duration(milliseconds: 200),
          child: ChoiceChip(
            selected: selected,
            label: Text(name),
            avatar: Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : color,
            ),
            selectedColor: color,
            backgroundColor: Colors.grey.shade100,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (_) {
              setState(() {
                healthStatus = name;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // PHOTO SECTION
  // ============================================================

  Widget _buildPhotoSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selectedPhotoBytes != null
            ? const Color.fromARGB(255, 175, 76, 132).withOpacity(0.05)
            : Colors.grey.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selectedPhotoBytes != null
              ? const Color.fromARGB(255, 175, 76, 120).withOpacity(0.4)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: selectedPhotoBytes != null
                ? GestureDetector(
                    key: const ValueKey('photo'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return Dialog(
                            child: InteractiveViewer(
                              child: Image.memory(
                                selectedPhotoBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        selectedPhotoBytes!,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('camera'),
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        175,
                        76,
                        135,
                      ).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 55,
                      color: Color.fromARGB(255, 76, 160, 175),
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            photoText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSelectingPhoto ? null : selectPhoto,
              icon: isSelectingPhoto
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library_outlined),
              label: Text(
                selectedPhotoBytes == null
                    ? 'Choose Tree Photo'
                    : 'Change Photo',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 76, 168, 175),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOCATION SECTION
  // ============================================================

  Widget _buildLocationSection() {
    final bool locationSelected = latitude != null && longitude != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: locationSelected
            ? const Color.fromARGB(255, 175, 76, 168).withOpacity(0.06)
            : Colors.grey.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: locationSelected
              ? const Color.fromARGB(255, 175, 76, 145).withOpacity(0.4)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: locationSelected
                      ? const Color.fromARGB(
                          255,
                          76,
                          163,
                          175,
                        ).withOpacity(0.12)
                      : Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  locationSelected
                      ? Icons.location_on
                      : Icons.location_searching,
                  color: locationSelected
                      ? const Color.fromARGB(255, 175, 76, 172)
                      : Colors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tree Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locationText,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (locationSelected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed,
                    color: Color.fromARGB(255, 175, 76, 140),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Latitude: '
                      '${latitude!.toStringAsFixed(6)}\n'
                      'Longitude: '
                      '${longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isGettingLocation ? null : getCurrentLocation,
              icon: isGettingLocation
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                isGettingLocation
                    ? 'Getting Location...'
                    : locationSelected
                    ? 'Update Location'
                    : 'Get Current Location',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double glow = isSaving
            ? 0.08 + (_pulseController.value * 0.12)
            : 0.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: isSaving
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        76,
                        119,
                        175,
                      ).withOpacity(glow),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveTree,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 142, 56, 95),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color.fromARGB(
                  255,
                  187,
                  102,
                  149,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 5,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isSaving
                    ? const Row(
                        key: ValueKey('saving'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Saving Tree...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        key: ValueKey('save'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.park),
                          SizedBox(width: 10),
                          Text(
                            'Save Tree',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 76, 140, 175).withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color.fromARGB(255, 76, 158, 175)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ANIMATED SECTION
  // ============================================================

  Widget _animatedSection({required int index, required Widget child}) {
    final double start = index * 0.10;

    final Animation<double> animation = CurvedAnimation(
      parent: _pageController,
      curve: Interval(
        start.clamp(0.0, 0.7),
        (start + 0.3).clamp(0.3, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: const Text(
          'Add New Tree',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 153, 76, 175),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildFloatingBackground(),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // HERO
                // =================================================
                _animatedSection(
                  index: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _floatingController,
                      builder: (context, child) {
                        final double offset =
                            math.sin(_floatingController.value * 2 * math.pi) *
                            6;

                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 129, 157, 199),
                                  Color.fromARGB(255, 142, 56, 123),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.park,
                              color: Colors.white,
                              size: 52,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Plant a New Memory 🌱',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Record your tree and help '
                            'build a greener future.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // PROGRESS
                // =================================================
                _animatedSection(index: 1, child: _buildProgressCard()),

                const SizedBox(height: 22),

                // =================================================
                // PREVIEW
                // =================================================
                _animatedSection(index: 2, child: _buildTreePreview()),

                const SizedBox(height: 28),

                // =================================================
                // TREE DETAILS
                // =================================================
                _animatedSection(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Tree Details',
                        'Tell us about your tree',
                        Icons.eco,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: treeNameController,
                        focusNode: treeNameFocus,
                        label: 'Tree Name',
                        hint: 'Example: My Mango Tree',
                        icon: Icons.park_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: speciesController,
                        focusNode: speciesFocus,
                        label: 'Species',
                        hint: 'Example: Mango',
                        icon: Icons.local_florist_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: heightController,
                        focusNode: heightFocus,
                        label: 'Height',
                        hint: 'Example: 2.5 meters',
                        icon: Icons.height,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // DATE
                // =================================================
                _animatedSection(
                  index: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Plantation Date',
                        'When was this tree planted?',
                        Icons.calendar_month,
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: selectDate,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: selectedDate != null
                                ? const Color.fromARGB(
                                    255,
                                    153,
                                    76,
                                    175,
                                  ).withOpacity(0.07)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedDate != null
                                  ? const Color.fromARGB(255, 175, 76, 157)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    76,
                                    130,
                                    175,
                                  ).withOpacity(0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Color.fromARGB(255, 76, 157, 175),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  selectedDate == null
                                      ? 'Select plantation date'
                                      : '${selectedDate!.day}/'
                                            '${selectedDate!.month}/'
                                            '${selectedDate!.year}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: selectedDate != null
                                        ? const Color.fromARGB(
                                            255,
                                            175,
                                            76,
                                            175,
                                          )
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // HEALTH
                // =================================================
                _animatedSection(
                  index: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Tree Health',
                        'Select the current health condition',
                        Icons.health_and_safety_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildHealthSelector(),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // PHOTO
                // =================================================
                _animatedSection(
                  index: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Tree Photo',
                        'Add a photo to remember your tree',
                        Icons.camera_alt_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildPhotoSection(),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // LOCATION
                // =================================================
                _animatedSection(
                  index: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Tree Location',
                        'Save the exact plantation location',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildLocationSection(),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // SAVE
                // =================================================
                _animatedSection(index: 8, child: _buildSaveButton()),

                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.storage_rounded,
                        size: 16,
                        color: Color.fromARGB(255, 76, 157, 175),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'MySQL database',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    treeNameController.dispose();
    speciesController.dispose();
    heightController.dispose();

    treeNameFocus.dispose();
    speciesFocus.dispose();
    heightFocus.dispose();

    _pageController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();

    super.dispose();
  }
}
