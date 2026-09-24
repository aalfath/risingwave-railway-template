# RisingWave v3.1.0 single node with a password on the root user, bootstrapped from environment variables.
FROM risingwavelabs/risingwave:v3.1.0@sha256:ee2e8e7a10b728d01b0e149d2a4f35864f0f52a0c889fa6cf9bc32c8ff46c602
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client tini \
 && rm -rf /var/lib/apt/lists/*
COPY risingwave.toml /etc/risingwave/risingwave.toml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
EXPOSE 4566 5691
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
