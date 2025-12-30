import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/invitation/domain/entities/group_lobby.dart';
import 'package:yad_app/features/invitation/presentation/bloc/group_lobby_bloc.dart';

class GroupLobbyWidget extends StatelessWidget {
  final GroupLobby lobby;
  final String currentUserId;

  const GroupLobbyWidget({
    super.key,
    required this.lobby,
    required this.currentUserId,
  });


  String _getInitials(String userId) {
    if (userId.isEmpty) return '?';
    if (userId.length < 2) return userId.toUpperCase();
    return userId.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lobby header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lobby.hasRequiredParticipants ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    lobby.hasRequiredParticipants 
                        ? Icons.check_circle 
                        : Icons.group_add,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lobby.hasRequiredParticipants 
                            ? 'Minyan Group Ready!' 
                            : 'Minyan Group Forming',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: lobby.hasRequiredParticipants 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lobby.participantIds.length}/10 participants',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress indicator
            LinearProgressIndicator(
              value: lobby.participantIds.length / 10.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                lobby.hasRequiredParticipants ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lobby.participantIds.length} of 10',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${lobby.participantsNeeded} more needed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: lobby.hasRequiredParticipants ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Participants list
            Text(
              'Participants (${lobby.participantIds.length}):',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: lobby.participantIds.length,
                itemBuilder: (context, index) {
                  final isCreator = lobby.participantIds[index] == lobby.creatorId;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCreator ? Colors.blue : Colors.grey[300],
                            border: Border.all(
                              color: currentUserId == lobby.participantIds[index] 
                                  ? Colors.orange 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(lobby.participantIds[index]),
                              style: TextStyle(
                                color: isCreator ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCreator ? 'Creator' : 'Participant',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            if (lobby.hasRequiredParticipants)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to minyan creation page
                        print('Navigating to minyan creation for lobby: ${lobby.lobbyId}');
                      },
                      icon: const Icon(Icons.group_work),
                      label: const Text('Create Minyan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to communication page
                        print('Opening communication channel for lobby: ${lobby.lobbyId}');
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Waiting for ${lobby.participantsNeeded} more participants to reach minyan threshold...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}