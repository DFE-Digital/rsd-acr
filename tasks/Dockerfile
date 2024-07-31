FROM mcr.microsoft.com/azure-cli
LABEL org.opencontainers.image.source=https://github.com/DFE-Digital/rsd-acr

RUN apk add curl
RUN apk add --update coreutils && rm -rf /var/cache/apk/*

COPY ./acr-scan.sh /
RUN chmod +x /acr-scan.sh
