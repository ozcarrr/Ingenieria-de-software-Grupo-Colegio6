# Rate Limiter Recommendations

## Implemented

| Endpoint | Method | Auth | Limit | Key | Reason |
|----------|--------|------|-------|-----|--------|
| `/api/auth/login` | POST | No | 5 per 15 min | IP address | Prevent brute-force credential attacks |
| `/api/curriculum/me` | GET | Yes | 5 per 15 min + 20 s minimum gap between requests | User ID | PDF generation is CPU-intensive; prevents abuse of QuestPDF rendering |

---

## Recommended

### High Priority

| Endpoint | Method | Auth | Proposed Limit | Key | Reason |
|----------|--------|------|----------------|-----|--------|
| `/api/auth/register` | POST | No | 3 per hour | IP address | Prevents automated bot account creation; registration is a one-time action so legitimate users are unaffected |
| `/api/reports/me` | GET | Yes | 5 per 15 min | User ID | Generates a monthly engagement PDF — same rendering cost as the CV endpoint |
| `/api/storage/upload` | POST | Yes | 20 per hour | User ID | Each upload can be up to 50 MB; without a limit, a single user can exhaust Azure Blob Storage budget in minutes |

### Medium Priority

| Endpoint | Method | Auth | Proposed Limit | Key | Reason |
|----------|--------|------|----------------|-----|--------|
| `/api/posts` | POST | Yes | 10 per 10 min | User ID | Prevents feed spam; 10 posts per 10 minutes is well above any legitimate use case |
| `/api/posts/{postId}/comments` | POST | Yes | 20 per 10 min | User ID | Prevents comment flooding on a single post |
| `/api/jobs/{jobId}/apply` | POST | Yes | 10 per hour | User ID | Prevents spam applications to job postings; job applications are deliberate actions |

### Low Priority

| Endpoint | Method | Auth | Proposed Limit | Key | Reason |
|----------|--------|------|----------------|-----|--------|
| `/api/chat/messages/{receiverId}` | POST | Yes | 30 per minute | User ID | Prevents message harassment/spam; 30 per minute is still comfortable for fast conversations |
| `/api/network/{userId}/follow` | POST | Yes | 50 per hour | User ID | Prevents automated mass-follow behavior |
