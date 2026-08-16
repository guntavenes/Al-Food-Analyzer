declare global {
  namespace Express {
    interface Request {
      id: string;
      auth?: { userId: string; isAnonymous: boolean };
    }
  }
}

export {};
