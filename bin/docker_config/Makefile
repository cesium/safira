DOCKER = docker
CONTAINER = postgres
POSTGRES = psql
RUNFLAGS = --name $(CONTAINER) -p 5432:5432 $(CONTAINER):11.5
CREATEUSER = createuser -U $(CONTAINER) -d $(USER)

run:
	$(DOCKER) run $(RUNFLAGS)

start:
	$(DOCKER) start $(CONTAINER)

stop:
	$(DOCKER) stop $(CONTAINER)

restart:
	$(DOCKER) restart $(CONTAINER)

createuser:
	$(DOCKER) exec $(CONTAINER) $(CREATEUSER)

clean:
	$(DOCKER) rm $(CONTAINER)
