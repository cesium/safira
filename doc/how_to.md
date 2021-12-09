# Generate new managers
`mix gen.managers n` `n` being the number of managers to generate.
This will return emails and passwords for these accounts.

# Populate Database with badges
`mix gen.badges path_to_badges_csv`
Sample data can be found at `data/badges.csv`

# Generate attendees
`mix gen.attendees n` `n` being the number of managers to generate.
This will return attendee ids and respective discord association codes.
To finish creating attendees, it is needed to call the `sign_up` endpoint and
provide respective details.
