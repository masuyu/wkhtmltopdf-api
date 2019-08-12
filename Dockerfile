FROM golang:1.12.7-alpine3.10 as build

WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api/

COPY . .

RUN apk add --no-cache git \
 && go get github.com/labstack/echo/... \
 && go get github.com/SebastiaanKlippert/go-wkhtmltopdf \
 && go get github.com/mitchellh/go-homedir \
 && CGO_ENABLED=0 go build -tags netgo -o gowkhtmltopdf

FROM ubuntu:14.04 as release

RUN apt-get update -qq \
 && apt-get install -y \
      build-essential \
      xorg \
      libssl-dev \
      libxrender-dev \
      wget \
      unzip \
      gdebi \
 && apt-get autoremove \
 && apt-get clean

WORKDIR /opt

COPY --from=build /go/src/github.com/masuyu/wkhtmltopdf-api/gowkhtmltopdf /go/src/github.com/masuyu/wkhtmltopdf-api/gowkhtmltopdf

ENV WKHTMLTOPDF_VERSION 0.12.4
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox-${WKHTMLTOPDF_VERSION}_linux-generic-amd64.tar.xz
RUN tar vxfJ wkhtmltox-${WKHTMLTOPDF_VERSION}_linux-generic-amd64.tar.xz \
 && ln -s /opt/wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf

RUN wget https://noto-website.storage.googleapis.com/pkgs/Noto-unhinted.zip \
 && unzip -d NotoSansJapanese Noto-unhinted.zip \
 && mkdir -p /usr/share/fonts/opentype \
 && mv -fv ./NotoSansJapanese /usr/share/fonts/opentype/NotoSansJapanese \
 && rm -rfv Noto-unhinted.zip \
 && fc-cache -fv

ENTRYPOINT ["/go/src/github.com/masuyu/wkhtmltopdf-api/gowkhtmltopdf"]
