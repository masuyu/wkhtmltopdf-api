FROM golang:1.12.7-alpine3.10 as build

WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api/

COPY . .

RUN apk add --no-cache git \
 && go get github.com/labstack/echo/... \
 && go get github.com/SebastiaanKlippert/go-wkhtmltopdf \
 && go get github.com/mitchellh/go-homedir \
 && CGO_ENABLED=0 go build -tags netgo -o gowkhtmltopdf

FROM alpine:latest as release
WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api
COPY --from=build /go/src/github.com/masuyu/wkhtmltopdf-api/gowkhtmltopdf .
RUN apk add wkhtmltopdf

ENTRYPOINT ["/go/src/github.com/masuyu/wkhtmltopdf-api/gowkhtmltopdf"]
