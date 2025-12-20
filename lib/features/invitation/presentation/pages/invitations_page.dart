import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:yad_app/features/invitation/presentation/widgets/invitation_card.dart';
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

class _InvitationsPageState extends State<InvitationsPage> {
  late InvitationBloc _invitationBloc;
  String? _loadingInvitationId;

  @override
  void initState() {
    super.initState();
    _invitationBloc = context.read<InvitationBloc>();
    // Load pending invitations when page opens
    _invitationBloc.add(LoadPendingInvitationsEvent(widget.currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        elevation: 0,
      ),
      body: BlocBuilder<InvitationBloc, InvitationState>(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _invitationBloc.add(
            LoadPendingInvitationsEvent(widget.currentUserId),
          );
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
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
