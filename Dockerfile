FROM golang:1.23.4-alpine3.20 as builder

WORKDIR /src
# оптимизация кеширования слоев
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o app

FROM alpine:3.20

WORKDIR /app
# создание непривелигированного пользователя вместо root
RUN adduser -D -g '' appuser
COPY --from=builder /src/app .
# потом заменить на volume
COPY --from=builder /src/tracker.db .
RUN chmod +x /app && chown appuser:appuser /app -R
USER appuser
CMD ["./app"]
