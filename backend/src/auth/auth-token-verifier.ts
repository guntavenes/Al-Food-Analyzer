export type AuthenticatedUser = {
  userId: string;
  isAnonymous: boolean;
};

export interface AuthTokenVerifier {
  verify(token: string): Promise<AuthenticatedUser>;
}
