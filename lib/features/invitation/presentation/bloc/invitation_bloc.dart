import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/invitation/domain/entities/invitation.dart';
import 'package:yad_app/features/invitation/data/datasources/invitation_datasource.dart';

// Events
abstract class InvitationEvent extends Equatable {
  const InvitationEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingInvitationsEvent extends InvitationEvent {
  final String userId;

  const LoadPendingInvitationsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RespondToInvitationEvent extends InvitationEvent {
  final String invitationId;
  final InvitationStatus response;

  const RespondToInvitationEvent(this.invitationId, this.response);

  @override
  List<Object?> get props => [invitationId, response];
}

class LoadSentInvitationsEvent extends InvitationEvent {
  final String userId;

  const LoadSentInvitationsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadAcceptanceNotificationsEvent extends InvitationEvent {
  final String userId;

  const LoadAcceptanceNotificationsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SendInvitationsEvent extends InvitationEvent {
  final String minyanId;
  final String senderId;
  final String senderName;
  final List<String> recipientIds;
  final String minyanDetails;
  final List<String> recipientNames; // NEW: Track names
  final List<double> distances; // NEW: Track distances

  const SendInvitationsEvent({
    required this.minyanId,
    required this.senderId,
    required this.senderName,
    required this.recipientIds,
    required this.minyanDetails,
    required this.recipientNames,
    required this.distances,
  });

  @override
  List<Object?> get props => [minyanId, senderId, senderName, recipientIds, minyanDetails, recipientNames, distances];
}

class RefreshInvitationsEvent extends InvitationEvent {
  final String userId;
  final bool isSent;

  const RefreshInvitationsEvent(
    this.userId, {
    this.isSent = false,
  });

  @override
  List<Object?> get props => [userId, isSent];
}

// States
abstract class InvitationState extends Equatable {
  const InvitationState();

  @override
  List<Object?> get props => [];
}

class InvitationInitial extends InvitationState {
  const InvitationInitial();
}

class InvitationLoading extends InvitationState {
  const InvitationLoading();
}

class PendingInvitationsLoaded extends InvitationState {
  final List<Invitation> invitations;
  final int unreadCount;

  const PendingInvitationsLoaded({
    required this.invitations,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [invitations, unreadCount];
}

class SentInvitationsLoaded extends InvitationState {
  final List<Invitation> invitations;
  final Map<String, int> responseCount; // Status -> count

  const SentInvitationsLoaded({
    required this.invitations,
    required this.responseCount,
  });

  @override
  List<Object?> get props => [invitations, responseCount];
}

class InvitationSent extends InvitationState {
  final int sentCount;

  const InvitationSent(this.sentCount);

  @override
  List<Object?> get props => [sentCount];
}

class InvitationResponseRecorded extends InvitationState {
  final String invitationId;
  final InvitationStatus response;

  const InvitationResponseRecorded(this.invitationId, this.response);

  @override
  List<Object?> get props => [invitationId, response];
}

class AcceptanceNotificationsLoaded extends InvitationState {
  final List<InvitationResponse> notifications;
  final int unreadCount;

  const AcceptanceNotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class InvitationError extends InvitationState {
  final String message;

  const InvitationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final InvitationDataSource dataSource;

  InvitationBloc({required this.dataSource}) : super(const InvitationInitial()) {
    on<LoadPendingInvitationsEvent>(_onLoadPendingInvitations);
    on<RespondToInvitationEvent>(_onRespondToInvitation);
    on<SendInvitationsEvent>(_onSendInvitations);
    on<LoadSentInvitationsEvent>(_onLoadSentInvitations);
    on<LoadAcceptanceNotificationsEvent>(_onLoadAcceptanceNotifications);
    on<RefreshInvitationsEvent>(_onRefreshInvitations);
  }

  Future<void> _onLoadPendingInvitations(
    LoadPendingInvitationsEvent event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      final invitations = await dataSource.getPendingInvitations(event.userId);

      emit(PendingInvitationsLoaded(
        invitations: invitations,
        unreadCount: invitations.length,
      ));

      debugPrint('✅ [InvitationBloc] Loaded ${invitations.length} pending invitations');
    } catch (e) {
      emit(InvitationError('Failed to load invitations: ${e.toString()}'));
      debugPrint('❌ [InvitationBloc] Error loading invitations: $e');
    }
  }

  Future<void> _onRespondToInvitation(
    RespondToInvitationEvent event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      // For mock implementation, we'll use placeholder values
      // In a real implementation, these would come from user context
      await dataSource.respondToInvitation(
        invitationId: event.invitationId,
        response: event.response,
        recipientName: 'Current User', // Would be actual user name in real implementation
        distance: 0.5, // Would be actual distance in real implementation
      );

      emit(InvitationResponseRecorded(event.invitationId, event.response));

      // Reload invitations after responding
      if (state is PendingInvitationsLoaded) {
        final currentState = state as PendingInvitationsLoaded;
        final updated = currentState.invitations
            .where((inv) => inv.invitationId != event.invitationId)
            .toList();

        emit(PendingInvitationsLoaded(
          invitations: updated,
          unreadCount: updated.length,
        ));

        debugPrint(
          '✅ [InvitationBloc] Responded to invitation: ${event.response.toString().split('.').last.toUpperCase()}',
        );
      }
    } catch (e) {
      emit(InvitationError('Failed to respond: ${e.toString()}'));
      debugPrint('❌ [InvitationBloc] Error responding to invitation: $e');
    }
  }

  Future<void> _onSendInvitations(
    SendInvitationsEvent event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      await dataSource.sendInvitations(
        minyanId: event.minyanId,
        senderId: event.senderId,
        senderName: event.senderName,
        recipientIds: event.recipientIds,
        minyanDetails: event.minyanDetails,
        recipientNames: event.recipientNames,
        distances: event.distances,
      );

      emit(InvitationSent(event.recipientIds.length));

      debugPrint('✅ [InvitationBloc] Sent invitations to ${event.recipientIds.length} users');
    } catch (e) {
      emit(InvitationError('Failed to send invitations: ${e.toString()}'));
      debugPrint('❌ [InvitationBloc] Error sending invitations: $e');
    }
  }

  Future<void> _onLoadSentInvitations(
    LoadSentInvitationsEvent event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      final invitations = await dataSource.getSentInvitations(event.userId);

      // Count responses by status
      final responseCount = <String, int>{};
      for (final inv in invitations) {
        final status = inv.status.toString().split('.').last;
        responseCount[status] = (responseCount[status] ?? 0) + 1;
      }

      emit(SentInvitationsLoaded(
        invitations: invitations,
        responseCount: responseCount,
      ));

      debugPrint('✅ [InvitationBloc] Loaded ${invitations.length} sent invitations');
    } catch (e) {
      emit(InvitationError('Failed to load sent invitations: ${e.toString()}'));
      debugPrint('❌ [InvitationBloc] Error loading sent invitations: $e');
    }
  }

  Future<void> _onLoadAcceptanceNotifications(
    LoadAcceptanceNotificationsEvent event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      final notifications = await dataSource.getAcceptanceNotifications(event.userId);

      emit(AcceptanceNotificationsLoaded(
        notifications: notifications,
        unreadCount: notifications.length,
      ));

      debugPrint('🔔 [InvitationBloc] Loaded ${notifications.length} acceptance notifications');
    } catch (e) {
      emit(InvitationError('Failed to load notifications: ${e.toString()}'));
      debugPrint('❌ [InvitationBloc] Error loading notifications: $e');
    }
  }

  Future<void> _onRefreshInvitations(
    RefreshInvitationsEvent event,
    Emitter<InvitationState> emit,
  ) async {
    if (event.isSent) {
      add(LoadSentInvitationsEvent(event.userId));
    } else {
      add(LoadPendingInvitationsEvent(event.userId));
    }
  }
}
