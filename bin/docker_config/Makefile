build: run

DOCKER = docker
CONTAINER = postgres
POSTGRES = postgres
RUNFLAGS = -d --name $(CONTAINER) -p 5432:5432 $(POSTGRES):11.5
CREATEUSER = createuser -U $(POSTGRES) -d $(USER)

run:
	$(DOCKER) run $(RUNFLAGS)
	@sleep 2
	$(DOCKER) exec $(CONTAINER) $(CREATEUSER)

start:
	$(DOCKER) start $(CONTAINER)

stop:
	$(DOCKER) stop $(CONTAINER)

.PHONY: run

clean:
	$(DOCKER) rm $(CONTAINER)
