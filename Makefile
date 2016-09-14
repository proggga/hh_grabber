libs_for_gcc = 31
keyword = $(word)
ifeq ($(strip $(word)),)
	url = localhost:3000/run
else
	url = localhost:3000/run?keyword=
endif

run:
	@curl $(url)$(keyword) && echo

dev:
	@curl localhost:3000/test && echo

side:
	bundle exec sidekiq

sidedev: dev side

migrate:
	bundle exec rake db:migrate

rollback:
	bundle exec rake db:rollback

deldb:
	rm db/development.sqlite3

remigrate: deldb migrate

reset-hard: remigrate side
