FROM frodenas/ubuntu
LABEL maintainer="Ferran Rodenas <frodenas@gmail.com>, Dr Nic Williams <drnic@starkandwayne.com>"

# Install PostgreSQL 9.6
ENV PG_VERSION 9.6
RUN DEBIAN_FRONTEND=noninteractive \
    cd /tmp && \
    wget https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    apt-key add ACCC4CF8.asc && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --force-yes \
    postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
    jq && \
    service postgresql stop && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add scripts
ADD scripts /scripts
ADD scripts/sanity-test.sh /usr/bin/sanity-test
RUN chmod +x /scripts/*.sh /usr/bin/sanity-test
RUN touch /.firstrun

# Command to run
ENTRYPOINT ["/scripts/run.sh"]
CMD [""]

# Expose listen port
EXPOSE 5432

# Expose our data directory
VOLUME ["/data"]
