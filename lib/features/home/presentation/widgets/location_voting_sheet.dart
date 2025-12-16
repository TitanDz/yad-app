import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/location_voting_bloc.dart';
import 'package:yad_app/features/home/domain/entities/voting_session.dart';
import 'location_suggestion_card.dart';

/// Bottom sheet widget for voting on minyan location
class LocationVotingSheet extends StatefulWidget {
  final VoidCallback? onLocationFinalized;
  final String currentUserId;

  const LocationVotingSheet({
    super.key,
    this.onLocationFinalized,
    required this.currentUserId,
  });

  @override
  State<LocationVotingSheet> createState() => _LocationVotingSheetState();
}

class _LocationVotingSheetState extends State<LocationVotingSheet> {
  late String _selectedLocationId;
  bool _isAddingLocation = false;
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();

  @override
  void dispose() {
    _locationNameController.dispose();
    _locationAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationVotingBloc, LocationVotingState>(
      listener: (context, state) {
        if (state is ConsensusReached) {
          // Show confirmation and close
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✓ Location finalized: ${state.winningLocation.name}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            widget.onLocationFinalized?.call();
            Navigator.of(context).pop(state.winningLocation);
          });
        }
      },
      child: BlocBuilder<LocationVotingBloc, LocationVotingState>(
        builder: (context, state) {
          if (state is! VotingSessionActive && state is! SuggestionAdded && state is! VoteCasted) {
            if (state is ConsensusReached) {
              return _buildConsensusReached(context, state);
            } else if (state is VotingExpired) {
              return _buildVotingExpired(context, state);
            }
            return const SizedBox.shrink();
          }

          final session = state is VotingSessionActive
              ? state.session
              : state is SuggestionAdded
                  ? state.session
                  : state is VoteCasted
                      ? state.session
                      : null;

          if (session == null) {
            return const SizedBox.shrink();
          }

          return _buildVotingSheet(context, session, state);
        },
      ),
    );
  }

  Widget _buildVotingSheet(BuildContext context, VotingSession session, LocationVotingState state) {
    final minutesRemaining = state is VotingSessionActive ? state.minutesRemaining : session.getMinutesUntilExpiry();
    final sortedSuggestions = List.from(session.suggestions)
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Meeting Location',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${session.participantIds.length} participants • ${session.suggestions.length} suggestions',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: minutesRemaining > 5 
                              ? Colors.orange.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$minutesRemaining min left',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: minutesRemaining > 5 ? Colors.orange : Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Voting requirement info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Need ${session.votesNeeded} vote${session.votesNeeded == 1 ? '' : 's'} for consensus',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Suggestions list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sortedSuggestions.length + (_isAddingLocation ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index == sortedSuggestions.length) {
                    // Add location button
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        onPressed: _toggleAddLocation,
                        icon: const Icon(Icons.add),
                        label: const Text('Suggest a Location'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  }

                  final suggestion = sortedSuggestions[index];
                  final userVotes = suggestion.voterIds.toList();
                  final hasVoted = userVotes.contains(widget.currentUserId);

                  return LocationSuggestionCard(
                    suggestion: suggestion,
                    hasVoted: hasVoted,
                    onVote: () {
                      context.read<LocationVotingBloc>().add(
                            VoteForLocationEvent(
                              suggestionId: suggestion.id,
                              userId: widget.currentUserId,
                            ),
                          );
                    },
                    totalParticipants: session.participantIds.length,
                    votesNeeded: session.votesNeeded,
                  );
                },
              ),
            ),

            // Add location form (if visible)
            if (_isAddingLocation) _buildAddLocationForm(context),

            // Finalize button
            if (session.hasConsensus() || minutesRemaining <= 1)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<LocationVotingBloc>().add(
                            const FinalizeVotingEvent(),
                          );
                    },
                    child: Text(
                      minutesRemaining <= 1 ? 'Time\'s up - Finalize' : 'Finalize Location',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddLocationForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggest a Location',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationNameController,
            decoration: InputDecoration(
              hintText: 'Location name',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationAddressController,
            decoration: InputDecoration(
              hintText: 'Address (optional)',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleAddLocation,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_locationNameController.text.isNotEmpty) {
                      // In real app, would get actual coordinates
                      context.read<LocationVotingBloc>().add(
                            AddLocationSuggestionEvent(
                              name: _locationNameController.text,
                              address: _locationAddressController.text.isEmpty
                                  ? null
                                  : _locationAddressController.text,
                              latitude: 40.7128,
                              longitude: -74.0060,
                              userId: widget.currentUserId,
                            ),
                          );
                      _locationNameController.clear();
                      _locationAddressController.clear();
                      _toggleAddLocation();
                    }
                  },
                  child: const Text('Suggest'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsensusReached(BuildContext context, ConsensusReached state) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'Location Finalized!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            state.winningLocation.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            state.winningLocation.address ?? 'Location confirmed',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(state.winningLocation);
                widget.onLocationFinalized?.call();
              },
              child: const Text(
                'Close & Share Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingExpired(BuildContext context, VotingExpired state) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Voting Expired',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 8),
          if (state.defaultLocation != null)
            Column(
              children: [
                Text(
                  'Default location selected:',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.defaultLocation!.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(state.defaultLocation);
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAddLocation() {
    setState(() {
      _isAddingLocation = !_isAddingLocation;
    });
  }
}
