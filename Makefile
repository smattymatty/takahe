.ONESHELL:
.PHONY: image docs compose_build compose_up compose_down

image:
	docker build -t takahe -f docker/Dockerfile .

docs:
	cd docs/ && make html

compose_build:
	cd docker
	docker compose -f docker-compose.yml build

compose_up:
	cd docker
	docker compose -f docker-compose.yml up

compose_down:
	cd docker
	docker compose -f docker-compose.yml down

# Development Setup
.venv:
	python3 -m venv .venv
	. .venv/bin/activate
	python3 -m pip install -r requirements-dev.txt

.git/hooks/pre-commit: .venv
	.venv/bin/python -m pre_commit install

.env:
	cp development.env .env

_PHONY: setup_local
setup_local: .venv .env .git/hooks/pre-commit

_PHONY: startdb stopdb
startdb:
	cd docker
	docker compose -f docker-compose.yml up db -d

stopdb:
	cd docker
	docker compose -f docker-compose.yml stop db

_PHONY: superuser
createsuperuser: setup_local startdb
	. .venv/bin/activate
	python3 -m manage createsuperuser

_PHONY: test
test: setup_local
	. .venv/bin/activate
	python3 -m pytest

# Active development
_PHONY: migrations server stator
migrations: setup_local startdb
	. .venv/bin/activate
	python3 -m manage migrate

runserver: setup_local startdb
	. .venv/bin/activate
	python3 -m manage runserver

runstator: setup_local startdb
	. .venv/bin/activate
	python3 -m manage runstator
