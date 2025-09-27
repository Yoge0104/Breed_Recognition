import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const BreedDemoApp());

class BreedDemoApp extends StatelessWidget {
  const BreedDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breed Recognition Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: DemoScreen.routeName,
      routes: {DemoScreen.routeName: (context) => const DemoScreen()},
    );
  }
}

class BreedInfo {
  final String name;
  final String species;
  final String origin;
  final String primaryUse;
  final List<String> traits;
  final String description;

  const BreedInfo({
    required this.name,
    required this.species,
    required this.origin,
    required this.primaryUse,
    required this.traits,
    required this.description,
  });
}

class BreedPrediction {
  final BreedInfo breed;
  final double confidence;

  const BreedPrediction({required this.breed, required this.confidence});
}

final List<BreedInfo> _breedLibrary = [
  const BreedInfo(
    name: 'Gir',
    species: 'Cattle',
    origin: 'Gujarat, India',
    primaryUse: 'Dairy',
    traits: const [
      'Heat tolerant',
      'High butterfat milk',
      'Distinctive curved horns',
    ],
    description:
        'Gir cattle are prized for their high milk yield and ability to thrive in hot, humid climates.',
  ),
  const BreedInfo(
    name: 'Sahiwal',
    species: 'Cattle',
    origin: 'Punjab, India & Pakistan',
    primaryUse: 'Dairy',
    traits: const [
      'Calm temperament',
      'Disease resilient',
      'Adaptable to heat',
    ],
    description:
        'Sahiwal is one of the best dairy breeds of zebu cattle, known for rich milk production and docility.',
  ),
  const BreedInfo(
    name: 'Kankrej',
    species: 'Cattle',
    origin: 'Gujarat & Rajasthan, India',
    primaryUse: 'Dual purpose',
    traits: const ['Strong draft power', 'Long lifespan', 'Hardy hooves'],
    description:
        'Kankrej cattle combine good milking ability with strength, making them valuable for both dairy and farm work.',
  ),
  const BreedInfo(
    name: 'Tharparkar',
    species: 'Cattle',
    origin: 'Rajasthan, India',
    primaryUse: 'Dual purpose',
    traits: const ['Heat tolerance', 'Efficient grazer', 'Drought resilient'],
    description:
        'Tharparkar cattle are suited for arid regions, offering reliable milk and moderate draft capabilities.',
  ),
  const BreedInfo(
    name: 'Red Sindhi',
    species: 'Cattle',
    origin: 'Sindh, Pakistan',
    primaryUse: 'Dairy',
    traits: const ['Red coat', 'High fertility', 'Long lactation'],
    description:
        'Red Sindhi cattle are valued for their red coat and consistent milk yield even under tropical climates.',
  ),
  const BreedInfo(
    name: 'Murrah',
    species: 'Buffalo',
    origin: 'Haryana & Punjab, India',
    primaryUse: 'Dairy',
    traits: const [
      'High butterfat milk',
      'Jet-black skin',
      'Tightly curled horns',
    ],
    description:
        'Murrah buffalo are the global standard for dairy buffalo, producing high-fat milk and adapting well to hot conditions.',
  ),
  const BreedInfo(
    name: 'Surti',
    species: 'Buffalo',
    origin: 'Gujarat, India',
    primaryUse: 'Dairy',
    traits: const ['Moderate size', 'White tail switch', 'High milk fat'],
    description:
        'Surti buffalo are efficient dairy producers with gentle temperaments and easily recognizable white markings.',
  ),
  const BreedInfo(
    name: 'Jaffarabadi',
    species: 'Buffalo',
    origin: 'Saurashtra, India',
    primaryUse: 'Dairy',
    traits: const ['Massive frame', 'Heavy milk yield', 'Drooping horns'],
    description:
        'Jaffarabadi buffalo are among the heaviest buffalo breeds and are reputed for rich milk and strong build.',
  ),
  const BreedInfo(
    name: 'Banni',
    species: 'Buffalo',
    origin: 'Kutch, India',
    primaryUse: 'Dairy',
    traits: const ['Night grazing', 'Disease resilient', 'High butterfat'],
    description:
        'Banni buffalo thrive in desert conditions and are known for high-fat milk from traditional night grazing practices.',
  ),
  const BreedInfo(
    name: 'Pandharpuri',
    species: 'Buffalo',
    origin: 'Maharashtra, India',
    primaryUse: 'Dairy',
    traits: const [
      'Long twisted horns',
      'Long lactation',
      'Adapted to semi-arid',
    ],
    description:
        'Pandharpuri buffalo are easily identified by their long, twisted horns and steady milk production.',
  ),
];

class DemoScreen extends StatefulWidget {
  static const String routeName = '/demo';

  const DemoScreen({super.key});

  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  XFile? _image;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  List<BreedPrediction>? _predictions;
  String? _feedback;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Breed Recognition')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 880;

            final Widget content = SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroSection(),
                      const SizedBox(height: 20),
                      _buildImagePreviewSection(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator()),
                      if (_predictions != null && _predictions!.isNotEmpty) ...[
                        Text(
                          'Top Matches',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._predictions!
                            .map(
                              (prediction) => _buildPredictionCard(prediction),
                            )
                            .toList(),
                      ] else if (!_isLoading && _image != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'No predictions available yet. Try uploading a different angle or clearer photo.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      if (_predictions != null && _predictions!.isNotEmpty)
                        _buildFeedbackSection(),
                    ],
                  ),
                ),
              ),
            );

            if (!isWide) {
              return content;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: content)],
            );
          },
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows &&
        source == ImageSource.camera) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera capture is not supported on Windows for this demo. Please pick an image from the gallery.',
          ),
        ),
      );
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      if (bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected image is unavailable or unsupported on this platform.',
            ),
          ),
        );
        return;
      }

      final filePath = pickedFile.path;

      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
        _predictions = null;
        _feedback = null;
        _isLoading = true;
      });

      final results = await _simulatePrediction(pickedFile);
      if (!mounted) return;

      setState(() {
        _predictions = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to access image: $error')));
    }
  }

  void submitFeedback(String value) {
    setState(() {
      _feedback = value;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Feedback received for $value")));
  }

  Widget _buildFeedbackSection() {
    final theme = Theme.of(context);
    final bool hasProvidedFeedback = _feedback != null && _feedback!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us improve the results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Let us know whether the predicted breed looks correct.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => submitFeedback('Match confirmed'),
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('Match confirmed'),
                ),
                ElevatedButton.icon(
                  onPressed: () => submitFeedback('Needs improvement'),
                  icon: const Icon(Icons.feedback_outlined),
                  label: const Text('Needs improvement'),
                ),
                OutlinedButton.icon(
                  onPressed: () => submitFeedback('Wrong breed'),
                  icon: const Icon(Icons.close),
                  label: const Text('Wrong breed'),
                ),
              ],
            ),
            if (hasProvidedFeedback) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Thanks for your feedback: ${_feedback!}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<List<BreedPrediction>> _simulatePrediction(XFile imageFile) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final random = Random(imageFile.path.hashCode);
    final pool = List<BreedInfo>.from(_breedLibrary)..shuffle(random);
    final topCandidates = pool.take(3).toList();

    return topCandidates.asMap().entries.map((entry) {
      final index = entry.key;
      final BreedInfo breed = entry.value;

      final base = 0.92 - index * 0.08;
      final jitter = random.nextDouble() * 0.03;
      final num confidenceValue = (base + jitter).clamp(0.6, 0.98);

      return BreedPrediction(
        breed: breed,
        confidence: confidenceValue.toDouble(),
      );
    }).toList();
  }

  Widget _buildPredictionCard(BreedPrediction prediction) {
    final breed = prediction.breed;
    final percentage = (prediction.confidence * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    breed.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${breed.species} • ${breed.primaryUse} • ${breed.origin}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: prediction.confidence.clamp(0.0, 1.0),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              breed.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (breed.traits.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: breed.traits
                    .map((trait) => Chip(label: Text(trait)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload a livestock photo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a clear photo from your device or take a new one. We will highlight the most likely breeds and let you confirm the match.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: Make sure the animal fills the frame for best results.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 520;
        final double buttonWidth = isWide ? 220.0 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton.icon(
                onPressed: () => pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton.icon(
                onPressed: () => pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreviewSection() {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(20);
    final previewKey = ValueKey<String>(_image?.path ?? 'placeholder');

    Widget previewChild;
    if (_image == null) {
      previewChild = AnimatedContainer(
        key: previewKey,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.18),
            width: 1.6,
          ),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No image selected yet',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Choose “Upload Image” or “Take Photo” to see a preview here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.72),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Upload image'),
                  ),
                  if (!kIsWeb)
                    OutlinedButton.icon(
                      onPressed: () => pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Take a photo'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      previewChild = AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: ClipRRect(
          key: previewKey,
          borderRadius: borderRadius,
          child: _imageBytes != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxHeight =
                        constraints.maxWidth / (kIsWeb ? 1.4 : 1.2);
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxHeight.clamp(200, 340),
                        minHeight: 200,
                      ),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: FittedBox(
                          fit: kIsWeb ? BoxFit.contain : BoxFit.cover,
                          alignment: Alignment.center,
                          clipBehavior: Clip.hardEdge,
                          child: Image.memory(
                            _imageBytes!,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  height: 240,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: borderRadius,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 42,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preview unavailable for this image.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(aspectRatio: 4 / 3, child: previewChild),
      ],
    );
  }
}
