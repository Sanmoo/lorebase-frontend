import 'package:flutter/material.dart';
import '../data/tracking_status.dart';

class StatusBottomSheet extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusSelected;

  const StatusBottomSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Update Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...TrackingStatus.values.map((status) {
              final isSelected = status.value == currentStatus;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                title: Text(status.label),
                onTap: () {
                  onStatusSelected(status.value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
