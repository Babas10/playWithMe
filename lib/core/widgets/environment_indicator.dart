import 'package:flutter/material.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_service.dart';

/// Widget that displays the current environment and Firebase connection status
/// This helps developers and testers know which environment they're using
class EnvironmentIndicator extends StatelessWidget {
  final bool showDetails;

  const EnvironmentIndicator({
    super.key,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show in non-production environments
    if (EnvironmentConfig.isProduction) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: _getEnvironmentColor(),
        border: Border(
          bottom: BorderSide(
            color: _getEnvironmentColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: showDetails ? _buildDetailedView() : _buildSimpleView(),
      ),
    );
  }

  Widget _buildSimpleView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getEnvironmentIcon(),
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          '${EnvironmentConfig.environmentName} Environment',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          FirebaseService.isInitialized ? Icons.cloud_done : Icons.cloud_off,
          size: 16,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildDetailedView() {
    final connectionInfo = FirebaseService.getConnectionInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getEnvironmentIcon(),
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              '${EnvironmentConfig.environmentName} Environment',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              FirebaseService.isInitialized ? Icons.cloud_done : Icons.cloud_off,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              FirebaseService.isInitialized ? 'Connected' : 'Disconnected',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Project: ${connectionInfo['projectId']}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getEnvironmentColor() {
    switch (EnvironmentConfig.environment) {
      case Environment.dev:
        return Colors.red.shade600;
      case Environment.stg:
        return Colors.orange.shade600;
      case Environment.prod:
        return Colors.green.shade600;
    }
  }

  IconData _getEnvironmentIcon() {
    switch (EnvironmentConfig.environment) {
      case Environment.dev:
        return Icons.code;
      case Environment.stg:
        return Icons.science;
      case Environment.prod:
        return Icons.public;
    }
  }
}

/// A floating debug panel that shows Firebase connection details
/// Useful for debugging and testing
class FirebaseDebugPanel extends StatefulWidget {
  const FirebaseDebugPanel({super.key});

  @override
  State<FirebaseDebugPanel> createState() => _FirebaseDebugPanelState();
}

class _FirebaseDebugPanelState extends State<FirebaseDebugPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Only show in development environment
    if (!EnvironmentConfig.isDevelopment) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isExpanded ? _buildExpandedPanel() : _buildCollapsedPanel(),
        ),
      ),
    );
  }

  Widget _buildCollapsedPanel() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = true),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Debug',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPanel() {
    final connectionInfo = FirebaseService.getConnectionInfo();

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Firebase Debug Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Environment:', EnvironmentConfig.environmentName),
          _buildInfoRow('Project ID:', connectionInfo['projectId']),
          _buildInfoRow('Initialized:', connectionInfo['isInitialized'].toString()),
          _buildInfoRow('App Name:', connectionInfo['appName'] ?? 'N/A'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                'Test Connection',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    final success = await FirebaseService.testConnection();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Firebase connection successful!'
                : '❌ Firebase connection failed!',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}