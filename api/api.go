package api

import (
	"log"
	"net/http"

	gowkhtmltopdf "github.com/SebastiaanKlippert/go-wkhtmltopdf"
	"github.com/labstack/echo"
)

// GetPdf recived url, generate pdf, return pdf
func GetPdf() echo.HandlerFunc {
	return func(c echo.Context) error {
		// set page, base to pdf
		uri := c.QueryParam("uri")
		page := gowkhtmltopdf.NewPage(uri)
		page.NoBackground.Set(true)
		page.DisableExternalLinks.Set(false)

		// create new pdf generator
		pdfg, err := gowkhtmltopdf.NewPDFGenerator()
		if err != nil {
			log.Fatal(err)
		}

		// add page to the PDF generator
		pdfg.AddPage(page)

		// set dpi of the content
		pdfg.Dpi.Set(350)

		// set margins to zero at all direction
		pdfg.MarginBottom.Set(0)
		pdfg.MarginTop.Set(0)
		pdfg.MarginLeft.Set(0)
		pdfg.MarginRight.Set(0)

		// generate pdf
		err = pdfg.Create()
		if err != nil {
			log.Fatal(err)
		}

		pdfbyte := pdfg.Bytes()

		return c.JSON(http.StatusOK, pdfbyte)
	}
}
