# Security Best Practices

Essential security guidelines for authentication implementations.

## Security Checklist

- [ ] Passwords hashed with bcrypt/argon2
- [ ] HTTPS enabled in production
- [ ] HTTP-only cookies for tokens
- [ ] CSRF protection implemented
- [ ] Rate limiting on auth endpoints
- [ ] Account lockout after failed attempts
- [ ] Email verification implemented
- [ ] Password reset flow secure
- [ ] Session timeout configured
- [ ] Two-factor authentication (optional)

## Do's

- **Use HTTPS in production** - Always encrypt authentication data
- **Hash passwords** - Use bcrypt or argon2, never plain text
- **Implement CSRF protection** - Prevent cross-site request forgery
- **Use HTTP-only cookies** - For storing tokens securely
- **Implement rate limiting** - Prevent brute-force attacks
- **Validate sessions server-side** - Don't trust client data
- **Implement token refresh** - For long-lived sessions

## Don'ts

- **Don't store passwords in plain text** - Always hash
- **Don't expose tokens in URLs** - Use HTTP-only cookies
- **Don't skip session validation** - Always check server-side
- **Don't use weak secrets** - Use strong, random JWT secrets (256-bit minimum)
- **Don't trust client-side auth checks** - Always validate server-side
- **Don't forget to expire sessions** - Implement proper timeout
- **Don't log sensitive data** - Passwords, tokens should never be logged

## Environment Variables

```bash
# .env.local

# NextAuth.js
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here

# OAuth Providers
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret

# Clerk (alternative)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxx
CLERK_SECRET_KEY=sk_test_xxx

# Custom JWT
JWT_SECRET=your-jwt-secret-256-bit-minimum

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
```
