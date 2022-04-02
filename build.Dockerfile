FROM --platform=amd64 golang:1.18 AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ARG VERSION

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /go/src/app
COPY . .

RUN git clone --branch ${VERSION} --single-branch --depth 1 https://github.com/coredns/coredns.git && \
    cp plugin.cfg coredns/ && \
    cd coredns && \
    go get github.com/miekg/dns@v1.1.48 && \
    go get github.com/milgradesec/filter@v1.2.3 && \
    make SYSTEM="GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT}" GITCOMMIT=${VERSION}

FROM alpine:3.15.3

RUN apk update && apk add --no-cache ca-certificates \
    && addgroup -g 1000 coredns \
    && adduser -u 1000 -G coredns -s /sbin/nologin -D coredns

COPY --from=builder /go/src/app/coredns/coredns /coredns

USER coredns
ENTRYPOINT ["/coredns"]
