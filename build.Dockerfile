FROM --platform=amd64 golang:1.26rc2 AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ARG VERSION=master

ENV GO111MODULE=on \
    CGO_ENABLED=0

LABEL org.opencontainers.image.description="Custom CoreDNS image with the filtering and blocking plugins that power PaesaDNS"

WORKDIR /go/src/app

COPY . .

RUN git clone --branch ${VERSION} --single-branch --depth 1 https://github.com/coredns/coredns.git && \
    cp plugin.cfg coredns/ && \
    cd coredns && \
    go mod tidy -go=1.25 && \
    go get github.com/milgradesec/filter@main && \
    make SYSTEM="GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT}" GITCOMMIT=${VERSION}

FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder --chown=nonroot /go/src/app/coredns/coredns /coredns

USER nonroot
ENTRYPOINT ["/coredns"]
