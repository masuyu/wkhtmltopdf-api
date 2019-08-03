package api

import (
	"net/http"

	"github.com/labstack/echo"
)

// get method
func MainPage() echo.HandlerFunc {
	return func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello golang")
	}
}
