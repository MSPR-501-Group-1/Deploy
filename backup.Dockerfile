FROM alpine:3.22
RUN apk add --no-cache docker-cli tzdata curl
ENV TZ=Europe/Paris
COPY scripts/backup-postgres.sh  /scripts/backup-postgres.sh
COPY scripts/backup-mongo.sh     /scripts/backup-mongo.sh
COPY scripts/restore-postgres.sh /scripts/restore-postgres.sh
COPY scripts/restore-mongo.sh    /scripts/restore-mongo.sh
RUN chmod +x /scripts/*.sh
COPY scripts/crontab /etc/crontabs/root
CMD ["crond", "-f", "-d", "8"]
