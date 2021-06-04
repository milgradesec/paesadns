FROM --platform=amd64 golang:1.16.5

ARG TAG=v1.8.4
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /go/src/app
COPY . .

RUN git clone --branch ${TAG} --single-branch --depth 1 https://github.com/coredns/coredns.git && \
    cp plugin.cfg coredns/ && \
    cp -r patches coredns/ && \
    cd coredns && \
    git apply patches/server_https.patch && \
    go mod tidy && \
    go get github.com/milgradesec/ratelimit@v1.0.0 && \
    go get github.com/milgradesec/filter@v1.2.0 && \
    go get github.com/miekg/dns@v1.1.42 && \
    make SYSTEM="GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT}" GITCOMMIT=${TAG}

FROM alpine:3.13

RUN apk update && apk add --no-cache ca-certificates

FROM scratch

COPY --from=0 /go/src/app/coredns/coredns /coredns
COPY --from=1 /etc/ssl/certs /etc/ssl/certs

ENTRYPOINT ["/coredns"]
