# syntax=docker/dockerfile:1
FROM golang:1.18-alpine3.15 as builder

WORKDIR /app

COPY . .

RUN go mod download && go build -o web main.go

FROM alpine:3.15

WORKDIR /app

COPY --from=builder /app/web ./

ENTRYPOINT [ "./web" ]


