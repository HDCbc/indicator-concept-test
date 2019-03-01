FROM alpine:latest

ADD ./scripts/autoMergeRequest.sh /scripts/autoMergeRequest.sh
RUN apk update && \
    apk add git && \
    apk add python3 && \
    apk add curl && \
    apk add bash && \
    apk add postgresql-client && \
    chmod +x /scripts/autoMergeRequest.sh