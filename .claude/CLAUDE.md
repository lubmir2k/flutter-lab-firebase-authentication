# Project-Specific Instructions

## Firebase Firestore Indexes

**CRITICAL: When implementing Firestore queries, ALWAYS analyze the complete query structure UPFRONT and provide ALL required indexes immediately.**

### For Compound OR Queries

When you see a query like:
```dart
.where(Filter.or(
  Filter.and(field1 = A, field2 = B),
  Filter.and(field1 = C, field2 = D)
))
.orderBy(sortField)
```

**You MUST create indexes for EACH branch of the OR:**
- Index for: field1 + field2 + sortField
- Index for: field1 + sortField
- Index for: field2 + sortField

**NEVER suggest creating indexes incrementally or one-at-a-time.**

### Sort Direction

- `descending: false` = ASCENDING
- `descending: true` = DESCENDING

Match the index sort direction to the query's orderBy direction.

### Process

1. Read the complete query code
2. Identify ALL required indexes
3. Provide the full list upfront with exact field names and sort directions
4. Explain why each index is needed
5. Note that indexes take 5-10 minutes to build

**DO NOT:**
- Suggest partial indexes and wait for errors
- Make the user create indexes through trial-and-error
- Give incomplete information initially
