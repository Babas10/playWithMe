// Shared TypeScript interfaces for invite system Cloud Functions
// Epic 17 — Story 17.3

// ============================================================================
// createGroupInvite
// ============================================================================

export interface CreateGroupInviteRequest {
  groupId: string;
  expiresInHours?: number;
  usageLimit?: number;
}

export interface CreateGroupInviteResponse {
  success: boolean;
  inviteId: string;
  token: string;
  deepLinkUrl: string;
  expiresAt: string | null;
}

// ============================================================================
// validateInviteToken
// ============================================================================

export interface ValidateInviteTokenRequest {
  token: string;
}

export interface ValidateInviteTokenResponse {
  valid: boolean;
  groupId: string;
  groupName: string;
  groupDescription?: string;
  groupPhotoUrl?: string;
  groupMemberCount: number;
  inviterName: string;
  inviterPhotoUrl?: string;
  expiresAt: string | null;
  remainingUses: number | null;
}

// ============================================================================
// joinGroupViaInvite
// ============================================================================

export interface JoinGroupViaInviteRequest {
  token: string;
}

export interface JoinGroupViaInviteResponse {
  success: boolean;
  groupId: string;
  groupName: string;
  alreadyMember: boolean;
}

// ============================================================================
// revokeGroupInvite
// ============================================================================

export interface RevokeGroupInviteRequest {
  groupId: string;
  inviteId: string;
}

export interface RevokeGroupInviteResponse {
  success: boolean;
}

// ============================================================================
// Shared internal types
// ============================================================================

export interface TokenLookupData {
  groupId: string;
  inviteId: string;
  createdAt: FirebaseFirestore.Timestamp;
  active: boolean;
}

export interface InviteData {
  token: string;
  createdBy: string;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp | null;
  revoked: boolean;
  usageLimit: number | null;
  usageCount: number;
  groupId: string;
  inviteType: string;
}

export interface GroupData {
  name: string;
  description?: string;
  photoUrl?: string;
  createdBy: string;
  memberIds: string[];
  adminIds: string[];
  maxMembers: number;
  allowMembersToInviteOthers: boolean;
  lastActivity?: FirebaseFirestore.Timestamp;
}
