FROM postgres:9.4

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' \
  $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && \
  apt-get install -y postgresql-plperl-9.4 && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
