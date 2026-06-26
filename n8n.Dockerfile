FROM alpine:3.22 AS docker-cli
RUN apk add --no-cache docker-cli

FROM n8nio/n8n
USER root
COPY --from=docker-cli /usr/bin/docker /usr/local/bin/docker
COPY scripts/n8n-entrypoint.sh /custom-entrypoint.sh
RUN sed -i 's/\r//' /custom-entrypoint.sh && chmod +x /custom-entrypoint.sh
USER node
ENTRYPOINT ["tini", "--", "/custom-entrypoint.sh"]