import 'package:flutter/material.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/core/services/centroid_calculation_service.dart';
import 'package:yad_app/features/home/domain/entities/location_suggestion.dart';

/// Card widget displaying a location suggestion with voting button
class LocationSuggestionCard extends StatelessWidget {
  final LocationSuggestion suggestion;
  final bool hasVoted;
  final VoidCallback onVote;
  final int totalParticipants;
  final int votesNeeded;

  const LocationSuggestionCard({
    super.key,
    required this.suggestion,
    required this.hasVoted,
    required this.onVote,
    required this.totalParticipants,
    required this.votesNeeded,
  });

  @override
  Widget build(BuildContext context) {
    final isLeading = suggestion.voteCount >= votesNeeded;
    final votePercentage = totalParticipants > 0 
        ? (suggestion.voteCount / totalParticipants * 100).toStringAsFixed(0)
        : '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasVoted 
              ? AppTheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: hasVoted ? 2 : 1,
        ),
        boxShadow: isLeading 
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ],
      ),
      child: Column(
        children: [
          // Header section with title and vote badge
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor(suggestion.type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getTypeIcon(suggestion.type),
                      color: _getTypeColor(suggestion.type),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Location info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (suggestion.address != null && suggestion.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            suggestion.address!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (suggestion.averageDistance != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Avg ${CentroidCalculationService.formatDistance(suggestion.averageDistance!)} away',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Vote count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLeading 
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${suggestion.voteCount} ${suggestion.voteCount == 1 ? 'vote' : 'votes'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vote progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalParticipants > 0 
                        ? suggestion.voteCount / totalParticipants
                        : 0,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLeading ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Vote percentage text
                Text(
                  '$votePercentage% ($suggestion.voteCount/$totalParticipants)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),

                // Consensus reached indicator
                if (isLeading)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Consensus reached!',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Vote button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasVoted ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.1),
                  foregroundColor: hasVoted 
                      ? Colors.white 
                      : AppTheme.primary,
                  elevation: hasVoted ? 2 : 0,
                  side: hasVoted ? null : BorderSide(
                    color: AppTheme.primary,
                    width: 1,
                  ),
                ),
                child: Text(
                  hasVoted ? '✓ Your vote' : 'Vote for this location',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'centroid':
        return Colors.purple;
      case 'synagogue':
        return Colors.orange;
      case 'user_suggested':
      default:
        return AppTheme.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'centroid':
        return Icons.location_on;
      case 'synagogue':
        return Icons.temple_buddhist;
      case 'user_suggested':
      default:
        return Icons.place;
    }
  }
}
