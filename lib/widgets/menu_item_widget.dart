import 'package:flutter/material.dart';
import 'expanded_content.dart';
import 'circles_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuItemWidget extends StatefulWidget {
  final Map<String, dynamic> menuItem;
  final Function(int, int) onRatingUpdate;
  final Future<int> Function(int, int) getUserRating;
  final bool isRecommended;

  const MenuItemWidget({
    Key? key,
    required this.menuItem,
    required this.onRatingUpdate,
    required this.getUserRating,
    this.isRecommended = false,
  }) : super(key: key);

  @override
  _MenuItemWidgetState createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  int _userRating = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchUserRating();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (!mounted) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _updateRating(int rating) async {
    final userId = await getUserId();
    if (!mounted) return;
    setState(() {
      _userRating = rating;
    });
    widget.onRatingUpdate(userId, rating);
  }

  Future<void> _fetchUserRating() async {
    try {
      final userId = await getUserId();
      final userRating = await widget.getUserRating(userId, widget.menuItem['id']);
      if (!mounted) return;
      setState(() {
        _userRating = userRating;
      });
    } catch (e) {
      print('Error fetching user rating: $e');
    }
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return int.tryParse(prefs.getString('userId') ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final borderWidth = widget.isRecommended ? 3.0 : 1.5;

    return Column(
      children: [
        InkWell(
          onTap: _toggleExpand,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFAB8532),
                width: borderWidth,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.menuItem['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                CirclesWidget(menuItem: widget.menuItem),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFAB8532),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                ExpandedContent(
                  menuItem: widget.menuItem,
                  userRating: _userRating,
                ),
                const SizedBox(height: 16),
                _buildStarRating(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => _updateRating(index + 1),
          child: Icon(
            index < _userRating ? Icons.star : Icons.star_border,
            color: Colors.yellow,
            size: 32,
          ),
        );
      }),
    );
  }
}
