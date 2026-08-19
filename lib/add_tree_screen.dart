import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddTreeScreen extends StatefulWidget {
  const AddTreeScreen({super.key});

  @override
  State<AddTreeScreen> createState() => _AddTreeScreenState();
}

class _AddTreeScreenState extends State<AddTreeScreen> {
  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController treeNameController =
      TextEditingController();

  final TextEditingController speciesController =
      TextEditingController();

  final TextEditingController heightController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  DateTime? selectedDate;

  String healthStatus = 'Healthy';

  // GPS
  double? latitude;
  double? longitude;

  String locationText = 'Location not selected';

  bool isGettingLocation = false;

  // PHOTO
  Uint8List? selectedPhotoBytes;

  String photoText = 'No photo selected';

  bool isSelectingPhoto = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    treeNameController.dispose();
    speciesController.dispose();
    heightController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> selectDate() async {
    final DateTime? pickedDate =
        await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2000),

      lastDate: DateTime.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
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
  // GPS LOCATION
  // ============================================================

  Future<void> getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      // --------------------------------------------------------
      // Check location service
      // --------------------------------------------------------

      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          isGettingLocation = false;
        });

        showMessage(
          'Please enable location services.',
        );

        return;
      }

      // --------------------------------------------------------
      // Check permission
      // --------------------------------------------------------

      LocationPermission permission =
          await Geolocator.checkPermission();

      // --------------------------------------------------------
      // Request permission
      // --------------------------------------------------------

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();

        if (permission ==
            LocationPermission.denied) {
          setState(() {
            isGettingLocation = false;
          });

          showMessage(
            'Location permission was denied.',
          );

          return;
        }
      }

      // --------------------------------------------------------
      // Permanently denied
      // --------------------------------------------------------

      if (permission ==
          LocationPermission.deniedForever) {
        setState(() {
          isGettingLocation = false;
        });

        showMessage(
          'Location permission is permanently denied. '
          'Please allow location from browser settings.',
        );

        return;
      }

      // --------------------------------------------------------
      // Get current position
      // --------------------------------------------------------

      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // --------------------------------------------------------
      // Save coordinates
      // --------------------------------------------------------

      setState(() {
        latitude = position.latitude;

        longitude = position.longitude;

        locationText =
            'Latitude: ${position.latitude.toStringAsFixed(6)}\n'
            'Longitude: ${position.longitude.toStringAsFixed(6)}';

        isGettingLocation = false;
      });

      showMessage(
        'Current location obtained successfully 📍',
      );
    } catch (e) {
      setState(() {
        isGettingLocation = false;
      });

      showMessage(
        'Unable to get location.',
      );
    }
  }

  // ============================================================
  // PHOTO PICKER
  // ============================================================

  Future<void> addPhoto() async {
    setState(() {
      isSelectingPhoto = true;
    });

    try {
      final ImagePicker picker =
          ImagePicker();

      final XFile? image =
          await picker.pickImage(
        source: ImageSource.gallery,

        imageQuality: 80,
      );

      // User cancelled selection
      if (image == null) {
        setState(() {
          isSelectingPhoto = false;
        });

        return;
      }

      // Read image as bytes.
      // This works well with Flutter Web.
      final Uint8List bytes =
          await image.readAsBytes();

      setState(() {
        selectedPhotoBytes = bytes;

        photoText = image.name;

        isSelectingPhoto = false;
      });

      showMessage(
        'Tree photo selected successfully 📷',
      );
    } catch (e) {
      setState(() {
        isSelectingPhoto = false;
      });

      showMessage(
        'Unable to select photo.',
      );
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: Colors.green,

        behavior:
            SnackBarBehavior.floating,

        duration:
            const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // SAVE TREE
  // ============================================================

  void saveTree() {
    // Validate form
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    // Check date
    if (selectedDate == null) {
      showMessage(
        'Please select plantation date.',
      );

      return;
    }

    // Check GPS
    if (latitude == null ||
        longitude == null) {
      showMessage(
        'Please get the current location.',
      );

      return;
    }

    // Check photo
    if (selectedPhotoBytes == null) {
      showMessage(
        'Please add a tree photo.',
      );

      return;
    }

    // For now show saved information.
    // Firebase will be connected in the next stage.

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),

              SizedBox(width: 10),

              Text(
                'Tree Ready to Save',
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Tree Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  '🌳 Name: '
                  '${treeNameController.text}',
                ),

                const SizedBox(height: 8),

                Text(
                  '🌿 Species: '
                  '${speciesController.text}',
                ),

                const SizedBox(height: 8),

                Text(
                  '📅 Date: '
                  '${selectedDate!.day}/'
                  '${selectedDate!.month}/'
                  '${selectedDate!.year}',
                ),

                const SizedBox(height: 8),

                Text(
                  '📏 Height: '
                  '${heightController.text} meters',
                ),

                const SizedBox(height: 8),

                Text(
                  '❤️ Health: '
                  '$healthStatus',
                ),

                const SizedBox(height: 8),

                Text(
                  '📍 Latitude: '
                  '${latitude!.toStringAsFixed(6)}',
                ),

                const SizedBox(height: 8),

                Text(
                  '📍 Longitude: '
                  '${longitude!.toStringAsFixed(6)}',
                ),

                const SizedBox(height: 15),

                // Photo preview
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),

                  child: Image.memory(
                    selectedPhotoBytes!,

                    width: double.infinity,

                    height: 180,

                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Firebase storage will be connected next.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({
    required String hintText,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,

      prefixIcon: Icon(
        icon,
        color: Colors.green,
      ),

      suffixText: suffixText,

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: BorderSide.none,
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: Colors.green,
          width: 2,
        ),
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 15,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(String title) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F8F4),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.green,

        foregroundColor:
            Colors.white,

        elevation: 0,

        title: const Text(
          'Add New Tree',

          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER ICON
              // ==================================================

              const Center(
                child: Icon(
                  Icons.forest,
                  size: 75,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Record a New Tree 🌱',

                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // TREE NAME
              // ==================================================

              sectionTitle(
                'Tree Name',
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    treeNameController,

                decoration:
                    inputDecoration(
                  hintText:
                      'Example: Neem',
                  icon: Icons.forest,
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter tree name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // SPECIES
              // ==================================================

              sectionTitle(
                'Species',
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    speciesController,

                decoration:
                    inputDecoration(
                  hintText:
                      'Example: Azadirachta indica',
                  icon: Icons.eco,
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter species';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PLANTATION DATE
              // ==================================================

              sectionTitle(
                'Plantation Date',
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: selectDate,

                borderRadius:
                    BorderRadius.circular(12),

                child: Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color:
                            Colors.green,
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Text(
                          selectedDate ==
                                  null
                              ? 'Select plantation date'
                              : '${selectedDate!.day}/'
                                '${selectedDate!.month}/'
                                '${selectedDate!.year}',

                          style:
                              const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_drop_down,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TREE HEIGHT
              // ==================================================

              sectionTitle(
                'Tree Height',
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    heightController,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    inputDecoration(
                  hintText:
                      'Example: 1.5',
                  icon: Icons.height,
                  suffixText:
                      'meters',
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter tree height';
                  }

                  final double?
                      height =
                      double.tryParse(
                    value,
                  );

                  if (height == null ||
                      height <= 0) {
                    return
                        'Enter a valid height';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // HEALTH STATUS
              // ==================================================

              sectionTitle(
                'Health Status',
              ),

              const SizedBox(height: 8),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<String>(
                    value:
                        healthStatus,

                    isExpanded: true,

                    items: const [
                      DropdownMenuItem(
                        value:
                            'Healthy',

                        child: Text(
                          'Healthy 🌿',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'Needs Attention',

                        child: Text(
                          'Needs Attention ⚠️',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'Unhealthy',

                        child: Text(
                          'Unhealthy',
                        ),
                      ),
                    ],

                    onChanged:
                        (value) {
                      if (value != null) {
                        setState(() {
                          healthStatus =
                              value;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // LOCATION
              // ==================================================

              sectionTitle(
                'Location',
              ),

              const SizedBox(height: 8),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Icon(
                      Icons.location_on,
                      color:
                          Colors.green,
                      size: 28,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        locationText,

                        style:
                            const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // GPS BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child:
                    OutlinedButton.icon(
                  onPressed:
                      isGettingLocation
                          ? null
                          : getCurrentLocation,

                  icon:
                      isGettingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.green,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                            ),

                  label: Text(
                    isGettingLocation
                        ? 'Getting Location...'
                        : 'Get Current Location',

                    style:
                        const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.green,

                    side:
                        const BorderSide(
                      color:
                          Colors.green,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TREE PHOTO
              // ==================================================

              sectionTitle(
                'Tree Photo',
              ),

              const SizedBox(height: 8),

              // Photo preview
              if (selectedPhotoBytes !=
                  null)
                Container(
                  width:
                      double.infinity,

                  height: 220,

                  margin:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    child: Image.memory(
                      selectedPhotoBytes!,

                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Photo filename
              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.image,
                      color:
                          Colors.green,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        photoText,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // PHOTO BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child:
                    OutlinedButton.icon(
                  onPressed:
                      isSelectingPhoto
                          ? null
                          : addPhoto,

                  icon:
                      isSelectingPhoto
                          ? const SizedBox(
                              width: 20,
                              height: 20,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.green,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                            ),

                  label: Text(
                    isSelectingPhoto
                        ? 'Selecting Photo...'
                        : 'Add Tree Photo',

                    style:
                        const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.green,

                    side:
                        const BorderSide(
                      color:
                          Colors.green,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // SAVE TREE BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height: 58,

                child:
                    ElevatedButton.icon(
                  onPressed: saveTree,

                  icon: const Icon(
                    Icons.save,
                  ),

                  label: const Text(
                    'SAVE TREE',

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,

                    foregroundColor:
                        Colors.white,

                    elevation: 3,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}