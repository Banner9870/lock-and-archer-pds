# Official Bluesky PDS - see https://github.com/bluesky-social/pds
FROM ghcr.io/bluesky-social/pds:0.4

# Install bash and curl for entrypoint/healthcheck
USER root
RUN apk add --no-cache bash curl

# Copy entrypoint and seed script
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY seed-accounts.sh /app/seed-accounts.sh
RUN chmod +x /app/entrypoint.sh /app/seed-accounts.sh

# PDS data directory (attach a Railway volume at /pds in the service settings)
ENV PDS_DATA_DIRECTORY=/pds
# Required: use disk for blobs (PDS errors without S3 or disk configured)
ENV PDS_BLOBSTORE_DISK_LOCATION=/pds/blocks
ENV PDS_PORT=3000

# Railway sets PORT; PDS uses PDS_PORT
EXPOSE 3000

# Keep dumb-init for signal handling; our script becomes the main process
ENTRYPOINT ["dumb-init", "--", "/app/entrypoint.sh"]
