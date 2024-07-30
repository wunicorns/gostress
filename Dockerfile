FROM golang:1.22.5-alpine3.20 AS builder

WORKDIR /build

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/stress main.go

FROM alpine:3.20

WORKDIR /app

LABEL io.k8s.display-name="Memory Stress"

COPY --chown=0:0 --from=builder /build/bin /app/

#ENTRYPOINT ["/app/memory-stress"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]