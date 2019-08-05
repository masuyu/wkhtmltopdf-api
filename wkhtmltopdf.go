package main

import (
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"

	"github.com/masuyu/wkhtmltopdf-api/api"
)

func main() {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.GET("/wkhtmltopdf", api.GetPdf())
	e.Start(":1323")
}
