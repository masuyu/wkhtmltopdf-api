FROM golang:1.12-alpine as build

WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api/

COPY . .

RUN apk add --no-cache git \
 && go get github.com/labstack/echo/... \
 && go get github.com/SebastiaanKlippert/go-wkhtmltopdf \
 && go get github.com/mitchellh/go-homedir \
 && CGO_ENABLED=0 go build -o wkhtmltopdf

FROM alpine

WORKDIR /var/www

COPY --from=build /go/src/github.com/masuyu/wkhtmltopdf-api/wkhtmltopdf .

RUN addgroup go \
  && adduser -D -G go go \
  && chown -R go:go /var/www/wkhtmltopdf

RUN apk add --no-cache msttcorefonts-installer fontconfig

ENV WKHTMLTOPDF_VERSION 0.12.4
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox-${WKHTMLTOPDF_VERSION}_linux-generic-amd64.tar.xz
RUN tar vxfJ wkhtmltox-${WKHTMLTOPDF_VERSION}_linux-generic-amd64.tar.xz \
 && ln -s /var/www/wkhtmltox/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf

RUN wget https://noto-website.storage.googleapis.com/pkgs/Noto-unhinted.zip \
 && mkdir -p /var/www/NotoSansJapanese \
 && unzip -d NotoSansJapanese Noto-unhinted.zip \
 && mkdir -p /usr/share/fonts/opentype \
 && mv -fv /var/www/NotoSansJapanese /usr/share/fonts/opentype/NotoSansJapanese \
 && rm -rfv Noto-unhinted.zip \
 && fc-cache -fv

CMD ["./wkhtmltopdf"]