import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../common/custom_button.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails, VoidCallback)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => ErrorBoundaryState();

  static ErrorBoundaryState? of(BuildContext context) {
    return context.findAncestorStateOfType<ErrorBoundaryState>();
  }
}

class ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() => _error = details);
        widget.onError?.call();
      }
      FlutterError.dumpErrorToConsole(details);
    };
  }

  void _reset() {
    if (mounted) {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _reset);
      }
      return _DefaultErrorWidget(error: _error!, onRetry: _reset);
    }
    return widget.child;
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.toPay),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Unknown error',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
              SizedBox(height: 24),
              _RetryButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton();

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Retry',
      onPressed: () {
        final state = context.findAncestorStateOfType<ErrorBoundaryState>();
        state?._reset();
      },
      color: AppColors.primary,
    );
  }
}

/// Consistent loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!,
                          style: const TextStyle(color: AppColors.textDark)),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Consistent empty state with action
class EmptyStateWithAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWithAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              CustomButton(text: actionLabel!, onPressed: onAction!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Consistent error state with retry
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.toPay),
            const SizedBox(height: 16),
            const Text('Error',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(text: retryLabel!, onPressed: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}