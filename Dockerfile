FROM alpine:latest

ADD ./scripts/ /scripts/
RUN apk update && \
    apk add git && \
    apk add python3 && \
    apk add curl && \
    apk add bash && \
    apk add jq && \
    apk add postgresql-client && \
    apk add openssh && \
    chmod +x /scripts/*.sh