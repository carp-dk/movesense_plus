// Contains the one-shot MDS request tester screen.
//
// Parts:
// - `RequestTesterView`, request form and result state.
// - `_ResponseCard`, response display.

import 'package:movesense_plus/movesense_plus.dart';
import 'package:flutter/material.dart';

import '../state/movesense_example_scope.dart';
import '../utils/movesense_example_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/connected_device_picker.dart';

/// Form for manually sending MDS GET, PUT, POST, and DELETE requests.
class RequestTesterView extends StatefulWidget {
  /// Creates the request tester view.
  const RequestTesterView({super.key});

  @override
  State<RequestTesterView> createState() => _RequestTesterViewState();
}

class _RequestTesterViewState extends State<RequestTesterView> {
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _resourceController = TextEditingController(
    text: '/System/Info',
  );
  final TextEditingController _contractController = TextEditingController(
    text: '{}',
  );
  MdsRequestMethod _method = MdsRequestMethod.get;
  bool _seededSerial = false;

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
    _serialController.dispose();
    _resourceController.dispose();
    _contractController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
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
        _RequestFormCard(
          method: _method,
          serialController: _serialController,
          resourceController: _resourceController,
          contractController: _contractController,
          onMethodChanged: (method) => setState(() => _method = method),
          onSend: () => _sendRequest(context),
        ),
        if (controller.lastResponse != null)
          _ResponseCard(response: controller.lastResponse!),
        if (controller.lastError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InlineError(message: controller.lastError!),
          ),
      ],
    );
  }

  void _sendRequest(BuildContext context) {
    final controller = MovesenseExampleScope.read(context);
    final uri = buildRequestUri(
      serial: _serialController.text,
      resource: _resourceController.text,
    );
    if (uri == null) {
      showExampleSnackBar(context, 'Enter a serial or a full suunto:// URI.');
      return;
    }

    controller.sendRequest(_method, uri, _contractController.text);
  }
}

class _RequestFormCard extends StatelessWidget {
  const _RequestFormCard({
    required this.method,
    required this.serialController,
    required this.resourceController,
    required this.contractController,
    required this.onMethodChanged,
    required this.onSend,
  });

  final MdsRequestMethod method;
  final TextEditingController serialController;
  final TextEditingController resourceController;
  final TextEditingController contractController;
  final ValueChanged<MdsRequestMethod> onMethodChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('MDS request', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<MdsRequestMethod>(
              initialValue: method,
              decoration: const InputDecoration(
                labelText: 'Method',
                border: OutlineInputBorder(),
              ),
              items: MdsRequestMethod.values.map((method) {
                return DropdownMenuItem<MdsRequestMethod>(
                  value: method,
                  child: Text(method.nativeName),
                );
              }).toList(),
              onChanged: (method) {
                if (method != null) onMethodChanged(method);
              },
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
                labelText: 'Resource or full request URI',
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
              onPressed: onSend,
              icon: const Icon(Icons.send),
              label: const Text('Send request'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({required this.response});

  final MdsResponse response;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            KeyValueRow(label: 'Status', value: response.statusCode.toString()),
            const SizedBox(height: 12),
            Text('Body', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SelectableText(prettyJson(response.body)),
          ],
        ),
      ),
    );
  }
}
