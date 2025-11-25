import 'package:flutter/material.dart';
import 'package:yad_app/config/theme.dart';

class SearchLocationBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final TextEditingController? controller;
  final Function(Map<String, dynamic>)? onLocationSelected;
  final List<Map<String, dynamic>> searchResults;
  final bool isLoading;

  const SearchLocationBar({
    super.key,
    required this.onSearch,
    required this.onClear,
    this.controller,
    this.onLocationSelected,
    this.searchResults = const [],
    this.isLoading = false,
  });

  @override
  State<SearchLocationBar> createState() => _SearchLocationBarState();
}

class _SearchLocationBarState extends State<SearchLocationBar> {
  late TextEditingController _controller;
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {
        _hasSearchText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAutocomplete(String query) async {
    if (query.isEmpty) {
      widget.onSearch('');
      return;
    }
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? AppTheme.neutral800 : Colors.white;
    final iconColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral400;
    final hintColor = isDarkMode ? AppTheme.neutral500 : AppTheme.neutral400;
    
    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          _fetchAutocomplete(value);
        },
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: iconColor,
            size: 20,
          ),
          suffixIcon: _hasSearchText
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: iconColor,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _hasSearchText = false;
                    });
                    widget.onClear();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
