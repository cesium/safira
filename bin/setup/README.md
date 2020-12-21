## How to Run?

We use ```docker-compose``` to deploy a database engine in docker.
Some commands that are useful:

  * ``` docker-compose up -d ```   -> Create a PostgreSQL container.
  * ``` docker-compose down -v ``` -> Destroy the containers and volumes deployed with ```docker-compose up```.

Notes: 
  * If you have some trouble running any ```mix``` commands after the container deployment, and the errors match ```key :password not found in:```, then you should leave in blank ```POSTGRES_PASSWORD``` field in .env file.
