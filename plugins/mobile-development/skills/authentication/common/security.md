# Mobile Security Best Practices

Essential security guidelines for mobile authentication.

## Do's

- **Use SecureStore for tokens** - Never use AsyncStorage for auth tokens
- **Implement token refresh** - Don't let users re-login frequently
- **Enable biometrics** - Better UX than passwords
- **Support Apple Sign In** - Required for iOS apps with social login
- **Handle auth state globally** - Use context or state management
- **Use HTTPS** - Always use secure connections
- **Implement session timeout** - Auto-logout after inactivity

## Don'ts

- **Don't store passwords** - Only store tokens
- **Don't skip validation** - Validate on both client and server
- **Don't ignore errors** - Show meaningful error messages
- **Don't forget logout cleanup** - Clear all secure storage
- **Don't log sensitive data** - Tokens, passwords should never be logged
- **Don't use AsyncStorage for tokens** - It's not encrypted

## Storage Comparison

| Data Type | Storage | Notes |
|-----------|---------|-------|
| Auth tokens | SecureStore | Encrypted, Keychain/Keystore |
| User preferences | MMKV | Fast, unencrypted |
| Sensitive user data | SecureStore | With additional encryption |
| Session flags | MMKV | Fast access needed |

## Security Checklist

- [ ] Tokens stored in SecureStore
- [ ] Token refresh implemented
- [ ] Session timeout configured
- [ ] Biometric option available
- [ ] Apple Sign In supported (iOS)
- [ ] Logout clears all secure storage
- [ ] No sensitive data in logs
- [ ] HTTPS only
- [ ] Rate limiting on auth endpoints
- [ ] Input validation on all forms
