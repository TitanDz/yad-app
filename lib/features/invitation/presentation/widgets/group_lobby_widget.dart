import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yad_app/features/invitation/domain/entities/group_lobby.dart';
import 'package:yad_app/features/invitation/presentation/bloc/group_lobby_bloc.dart';

class GroupLobbyWidget extends StatefulWidget {
  final GroupLobby lobby;
  final String currentUserId;

  const GroupLobbyWidget({
    super.key,
    required this.lobby,
    required this.currentUserId,
  });

  @override
  State<GroupLobbyWidget> createState() => _GroupLobbyWidgetState();
}

class _GroupLobbyWidgetState extends State<GroupLobbyWidget> {
  String? _selectedLocationId;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  
  final List<Map<String, dynamic>> _locationSuggestions = [
    {
      'id': 'suggestion_1',
      'name': 'Central Synagogue',
      'address': '123 E 60th St, New York, NY 10022',
      'latitude': 40.7614,
      'longitude': -73.9710,
      'type': 'Synagogue',
      'distance': '0.8 miles',
      'rating': 4.7,
    },
    {
      'id': 'suggestion_2',
      'name': 'Congregation Beit Simchat Torah',
      'address': '349 W 19th St, New York, NY 10011',
      'latitude': 40.7522,
      'longitude': -74.0011,
      'type': 'Synagogue',
      'distance': '1.2 miles',
      'rating': 4.8,
    },
    {
      'id': 'suggestion_3',
      'name': 'The Jewish Center',
      'address': '1767 Broadway, New York, NY 10019',
      'latitude': 40.7682,
      'longitude': -73.9822,
      'type': 'Synagogue',
      'distance': '1.5 miles',
      'rating': 4.6,
    },
    {
      'id': 'suggestion_4',
      'name': 'Park Avenue Synagogue',
      'address': '170 E 87th St, New York, NY 10128',
      'latitude': 40.7823,
      'longitude': -73.9552,
      'type': 'Synagogue',
      'distance': '2.1 miles',
      'rating': 4.5,
    },
    {
      'id': 'suggestion_5',
      'name': 'Temple Emanu-El',
      'address': '1 E 65th St, New York, NY 10065',
      'latitude': 40.7737,
      'longitude': -73.9808,
      'type': 'Synagogue',
      'distance': '1.8 miles',
      'rating': 4.9,
    },
  ];

  void _updateMapMarkers() {
    _markers.clear();
    for (int i = 0; i < _locationSuggestions.length; i++) {
      final suggestion = _locationSuggestions[i];
      final isSelected = _selectedLocationId == suggestion['id'];
      final marker = Marker(
        markerId: MarkerId('suggestion_${i + 1}'),
        position: LatLng(suggestion['latitude'] as double, suggestion['longitude'] as double),
        infoWindow: InfoWindow(
          title: suggestion['name'] as String,
          snippet: suggestion['address'] as String,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueGreen,
        ),
      );
      _markers.add(marker);
    }
    setState(() {});
  }

  String _getInitials(String userId) {
    if (userId.isEmpty) return '?';
    if (userId.length < 2) return userId.toUpperCase();
    return userId.substring(0, 2).toUpperCase();
  }

  String _getUserName(String userId) {
    // Search through acceptances to find the user's name
    for (final acceptance in widget.lobby.acceptances) {
      if (acceptance.recipientId == userId) {
        return acceptance.recipientName;
      }
    }
    // If not found in acceptances, return a truncated version of the user ID
    return userId.length > 12 ? '${userId.substring(0, 9)}...' : userId;
  }

  @override
  void initState() {
    super.initState();
    // Auto-load location suggestions when lobby is opened
    _updateMapMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: Lobby Title
              Text(
                'Minyan Group Lobby',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All participants can interact and coordinate here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              
              // SECTION 1: Location Suggestions (PRIMARY - AT TOP OF LOBBY)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with group icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Choose Meeting Location',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All ${widget.lobby.participantIds.length} participants can view and discuss these suggestions together:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Location suggestions list
                  ...List.generate(
                    _locationSuggestions.length,
                    (index) {
                      final location = _locationSuggestions[index];
                      final isSelected = _selectedLocationId == location['id'];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on,
                            color: isSelected ? Colors.blue : Colors.green,
                            size: 22,
                          ),
                          title: Text(
                            location['name'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                location['address'] as String,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 13, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${location['rating']} • ${location['distance']}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle, color: Colors.blue, size: 22)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedLocationId = location['id'] as String;
                              _updateMapMarkers();
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Selection status & Create Minyan button
                  if (_selectedLocationId != null)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.group, color: Colors.blue, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${widget.lobby.participantIds.length} group members can see this location choice',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            debugPrint('Creating minyan with selected location: $_selectedLocationId');
                            // Navigate to minyan creation with selected location
                          },
                          icon: const Icon(Icons.group_work),
                          label: const Text('Create Minyan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 20),
              
              // SECTION 2: Participants Information
              Text(
                'Group Members',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              // Status overview
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group Complete',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${widget.lobby.participantIds.length} of 10 members',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Participants avatar carousel
              Text(
                'Members (${widget.lobby.participantIds.length})',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.lobby.participantIds.length,
                  itemBuilder: (context, index) {
                    final isCreator = widget.lobby.participantIds[index] == widget.lobby.creatorId;
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCreator ? Colors.blue : Colors.grey[300],
                              border: Border.all(
                                color: widget.currentUserId == widget.lobby.participantIds[index] 
                                    ? Colors.orange 
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(widget.lobby.participantIds[index]),
                                style: TextStyle(
                                  color: isCreator ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 62,
                            child: Text(
                              _getUserName(widget.lobby.participantIds[index]),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Participant names detailed list
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Members List',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(
                      widget.lobby.participantIds.length,
                      (index) {
                        final participantId = widget.lobby.participantIds[index];
                        final participantName = _getUserName(participantId);
                        final isCreator = participantId == widget.lobby.creatorId;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Icon(
                                isCreator ? Icons.stars : Icons.person,
                                size: 16,
                                color: isCreator 
                                    ? Colors.blue 
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  participantName,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: isCreator ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.currentUserId == participantId)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'You',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
