# Build stage
FROM golang:1.21-alpine3.20 AS builder

WORKDIR /app

COPY go.mod ./

RUN go mod download

COPY . .

RUN go build -o main main.go

# Running stage
FROM alpine:3.22.2

WORKDIR /app

COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]