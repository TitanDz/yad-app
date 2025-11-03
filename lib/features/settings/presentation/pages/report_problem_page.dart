import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class ReportAProblemPage extends StatefulWidget {
  const ReportAProblemPage({super.key});

  @override
  State<ReportAProblemPage> createState() => _ReportAProblemPageState();
}

class _ReportAProblemPageState extends State<ReportAProblemPage> {
  late String _selectedIssue;
  late TextEditingController _descriptionController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _selectedIssue = 'Incorrect Information';
    _descriptionController = TextEditingController();
    _contactController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Report a Problem',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // What is the issue? Section
              Text(
                'What is the issue?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Issue Options
              _buildIssueOption(
                title: 'Incorrect Information',
                isSelected: _selectedIssue == 'Incorrect Information',
                context: context,
                onTap: () {
                  setState(() => _selectedIssue = 'Incorrect Information');
                },
              ),
              const SizedBox(height: 12),

              _buildIssueOption(
                title: 'Inappropriate Content',
                isSelected: _selectedIssue == 'Inappropriate Content',
                context: context,
                onTap: () {
                  setState(() => _selectedIssue = 'Inappropriate Content');
                },
              ),
              const SizedBox(height: 12),

              _buildIssueOption(
                title: 'Minyan Did Not Occur',
                isSelected: _selectedIssue == 'Minyan Did Not Occur',
                context: context,
                onTap: () {
                  setState(() => _selectedIssue = 'Minyan Did Not Occur');
                },
              ),
              const SizedBox(height: 12),

              _buildIssueOption(
                title: 'Other',
                isSelected: _selectedIssue == 'Other',
                context: context,
                onTap: () {
                  setState(() => _selectedIssue = 'Other');
                },
              ),
              const SizedBox(height: 24),

              // Description Text Field
              TextField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Describe the issue...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Information (Optional)
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  hintText: 'Contact Information (Optional)',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueOption({
    required String title,
    required bool isSelected,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primary : Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Theme.of(context).colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
