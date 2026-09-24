# Deploy and Host RisingWave on Railway

RisingWave is a Postgres-compatible streaming database. You ingest events from Kafka, Postgres CDC, webhooks or plain inserts, define materialized views in SQL, and RisingWave keeps them incrementally up to date in real time. Any Postgres driver, `psql` or BI tool can query the results with low latency.

## About Hosting RisingWave

This template deploys RisingWave v3.1.0 in single-node mode from a small public wrapper image that builds on the official one, pinned by digest. The wrapper sets a generated password on the `root` user at every start, and only loopback connections inside the container are trusted, so every other client needs the password. State is stored on a Railway volume. Services connect over the private network on port 4566, and external clients use the Railway TCP proxy. RisingWave needs memory: give it at least 2 GB and consider the Pro plan for real workloads.

## Common Use Cases

- Real-time dashboards and metrics from event streams with SQL
- Streaming ETL from Kafka or Postgres CDC into materialized views
- Alerting and monitoring that reacts to events as they arrive

## Dependencies for RisingWave Hosting

- `aalfath/risingwave-railway-template` (public wrapper around `risingwavelabs/risingwave:v3.1.0`)
- A Railway volume at `/risingwave/data`
- A Railway TCP proxy for external clients

### Deployment Dependencies

- [RisingWave documentation](https://docs.risingwave.com/)
- [RisingWave v3.1.0 release](https://github.com/risingwavelabs/risingwave/releases/tag/v3.1.0)
- [Wrapper repository](https://github.com/aalfath/risingwave-railway-template)
- [Railway TCP proxy](https://docs.railway.com/reference/tcp-proxy)

### Implementation Details

| Service | Source | Networking | Storage |
| --- | --- | --- | --- |
| risingwave | `aalfath/risingwave-railway-template` | private 4566; TCP proxy to 4566; health on 5691 | volume at `/risingwave/data` |

```sql
CREATE TABLE orders (id INT, amount NUMERIC, ts TIMESTAMP);
CREATE MATERIALIZED VIEW revenue AS SELECT sum(amount) AS total FROM orders;
INSERT INTO orders VALUES (1, 19.90, now());
SELECT * FROM revenue;
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `RW_ROOT_PASSWORD` | generated | Password for `root`; changing it and redeploying rotates it |
| `DATABASE_URL` / `DATABASE_PUBLIC_URL` | private / TCP proxy | Connection strings (database `dev`) |

Notes:

- The meta dashboard on port 5691 is used for Railway's health check and is not exposed publicly.
- The TCP proxy carries traffic without TLS; prefer the private network.

This is a community-maintained deployment package and does not imply affiliation with or endorsement by the RisingWave project or its maintainers.

## Why Deploy RisingWave on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying RisingWave on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
