## How to Run?

If you want to run a PostgreSQL database engine in docker, you just need to run ``` ./setup.sh ``` inside this folder,
which leaves you with a container up-and-running, or informs you what you need or what went wrong.

The setup script uses a Makefile with has some commands you can run on your own:

  * ```make```       -> To create a PostgreSQL container and a user. After running this command your container is up-and-running.
  * ```make stop```  -> To stop the container.
  * ```make start``` -> To start a container after a stop.
  * ```make clean``` -> To remove the container, and consequently all its data.

Notes: 
  * The used PostgreSQL engine version is 11.5. There are new versions, but they require other configurations which might not be compatible with the current state of safira.
  * Makefile has some constants that you can change. Perhaps you already have a container named postgres, which has another version and you don't want to loose it, so in this case you might want to change the CONTAINER constant to another value, and perhaps its port too.
