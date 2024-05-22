###############################################################################
# Build AWS Cli
###############################################################################
FROM alpine:3.20.0 AS BUILD

# renovate: datasource=github-tags depName=aws/aws-cli extractVersion=(?<version>.*)$
ARG AWS_CLI_VERSION=2.15.56

# Install dependencies
RUN apk add --no-cache --update git build-base libffi-dev cmake python3 py3-pip python3-dev py3-setuptools py3-distutils-extra gcompat

# Build AWS Cli
WORKDIR /tmp
RUN git clone --single-branch --depth 1 -b ${AWS_CLI_VERSION} https://github.com/aws/aws-cli.git awscli && \
    cd awscli && \
    python -m venv venv && \
    . venv/bin/activate && \
    scripts/installers/make-exe

###############################################################################
# AWS Cli Docker Image
###############################################################################
FROM alpine:3.20.0
LABEL maintainer="Julian Nonino <noninojulian@gmail.com>"

# Install dependencies
RUN apk add --no-cache --update bash groff less jq yq

# Copy AWS Cli zip file
COPY --from=BUILD /tmp/awscli/dist/awscli-exe.zip /tmp/awscli.zip

# Install AWS Cli
RUN unzip -q /tmp/awscli.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscli.zip

# Setup entrypoint
ENTRYPOINT ["/usr/local/bin/aws"]
