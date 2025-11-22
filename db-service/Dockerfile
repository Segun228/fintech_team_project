# ===== Builder =====
FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY db-service/go.mod db-service/go.sum ./
RUN go mod download

COPY db-service/ .

RUN CGO_ENABLED=0 GOOS=linux go build -o db-service ./cmd/app

# ===== Final stage =====
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/db-service .

COPY db-service/configs ./configs

COPY migrations ./migrations

CMD ["./db-service"]