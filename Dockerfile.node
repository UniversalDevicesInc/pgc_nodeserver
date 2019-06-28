# Global
FROM node:11
LABEL maintainer="James Milne <milne.james@gmail.com>"

# NodeServer Pre-reqs
ARG STAGE=test
ARG LOCAL=false
ENV STAGE $STAGE
ENV LOCAL $LOCAL
RUN apt-get update
RUN apt-get -qqy install git curl jq

RUN mkdir -p /app/logs
RUN mkdir -p /app/certs
WORKDIR /app
# COPY certs/ /app/certs
COPY startup.sh /app/
# COPY ecobee/ /app/template
# COPY pgc_interface/pgc_interface /app/pgc_interface
ENTRYPOINT [ "/usr/bin/env", "bash", "-e", "startup.sh" ]