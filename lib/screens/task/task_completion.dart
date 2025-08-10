import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/models/task_model.dart';
import 'package:vcare_attendance/router/router_name.dart';

class TaskCompletionScreen extends StatefulWidget {
  final String taskId;

  const TaskCompletionScreen({super.key, required this.taskId});

  @override
  State<TaskCompletionScreen> createState() => _TaskCompletionScreenState();
}

class _TaskCompletionScreenState extends State<TaskCompletionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // Keep
  final _observationController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Task? _task;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _selectedSummary;
  File? _selectedImage;
  Position? _currentPosition;
  bool _locationEnabled = false;

  final List<String> _summaryOptions = [
    'Visited location and discussed product',
    'Meeting completed successfully',
    'Follow-up required',
    'Product demonstration given',
    'Information collected',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadTask();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _observationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);

    try {
      final taskId = int.parse(widget.taskId);
      final task = await Api.task.getTask(taskId);

      setState(() {
        _task = task;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load task details');
    }
  }

  Future<void> _checkLocationPermission() async {
    final permission = await Permission.location.status;
    if (permission.isGranted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _requestLocation() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      await _getCurrentLocation();
    } else {
      _showErrorSnackBar('Location permission is required for task completion');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
      ));

      setState(() {
        _currentPosition = position;
        _locationEnabled = true;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to get current location');
    }
  }

  Future<void> _openLiveCamera() async {
    try {
      final File? capturedPhoto = await context.pushNamed<File?>(
        RouteNames.liveCamera,
      );
      if (capturedPhoto != null) {
        setState(() {
          _selectedImage = capturedPhoto;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open camera: ${e.toString()}');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submitCompletion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSummary == null) {
      _showErrorSnackBar('Please select a summary');
      return;
    }

    if (_selectedImage == null) {
      _showErrorSnackBar('Please take a photo');
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final response = await Api.task.completeTask(
        taskId: int.parse(widget.taskId),
        name: _nameController.text.trim(),
        summary: _selectedSummary!,
        observation: _observationController.text.trim(),
        photos: _selectedImage!,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );

      if (response.success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(response.message ?? 'Failed to complete task');
      }
    } catch (e) {
      _showErrorSnackBar('Network error occurred');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Task Completed!'),
          ],
        ),
        content: const Text(
            'Your task has been successfully completed and submitted.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(true); // Return to task list with success flag
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Complete Task'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildForm(theme),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      title: const Text(
        'Complete Task',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.square(80),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _task?.statusColor.withAlpha(200) ?? Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _task?.statusIcon ?? Icons.task,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _task?.title ?? 'Task',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${_task?.id ?? widget.taskId}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withAlpha(180),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameCard(theme),
            const SizedBox(height: 16),
            _buildSummaryCard(theme),
            const SizedBox(height: 16),
            _buildObservationCard(theme),
            const SizedBox(height: 16),
            _buildPhotosCard(theme),
            const SizedBox(height: 16),
            _buildLocationStatusCard(theme),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildNameCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Name *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter Location, client or type name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Name is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Observation *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observationController,
              textInputAction: TextInputAction.next,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your detailed observations...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Observation is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSummary,
              decoration: InputDecoration(
                hintText: 'Select summary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              items: _summaryOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSummary = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a summary';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Live Photo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_selectedImage != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified,
                            size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'TIMESTAMPED',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _openLiveCamera,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Retake', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _openLiveCamera,
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label:
                        const Text('Capture', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null) ...[
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      // Timestamp indicator
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'TIMESTAMPED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withAlpha(75),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_enhance,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No photo captured',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Photo will be timestamped for security',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildLocationStatusCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _locationEnabled ? Icons.location_on : Icons.location_off,
                  color:
                      _locationEnabled ? Colors.green : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_locationEnabled) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location captured successfully',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              if (_currentPosition != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: theme.colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location access required',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _requestLocation,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Allow Location Access'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
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

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitCompletion,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle),
            label: Text(_isSubmitting ? 'Submitting...' : 'Complete Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
