VERSION:=v1.8.4

.PHONY: all
all:
	docker buildx build . -f build.Dockerfile \
		--build-arg=VERSION=$(VERSION) \
		--platform linux/arm64 \
		--tag ghcr.io/milgradesec/coredns:arm64 \
		--push
	
	docker buildx build . -f build.Dockerfile \
		--build-arg=VERSION=$(VERSION) \
		--platform linux/amd64 \
		--tag ghcr.io/milgradesec/coredns:amd64 \
		--push

	docker manifest create ghcr.io/milgradesec/coredns:$(VERSION) \
		ghcr.io/milgradesec/coredns:arm64 \
		ghcr.io/milgradesec/coredns:amd64
	docker manifest push --purge ghcr.io/milgradesec/coredns:$(VERSION)