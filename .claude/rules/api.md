# API rules

<!-- Applies when touching any API/endpoint/handler. Trim if no API in this project. -->

- Rate limit public endpoints.
- Authorize every data access (check ownership, not just authentication).
- Validate + sanitize all input. Never trust the client.
- Verify webhook signatures before processing.
- Never log secrets, tokens, or PII.
- Minimal error detail to client; full detail server-side only.
