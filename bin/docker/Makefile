build: run

DOCKER = docker
CONTAINER = postgres
POSTGRES = postgres
POSTGRES_IMAGE = 11.5
DB_PORT = 5432
RUN_FLAGS = -d --name $(CONTAINER) -p $(DB_PORT):5432 $(POSTGRES):$(POSTGRES_IMAGE)
CREATE_USER = createuser -U $(POSTGRES) -d $(USER)

run:
	$(DOCKER) pull $(POSTGRES):$(POSTGRES_IMAGE)
	$(DOCKER) run $(RUN_FLAGS)
	@sleep 2
	$(DOCKER) exec $(CONTAINER) $(CREATE_USER)

start:
	$(DOCKER) start $(CONTAINER)

stop:
	$(DOCKER) stop $(CONTAINER)

.PHONY: run

clean:
	$(DOCKER) rm $(CONTAINER)
