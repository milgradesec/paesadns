FROM --platform=amd64 golang:1.19.1 AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ARG VERSION

ENV GO111MODULE=on \
    CGO_ENABLED=0

LABEL org.opencontainers.image.source="https://github.com/milgradesec/paesadns"

WORKDIR /go/src/app

COPY . .

RUN git clone --branch ${VERSION} --single-branch --depth 1 https://github.com/coredns/coredns.git && \
    cp plugin.cfg coredns/ && \
    cd coredns && \
    go get github.com/miekg/dns@v1.1.50 && \
    go get github.com/milgradesec/filter@v1.3.0 && \
    make SYSTEM="GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT}" GITCOMMIT=${VERSION}

FROM gcr.io/distroless/static-debian11:nonroot

COPY --from=builder --chown=nonroot /go/src/app/coredns/coredns /coredns

USER nonroot
ENTRYPOINT ["/coredns"]
