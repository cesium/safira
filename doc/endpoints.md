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
    - /store
      - GET /
      - GET /:id
      - POST /buy

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
    - /store
      - GET /
      - GET /:id
      - POST /buy

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
            "avatar": "/images/attendee-missing.png",
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
            "entries": 0,
            "id": "eae3333d-51a6-4142-b35d-0154e431ff60",
            "name": "user1",
            "nickname": "user1",
            "token_balance": 10,
            "volunteer": false
        },
        {
            "avatar": "/images/attendee-missing.png",
            "badge_count": 0,
            "badges": [],
            "entries": 0,
            "id": "87656cdb-5615-4118-b981-a76f5ee4352a",
            "name": "user3",
            "nickname": "user3",
            "token_balance": 10,
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
        "avatar": "/images/attendee-missing.png",
        "badge_count": 1,
        "badges": [{
                    "avatar": "https://teste.amazonaws.com/uploads/badge/avatars/179/original.png?v=63731919919",
                    "begin": "2019-02-05T00:00:00Z",
                    "description": "Estiveste presente na talk do Celso Martinho",
                    "end": "2019-02-06T00:00:00Z",
                    "id": 179,
                    "name": "Talk Celso Martinho",
                    "type": 3
                }],
        "entries": 0,
        "id": "eae3333d-51a6-4142-b35d-0154e431ff60",
        "name": "user1",
        "nickname": "user1",
        "prizes": [{
                    "avatar": "/uploads/prize/avatars/26/original.png?v=63780572129",
                    "id": 26,
                    "max_amount_per_attendee": 1,
                    "name": "Raspberry Pi 4 2gb + carregador",
                    "stock": 1
        }],
        "redeemables": [
            {
                "id": 1,
                "image": "/images/redeemable-missing.png",
                "name": "T-shirt",
                "price": 10,
                "quantity": 1
            }
        ],
        "token_balance": 10,
        "volunteer": false
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
```
# Store
## GET / (Index)
Fetches all redeemables in store.

### Valid:
```json

{
    "data": [
        {
            "id": 1,
            "image": "/images/redeemable-missing.png",
            "name": "T-shirt",
            "price": 10
        },
        {
            "id": 2,
            "image": "/images/redeemable-missing.png",
            "name": "Caneta",
            "price": 5
        }
    ]
}
```
## GET /:id (Show)
Fetches a single item.

### Valid:
```json
{
    "data": {
        "description": "Caneta Merch SEI",
        "id": 2,
        "image": "/images/redeemable-missing.png",
        "max_per_user": 10,
        "name": "Caneta",
        "price": 5,
        "stock": 7
    }
}
```

### Errors:
- When an item does not exist in store.
```json
{
    "errors": {
        "detail": "Endpoint Not Found"
    }
}
```

## POST /buy
Buy a redeemable.
```json
{
    "redeemable": {
        "redeemable_id": 3
    }
}
```

### Valid:
```json
{
    "Redeemable": "Caneta bought successfully!"
}
```
### Errors:
- When the participant has already reached the maximum quantity allowed per user.
```json
{
    "errors": {
        "quantity": [
            "Quantity is greater than the maximum amount permitted per attendee"
        ]
    }
}
```
- Attendee *token balance* is insufficient to buy the redeemable.
```json
{
    "errors": {
        "token_balance": [
            "must be greater than or equal to 0"
        ]
    }
}
```
- The stock of the selected redeemable reached 0.
```json
{
    "errors": {
        "stock": [
            "must be greater than or equal to 0"
        ]
    }
}
```
- There is no *redeemable_id* parameter or it is written differently.
```json
{
    "Redeemable": "No 'redeemable_id' param"
}
```
- Not an attendee
```json
{
    "error": "Only attendees can buy products!"
}
```
- There is no redeemable with that *id*
```json
{
    "Redeemable": "There is no such redeemable"
}
```