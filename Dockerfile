###############################################################################
# Build AWS Cli
###############################################################################
FROM python:3.11-alpine AS build

# renovate: datasource=github-tags depName=aws/aws-cli extractVersion=(?<version>.*)$
ARG AWS_CLI_VERSION=2.33.13

# Change workdir
WORKDIR /tmp

# Install dependencies
RUN apk add --no-cache --update autoconf automake binutils curl libtool make

# Build AWS Cli
RUN curl "https://awscli.amazonaws.com/awscli-${AWS_CLI_VERSION}.tar.gz" -o "awscli-${AWS_CLI_VERSION}.tar.gz" && \
    tar -xzf "awscli-${AWS_CLI_VERSION}.tar.gz" && \
    cd "awscli-${AWS_CLI_VERSION}" && \
    ./configure --with-download-deps --with-install-type=portable-exe && \
    make && \
    tar -czf /tmp/awscli.tar.gz -C "/tmp/awscli-${AWS_CLI_VERSION}/build/exe/aws" .

###############################################################################
# AWS Cli Docker Image
###############################################################################
FROM alpine:3.23
LABEL maintainer="Julian Nonino <noninojulian@gmail.com>"

# Install dependencies
RUN apk add --no-cache --update bash groff less jq yq

# Copy AWS Cli tar file
COPY --from=build /tmp/awscli.tar.gz /tmp/awscli.tar.gz

# Install AWS Cli
RUN mkdir -p /tmp/awscli && \
    tar -xzf /tmp/awscli.tar.gz -C /tmp/awscli && \
    /tmp/awscli/install && \
    rm -rf /tmp/awscli /tmp/awscli.tar.gz

# Setup entrypoint
ENTRYPOINT ["/usr/local/bin/aws"]
