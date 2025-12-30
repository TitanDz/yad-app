import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:yad_app/features/invitation/presentation/widgets/invitation_card.dart';
import 'package:yad_app/features/invitation/presentation/widgets/acceptance_notification_card.dart';
import 'package:yad_app/features/invitation/domain/entities/invitation.dart';

class InvitationsPage extends StatefulWidget {
  final String currentUserId;

  const InvitationsPage({
    super.key,
    required this.currentUserId,
  });

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage>
    with TickerProviderStateMixin {
  late InvitationBloc _invitationBloc;
  String? _loadingInvitationId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _invitationBloc = context.read<InvitationBloc>();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load pending invitations when page opens
    _invitationBloc.add(LoadPendingInvitationsEvent(widget.currentUserId));
    
    // Listen for tab changes to load acceptance notifications when "Accepted" tab is tapped
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Load acceptance notifications when user switches to "Accepted" tab
    if (_tabController.index == 1) {
      debugPrint('📬 [InvitationsPage] Switching to Accepted tab - loading acceptance notifications');
      _invitationBloc.add(LoadAcceptanceNotificationsEvent(widget.currentUserId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.mail_outline),
              text: 'Received',
            ),
            Tab(
              icon: Icon(Icons.check_circle_outline),
              text: 'Accepted',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Received invitations tab
          _buildReceivedTab(),
          // Accepted invitations tab
          _buildAcceptedTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _invitationBloc.add(
              LoadPendingInvitationsEvent(widget.currentUserId),
            );
          } else {
            _invitationBloc.add(
              LoadAcceptanceNotificationsEvent(widget.currentUserId),
            );
          }
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  Widget _buildReceivedTab() {
    return BlocBuilder<InvitationBloc, InvitationState>(
        builder: (context, state) {
          if (state is InvitationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PendingInvitationsLoaded) {
            if (state.invitations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No pending invitations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invitations will appear here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.invitations.length,
              itemBuilder: (context, index) {
                final invitation = state.invitations[index];
                final isLoading = _loadingInvitationId == invitation.invitationId;

                return InvitationCard(
                  invitation: invitation,
                  isLoading: isLoading,
                  onAccept: () => _handleResponse(
                    invitation.invitationId,
                    InvitationStatus.accepted,
                  ),
                  onDecline: () => _handleResponse(
                    invitation.invitationId,
                    InvitationStatus.declined,
                  ),
                );
              },
            );
          }

          if (state is InvitationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error loading invitations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _invitationBloc.add(
                        LoadPendingInvitationsEvent(widget.currentUserId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
  }

  Widget _buildAcceptedTab() {
    return BlocBuilder<InvitationBloc, InvitationState>(
      builder: (context, state) {
          if (state is InvitationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AcceptanceNotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No acceptances yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When people accept your invitations,\nthey will appear here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final acceptance = state.notifications[index];
                return AcceptanceNotificationCard(
                  acceptance: acceptance,
                );
              },
            );
          }

          if (state is InvitationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error loading acceptances',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _invitationBloc.add(
                        LoadAcceptanceNotificationsEvent(widget.currentUserId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
  }

  void _handleResponse(String invitationId, InvitationStatus response) {
    setState(() {
      _loadingInvitationId = invitationId;
    });

    _invitationBloc.add(
      RespondToInvitationEvent(invitationId, response),
    );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invitation ${response.toString().split('.').last.toUpperCase()}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _loadingInvitationId = null;
    });
  }
}
