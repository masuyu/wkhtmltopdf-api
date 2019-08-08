FROM golang:1.12-alpine as build

WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api/

COPY . .

RUN apk add --no-cache git \
 && go get github.com/labstack/echo/... \
 && go get github.com/SebastiaanKlippert/go-wkhtmltopdf \
 && go get github.com/mitchellh/go-homedir \
 && CGO_ENABLED=0 go build -tags netgo -o gowkhtmltopdf

ENV WKHTMLTOPDF_VERSION 0.12.4
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox-${WKHTMLTOPDF_VERSION}_linux-generic-amd64.tar.xz
RUN tar vxfJ wkhtmltox-${WKHTMLTOPDF_VERSION}_linux-generic-amd64.tar.xz

FROM busybox as release
WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api
COPY --from=build /go/src/github.com/masuyu/wkhtmltopdf-api/gowkhtmltopdf .
COPY --from=build /go/src/github.com/masuyu/wkhtmltopdf-api/wkhtmltox/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf

ENTRYPOINT ["/go/src/github.com/masuyu/wkhtmltopdf-api/gowkhtmltopdf"]
