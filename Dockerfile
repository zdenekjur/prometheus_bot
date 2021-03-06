FROM  golang:1.18.2-alpine3.15 as builder
RUN apk add --no-cache git ca-certificates make tzdata upx
COPY . /app
RUN cd /app && \
    go get -d -v && \
    CGO_ENABLED=0 GOOS=linux go build -v -a -ldflags="-w -s" -o prometheus_bot
RUN cd /app && \
    upx --best --lzma prometheus_bot

FROM alpine:3.15.4
COPY --from=builder /app/prometheus_bot /
RUN apk add --no-cache ca-certificates tzdata tini
USER nobody
EXPOSE 9087
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/prometheus_bot"]
