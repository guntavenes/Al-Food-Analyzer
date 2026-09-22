import { AppError } from '../errors.js';

export interface AccountDeletionService {
  deleteAccount(userId: string): Promise<void>;
}

export class SupabaseAccountDeletionService implements AccountDeletionService {
  constructor(
    private readonly supabaseUrl: string,
    private readonly secretKey: string
  ) {}

  async deleteAccount(userId: string): Promise<void> {
    const baseUrl = this.supabaseUrl.replace(/\/$/, '');
    const headers = {
      apikey: this.secretKey,
      authorization: `Bearer ${this.secretKey}`,
      'content-type': 'application/json'
    };

    // Storage objects are not removed by Postgres foreign-key cascades.
    const listResponse = await fetch(`${baseUrl}/storage/v1/object/list/analysis-images`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ prefix: userId, limit: 1000, offset: 0 })
    });
    if (!listResponse.ok && listResponse.status !== 404) {
      throw new AppError('SERVICE_UNAVAILABLE', 'Account data could not be removed.', 503);
    }
    if (listResponse.ok) {
      const objects = await listResponse.json() as Array<{ name?: string }>;
      const prefixes = objects
        .map((object) => object.name ? `${userId}/${object.name}` : null)
        .filter((path): path is string => path != null);
      if (prefixes.length > 0) {
        const removeResponse = await fetch(`${baseUrl}/storage/v1/object/analysis-images`, {
          method: 'DELETE',
          headers,
          body: JSON.stringify({ prefixes })
        });
        if (!removeResponse.ok) {
          throw new AppError('SERVICE_UNAVAILABLE', 'Account photos could not be removed.', 503);
        }
      }
    }

    const deleteResponse = await fetch(`${baseUrl}/auth/v1/admin/users/${encodeURIComponent(userId)}`, {
      method: 'DELETE',
      headers
    });
    if (!deleteResponse.ok) {
      throw new AppError('SERVICE_UNAVAILABLE', 'The account could not be deleted.', 503);
    }
  }
}
