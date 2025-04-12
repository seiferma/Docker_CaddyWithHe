FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS builder

ARG TARGETARCH
ARG CADDY_VERSION=latest
ARG GOOS=linux
ARG CGOENABLED=0

RUN apk add --no-cache git
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@$CADDY_VERSION
RUN export GOARCH=$TARGETARCH && \
    xcaddy build \
      --with github.com/caddy-dns/he \
      --replace github.com/caddyserver/certmagic=github.com/caddyserver/certmagic@latest
RUN apk add --no-cache libcap
RUN setcap cap_net_bind_service=+ep /go/caddy
RUN touch /tmp/empty



FROM scratch

ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data

COPY --from=builder /tmp/empty /etc/caddy/Caddyfile
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/caddy /bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
