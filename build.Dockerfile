FROM --platform=amd64 golang:1.16.2

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG TAG=v1.8.3

WORKDIR /go/src/app
COPY . .

RUN git clone --branch ${TAG} --single-branch --depth 1 https://github.com/coredns/coredns.git && \
    cp plugin.cfg coredns/ && \
    cp -r patches coredns/ && \
    cd coredns && \
    git apply patches/server_https.patch && \
    go get github.com/milgradesec/ratelimit@v1.0.0 && \
    go get github.com/milgradesec/filter@v1.0.0 && \
    go get github.com/miekg/dns@v1.1.40 && \
    make SYSTEM="GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT}" GITCOMMIT=${TAG}

FROM alpine:3.13

RUN apk update && apk add --no-cache ca-certificates

FROM scratch

COPY --from=0 /go/src/app/coredns/coredns /coredns
COPY --from=1 /etc/ssl/certs /etc/ssl/certs

ENTRYPOINT ["/coredns"]
