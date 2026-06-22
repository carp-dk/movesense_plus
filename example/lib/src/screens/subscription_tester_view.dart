// Contains the manual MDS subscription tester screen.
//
// Parts:
// - `SubscriptionTesterView`, subscription form and active stream controls.
// - `_SubscriptionPreviewCard`, latest notification display.

import 'package:flutter/material.dart';

import '../state/movesense_example_scope.dart';
import '../utils/movesense_example_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/connected_device_picker.dart';

/// Form for manually starting and stopping one MDS subscription.
class SubscriptionTesterView extends StatefulWidget {
  /// Creates the subscription tester view.
  const SubscriptionTesterView({super.key});

  @override
  State<SubscriptionTesterView> createState() => _SubscriptionTesterViewState();
}

class _SubscriptionTesterViewState extends State<SubscriptionTesterView> {
  final TextEditingController _labelController = TextEditingController(
    text: 'Manual subscription',
  );
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _resourceController = TextEditingController(
    text: '/Meas/Acc/13',
  );
  final TextEditingController _contractController = TextEditingController(
    text: '{}',
  );
  bool _seededSerial = false;
  String? _activeKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededSerial) return;
    final preferredSerial = MovesenseExampleScope.watch(
      context,
    ).preferredSerial;
    if (preferredSerial.isNotEmpty) {
      _serialController.text = preferredSerial;
      _seededSerial = true;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _serialController.dispose();
    _resourceController.dispose();
    _contractController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    final activeKey = _activeKey;
    final isActive =
        activeKey != null && controller.isSubscriptionActive(activeKey);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: <Widget>[
        ConnectedDevicePicker(
          selectedSerial: _serialController.text,
          onSelected: (serial) => setState(() {
            _serialController.text = serial;
            _seededSerial = true;
          }),
        ),
        _SubscriptionFormCard(
          labelController: _labelController,
          serialController: _serialController,
          resourceController: _resourceController,
          contractController: _contractController,
          isActive: isActive,
          onStartStop: isActive
              ? () => _stopSubscription(context)
              : () => _startSubscription(context),
        ),
        if (activeKey != null)
          _SubscriptionPreviewCard(subscriptionKey: activeKey),
        if (controller.lastError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InlineError(message: controller.lastError!),
          ),
      ],
    );
  }

  void _startSubscription(BuildContext context) {
    final controller = MovesenseExampleScope.read(context);
    final uri = buildSubscriptionUri(
      serial: _serialController.text,
      resource: _resourceController.text,
    );
    if (uri == null) {
      showExampleSnackBar(context, 'Enter a serial before subscribing.');
      return;
    }

    final key = _labelController.text.trim().isEmpty
        ? uri
        : _labelController.text.trim();
    setState(() => _activeKey = key);
    controller.startSubscription(key, uri, _contractController.text);
  }

  void _stopSubscription(BuildContext context) {
    final key = _activeKey;
    if (key == null) return;
    MovesenseExampleScope.read(context).stopSubscription(key);
  }
}

class _SubscriptionFormCard extends StatelessWidget {
  const _SubscriptionFormCard({
    required this.labelController,
    required this.serialController,
    required this.resourceController,
    required this.contractController,
    required this.isActive,
    required this.onStartStop,
  });

  final TextEditingController labelController;
  final TextEditingController serialController;
  final TextEditingController resourceController;
  final TextEditingController contractController;
  final bool isActive;
  final VoidCallback onStartStop;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'MDS subscription',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _SubscriptionPresetChips(resourceController: resourceController),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: serialController,
              decoration: const InputDecoration(
                labelText: 'Serial',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resourceController,
              decoration: const InputDecoration(
                labelText: 'Subscription resource',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contractController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Contract JSON',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onStartStop,
              icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
              label: Text(isActive ? 'Stop subscription' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionPresetChips extends StatelessWidget {
  const _SubscriptionPresetChips({required this.resourceController});

  final TextEditingController resourceController;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ActionChip(
          avatar: const Icon(Icons.show_chart),
          label: const Text('Acc 13 Hz'),
          onPressed: () => resourceController.text = '/Meas/Acc/13',
        ),
        ActionChip(
          avatar: const Icon(Icons.monitor_heart),
          label: const Text('HR'),
          onPressed: () => resourceController.text = '/Meas/HR',
        ),
      ],
    );
  }
}

class _SubscriptionPreviewCard extends StatelessWidget {
  const _SubscriptionPreviewCard({required this.subscriptionKey});

  final String subscriptionKey;

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    final body = controller.latestSubscriptionData(subscriptionKey);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              subscriptionKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SelectableText(body.isEmpty ? 'Waiting for notifications.' : body),
          ],
        ),
      ),
    );
  }
}
