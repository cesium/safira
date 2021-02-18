# Endpoints

- /api
  - /auth
    - /sign_up
      - POST /
    - /sign_in
      - POST /
  - /v1
    - /user
      - GET /
    - /attendee
      - GET /
    - /badges
      - GET /
      - GET /:id
    - /attendees
      - GET /
      - GET /:id
      - POST /:id
      - DELETE /:id
    - /company
      - GET /
    - /companies
      - GET /
      - GET /:id
    - /referrals
      - GET /:id
    - /redeems
      - POST /
    - /leaderboard
      - GET /
    - /association
      - GET /:discord_id
      - POST /
    - /spotlight
      - POST

## Attendee

- /api
  - /auth
    - /sign_up
     - POST /
    - /sign_in
     - POST /
  - /v1
    - /user
      - GET /
    - /attendee
      - GET /
    - /badges
      - GET /
      - GET /:id
    - /attendees
      - GET /
      - GET /:id
      - POST /:id
      - DELETE /:id
    - /companies
      - GET /
      - GET /:id
    - /referrals
      - GET /:id

## Company

- /api
  - /auth
    - /sign_in
     - POST /
  - /v1
    - /user
      - GET /
    - /badges
      - GET /
      - GET /:id
    - /attendees
      - GET /
      - GET /:id
      - POST /:id
      - DELETE /:id
    - /company
      - GET /
    - /companies
      - GET /
      - GET /:id
    - /spotlight
      - POST

## Manager

- /api
  - /auth
    - /user
      - GET /
    - /sign_up
      - POST /
    - /sign_in
      - POST /
  - /v1
    - /redeems
      - POST /
    - /association
      - GET /:discord_id
      - POST /  


# sign_up

## POST /
```json
{
    "user": {
        "email": "foo@bar.com",
        "password": "somePassword",
        "password_confirmation": "somePassword",
        "attendee": {
            "id": "adaa8aab4e-7549-494b-91f0-52e9c9a8cf5d",
            "nickname": "foobar"
        }
    }
}
```

### Valid:
```json
{
    "discord_association_code": "733405df-0b7b-4dc3-9666-3038fde44698",
    "jwt": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzYWZpcmEiLCJl..."

}
```

### Errors:
- Invalid email, email already taken, password doesn't match, username already taken

```json
{
    "error": "Invalid register data"
}
```
- UUID taken

```json
{
    "error": "Already registered"
}
```
- UUID Incorrect

```json
{
    "errors": {
        "detail": "Bad Request"
    }
}
```

# sign_in
## POST /

```json
{
    "email": "foo@bar.com",
    "password": "somePassword"
}
```

### Valid:

```json
{
    "jwt": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzYWZpcmEiLCJle..."
}
```

### Errors:

- Invalid username or password
```json
{
    "error": "Login error"
}
```


# Authenticated Endpoints
When you are autheticated you get a jwt token.

This token is used as a bearer token to service
any calls to the api that need to be authenticated.

### Errors:
```json
{
    "error": "unauthenticated"
}
```

```json
{
    "error": "invalid_token"
}
```

# badges
## GET / (Index)
Fetches the badges of the logged in attendee.

### Valid:
```json

{
    "data": [
        {
            "name": 1,
            "end": "2018-07-31T15:59:51.746577Z",
            "description": "coisa",
            "begin": "2018-07-31T15:59:51.742630Z",
            "avatar": "/images/default/badge-missing.png"
        }
    ]
}
```
## GET /:id (Show)
Fetches a single badge.

### Valid:
```json
{
    "data": {
        "name": 1,
        "end": "2018-07-31T15:59:51.746577Z",
        "description": "coisa",
        "begin": "2018-07-31T15:59:51.742630Z",
        "avatar": "/images/default/badge-missing.png"
    }
}
```

### Errors:
```json
{
    "errors": {
        "detail": "Endpoint Not Found"
    }
}
```

# attendee
## GET / (Show)
Fetches the nick, uuid, email and avatar of the logged in attendee.

### Valid:
```json
{
    "nick": "qwrqasd",
    "id": "43ffc4f5-3b12-4243-a157-e4e9e90d35dc",
    "email": "fooo@bar.com",
    "name": "Name LastName",
    "avatar": "/images/default/attendee-missing.png"
}
```


# attendees
## GET / (Index)
Lists all attendess.

### Valid:
```json
{
    "data": [
        {
            "avatar": "https://safira20.herokuapp.com//images/attendee-missing.png",
            "badge_count": 1,
            "badges": [
                {
                    "avatar": "https://teste.amazonaws.com/uploads/badge/avatars/179/original.png?v=63731919919",
                    "begin": "2019-02-05T00:00:00Z",
                    "description": "Estiveste presente na talk do Celso Martinho",
                    "end": "2019-02-06T00:00:00Z",
                    "id": 179,
                    "name": "Talk Celso Martinho",
                    "type": 3
                }
            ],
            "id": "6de51b47-4c35-4127-8c48-79b354061ae5",
            "name": "Name LastName",
            "nickname": "attendee1",
            "volunteer": false
        }
    ]
}
```

## GET /:id (Show)
Shows an attendee.

### Valid:
```json
{
    "data": {
        "nickname": "foo",
        "id": "43ffc4f5-3b12-4243-a157-e4e9e90d35dc",
        "avatar": "/images/default/attendee-missing.png"
    }
}
```
### Errors:
```json
{
    "errors": {
        "detail": "Bad Request"
    }
}
```
## PUT /:id (Update)
Changes an attendee.

### Request:

```json
{
    "attendee": {
        "nickname": "qwrqasd"
    }

}
```
### Valid:

```json
{
    "data": {
        "nickname": "qwrqasd",
        "id": "d832f350-fe30-4d98-a245-59d1aa186f36",
        "name": "Name LastName",
        "avatar": "/images/default/attendee-missing.png"
    }
}
```
### Errors:

```json
{
    "errors": {
        "detail": "Bad Request"
    }
}
```

## DELETE /:id (Delete)
Removes an attendee.

### Valid:
`204` (no content)
### Errors:
- Invalid uuid
```json
{
    "errors": {
        "detail": "Endpoint Not Found"
    }
}
```


# referrals
## GET /:id
### Valid:
```json
{
    "referral": "Referral redeemed successfully"
}
```
### Errors:

- Used referrals
```json
{
    "referral": "Referral not available"
}
```
- Attende allready had this badge
```json
{
    "errors": {
        "unique_attendee_badge": [
            "An attendee can't have the same badge twice"
        ]
    }
}
```
# company
## GET /
```json
{
    "badge_id": 10,
    "email": "company@company.org",
    "id": 1,
    "name": "Company",
    "sponsorship": "Tier"
}
```

# companies
## GET /
```json
{
    "data": [
        {
            "sponsorship": "ola",
            "name": "ola",
            "id": 1
        }
    ]
}
```
## GET /:id
### Valid:
```json
{
    "data": {
        "sponsorship": "ola",
        "name": "ola",
        "id": 1
    }
}
```

### Errors:
```json
{
    "errors": {
        "detail": "Endpoint Not Found"
    }
}
```

# redeems
## POST /
```json
{
    "redeem": {
        "attendee_id": "43ffc4f5-3b12-4243-a157-e4e9e90d35dc",
        "badge_id": "1"
    }
}
```

### Valid:
```json
{
    "redeem": "Badge redeem successfully"
}
```
### Errors:

- User allready had the badge
```json
{
    "errors": {
        "unique_attendee_badge": [
            "An attendee can't have the same badge twice"
        ]
    }
}
```
- Not an manager, no badge_id, not valid badge_id
```json
{
    "errors": {
        "detail": "Endpoint Not Found"
    }
}
```

# leaderboard
## GET /
```json
{
    "data": [
        {
            "avatar": "/uploads/attendee/avatars/ee4514b5-6b71-44ff-b26f-8afc0b8c7e51/original.png?v=63705800808",
            "badges": [
                {
                    "avatar": "/uploads/badge/avatars/5/original.png?v=63705802360",
                    "begin": "2019-02-12T00:00:00.000000Z",
                    "description": "hackerino",
                    "end": "2019-02-13T00:00:00.000000Z",
                    "name": 5
                }
            ],
            "id": "ee4514b5-6b71-44ff-b26f-8afc0b8c7e51",
            "nickname": "Nick"
        }
    ]
}
```

# spotlight
## POST 
No body

### Valid
```Json
{
  "spotlight": "Spotlight requested succesfully"
}
```

### Errors:

- A company is already in spotlight

```json
{
  "errors": {
    "active": [
      "Another spotlight is still active"
    ]
  }
}
```

- The company has no remaining spotlights

```json
{
  "errors": {
    "remaining_spotlights": [
      "must be greater than or equal to 0"
    ]
  }
}
```

# Association
## /:discord_id (Show)
Fetches the id of the attendee associated with the given discord id

### Valid: 
```JSON
{
  "id": "f90b60ce-219c-4edc-a92a-e6c63fec4a4d"
}
```

### Errors:

- Discord id is not associated:

```JSON 
{
  "error": "No attendee with that discord_id"
}
```

## POST /

```json
{
	"discord_association_code": "733405df-0b7b-4dc3-9666-3038fde44698",
	"discord_id": "abc"
}
```

### Valid: 
```JSON
{
  "association": "participante"/"empresa"/"orador"/"staff"
}
```

### Errors:

- Invalid association code:

```JSON 
{
  "error": "Unable to associate"
}
