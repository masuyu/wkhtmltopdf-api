FROM golang:latest
WORKDIR /go/src/github.com/masuyu/wkhtmltopdf-api/
RUN go get -d -v golang.org/x/net/html
RUN go get github.com/labstack/echo/...
COPY wkhtmltopdf.go .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o api .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/masuyu/wkhtmltopdf-api/wkhtmltopdf .
CMD ["./wkhtmltopdf"]

