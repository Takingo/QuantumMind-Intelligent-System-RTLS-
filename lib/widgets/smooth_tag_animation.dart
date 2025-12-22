import 'package:flutter/material.dart';
import '../models/map_element_models.dart';
import '../services/telemetry_service.dart';

/// Smooth Tag Animation Widget for animating tag movements
class SmoothTagAnimation extends StatefulWidget {
  final MapTag tag;
  final TelemetryService telemetryService;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const SmoothTagAnimation({
    super.key,
    required this.tag,
    required this.telemetryService,
    this.animationDuration = const Duration(milliseconds: 200),
    this.onTap,
  });

  @override
  State<SmoothTagAnimation> createState() => _SmoothTagAnimationState();
}

class _SmoothTagAnimationState extends State<SmoothTagAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  Offset _currentPosition = Offset.zero;
  Offset _targetPosition = Offset.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = Offset(widget.tag.x, widget.tag.y);
    _targetPosition = Offset(widget.tag.x, widget.tag.y);

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _setupAnimations();

    // Listen for telemetry updates
    _listenForTelemetryUpdates();
  }

  void _setupAnimations() {
    _positionAnimation = Tween<Offset>(
      begin: _currentPosition,
      end: _targetPosition,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentPosition = _targetPosition;
          _isAnimating = false;
        });
      }
    });
  }

  void _listenForTelemetryUpdates() {
    // In a real implementation, this would listen to a stream
    // For now, we'll simulate updates
  }

  @override
  void didUpdateWidget(covariant SmoothTagAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if tag position has changed
    if (oldWidget.tag.x != widget.tag.x || oldWidget.tag.y != widget.tag.y) {
      _updateTargetPosition(Offset(widget.tag.x, widget.tag.y));
    }
  }

  void _updateTargetPosition(Offset newPosition) {
    if (_isAnimating) {
      // If already animating, update the target
      _targetPosition = newPosition;
      _controller.stop();
    } else {
      // Start new animation
      _targetPosition = newPosition;
      _isAnimating = true;
    }

    // Update animations
    _positionAnimation = Tween<Offset>(
      begin: _currentPosition,
      end: _targetPosition,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Restart animation
    _controller
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentPosition = _positionAnimation.value;
        final currentScale = _scaleAnimation.value;

        return Positioned(
          left: currentPosition.dx - (30 * currentScale / 2),
          top: currentPosition.dy - (30 * currentScale / 2),
          child: Transform.scale(
            scale: currentScale,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 30 * currentScale,
                height: 30 * currentScale,
                decoration: BoxDecoration(
                  color: widget.tag.type.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tag.type.color.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.tag.type.icon,
                    color: Colors.white,
                    size: 16 * currentScale,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated Tag List Widget for smooth tag list updates
class AnimatedTagList extends StatefulWidget {
  final List<MapTag> tags;
  final double itemHeight;
  final EdgeInsets padding;

  const AnimatedTagList({
    super.key,
    required this.tags,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<AnimatedTagList> createState() => _AnimatedTagListState();
}

class _AnimatedTagListState extends State<AnimatedTagList> {
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      itemBuilder: (context, index, animation) {
        final tag = widget.tags[index];
        return _buildAnimatedTagItem(tag, animation);
      },
      initialItemCount: widget.tags.length,
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
    );
  }

  Widget _buildAnimatedTagItem(MapTag tag, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          width: 140,
          height: widget.itemHeight,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: tag.type.color.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tag.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ID: ${tag.id}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: tag.type.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tag.isActive ? 'Active' : 'Offline',
                    style: TextStyle(
                      color: tag.isActive ? tag.type.color : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
