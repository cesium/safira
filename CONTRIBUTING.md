## Setup

To run Safira locally, you need to have some tools installed. Go to ```bin/setup``` and execute the setup script ```./setup.sh```.

## Database on Docker

We use ```docker-compose``` to deploy a database engine in docker.
Some commands that are useful:

  * ``` docker-compose up -d ```   -> Create a PostgreSQL container.
  * ``` docker-compose down -v ``` -> Destroy the containers and volumes deployed with ```docker-compose up```.

Notes: 
  * If you have some trouble running any ```mix``` commands after the container deployment, and the errors match ```key :password not found in:```, then you should leave in blank ```DB_PASSWORD``` field in .env file.
