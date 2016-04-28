FROM postgres:9.4

# A dockerfile to use to test the deployment tasks

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' \
  $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && \
  apt-get install -y postgresql-plperl-9.4 && \
  rm -rf /var/lib/apt/lists/*

ADD pre-docker-build_artifact pre-docker-build_artifact

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
