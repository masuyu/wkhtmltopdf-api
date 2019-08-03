# FROM golang:latest as build
# WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api/
# RUN go get -d -v golang.org/x/net/html
# RUN go get github.com/labstack/echo/...
# COPY . .

# RUN CGO_ENABLED=0 GOOS=linux go build -o wkhtmltopdf .

# FROM alpine:latest
# RUN apk --no-cache add ca-certificates
# WORKDIR /root/
# COPY --from=build /go/src/github.com/masuyu/wkhtmltopdf-api/wkhtmltopdf .
# CMD ["./wkhtmltopdf"]

FROM golang:1.12-alpine as build

WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api/

COPY . .

RUN apk add --no-cache git \
 && go get github.com/labstack/echo/... \
 && go build -o wkhtmltopdf

FROM alpine

WORKDIR /var/www

COPY --from=build /go/src/github.com/masuyu/wkhtmltopdf-api/wkhtmltopdf .

RUN addgroup go \
  && adduser -D -G go go \
  && chown -R go:go /var/www/wkhtmltopdf

CMD ["./wkhtmltopdf"]