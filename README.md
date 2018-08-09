# Safira

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
    - /companies
      - GET /
      - GET /:id
    - /referrals
      - GET /:id
    - /redeems
      - POST /

## Attendee

- /api
  - /auth
    - /sign_up
     - POST /
    - /sign_in
     - POST /
  - /v1
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

## Manager

- /api
  - /auth
    - /sign_up
     - POST /
    - /sign_in
     - POST /
  - /v1
    - /redeems
      - POST /


# sign_up

 ## request POST
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
      "jwt": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzYWZpcmEiLCJleHAiOjE1MzYxNDU4NzEsImlhdCI6MTUzMzcyNjY3MSwiaXNzIjoic2FmaXJhIiwianRpIjoiMGIxODFiZmUtZjYyYS00MTEwLWE2NmQtMDcxNTVjMGZjOWJlIiwibmJmIjoxNTMzNzI2NjcwLCJzdWIiOiIzOCIsInR5cCI6ImFjY2VzcyJ9.RUlR6XjHpgwJcRxjdBIRQsFvSXLG5SMSWAdR4g8CrM6hCFm3GuEDysTYtCTx1sQONJKNlAkls5O1wC-ocefgdg"
    }
  ```

 ### Errors:
   - Invalid email
      ```json

        {
          "errors": {
            "email": [
              "has invalid format"
            ]
          }
        }
      ```

   - Email allready taken

      ```json

        {
          "errors": {
            "email": [
              "has already been taken"
            ]
          }
        }
      ```

   - Password doesn't match

      ```json

        {
          "errors": {
            "password_confirmation": [
              "does not match confirmation"
            ]
          }
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
  ## request POST

  ```json

  {
    "email": "foo@bar.com",
   "password": "somePassword"
  }
  ```

  ### Valid:

```json
    {
      "jwt": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzYWZpcmEiLCJleHAiOjE1MzYxNTE4NjgsImlhdCI6MTUzMzczMjY2OCwiaXNzIjoic2FmaXJhIiwianRpIjoiMjI2MGJlYjQtMDAwZi00ZjdhLTk1YzUtZDM1OTU1NDE4Yjg3IiwibmJmIjoxNTMzNzMyNjY3LCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.jSPUcn0e3Qg3tEiTxzvYHWfFa5YgNO-XPPrEZCBTuIkr3-zNLrx_50QvcOxB--ZDm0vmSTbCOl5ml_801IDFTw"
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
  any calls to the api that need to be authented

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

# attendee
  ## request GET /
  ### Valid:
  Way to get  uuid, nick e email of attendee loged in
  ```json
 {
	"nick": "qwrqasd",
	"id": "43ffc4f5-3b12-4243-a157-e4e9e90d35dc",
	"email": "fooo@bar.com",
	"avatar": "/images/default/attendee-missing.png"
}
  ```


# badges
  ## GET / (Index)

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

# attendees
  ## GET / (Index)
  ### Valid:
  ```json
  {
    "data": [
      {
        "nickname": "foo",
        "id": "d832f350-fe30-4d98-a245-59d1aa186f36",
        "avatar": "/images/default/attendee-missing.png"
      }
    ]
  }
  ```

  ## GET /:id (Show)
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
  ### Valid:
  204 no content
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
