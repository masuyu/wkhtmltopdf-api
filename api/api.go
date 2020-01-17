package api

import (
	"bytes"
	"log"
	"net/http"
	"strings"

	gowkhtmltopdf "github.com/SebastiaanKlippert/go-wkhtmltopdf"
	"github.com/labstack/echo"
)

type PdfOptions struct {
	HTMLString   string `json:"htmlstring"`
	Encoding     string `json:"encoding"`
	PageSize     string `json:"page-size"`
	MarginBottom uint   `json:"margin-bottom"`
	MarginLeft   uint   `json:"marin-left"`
	MarginRight  uint   `json:"margin-right"`
	MarginTop    uint   `json:"margin-top"`
	UserName     string `json:"username"`
	Password     string `json:"password"`
}

// FetchPdf recived url, generate pdf, return pdf
func FetchPdf() echo.HandlerFunc {
	return func(c echo.Context) error {
		// post json bind struct PdfOptions
		pdfoptions := new(PdfOptions)
		if err := c.Bind(pdfoptions); err != nil {
			log.Fatal(err)
		}
		// page type Page
		page := gowkhtmltopdf.NewPageReader(strings.NewReader(pdfoptions.HTMLString))

		// set page options basic Authentication
		page.PageOptions.Username.Set(pdfoptions.UserName)
		page.PageOptions.Password.Set(pdfoptions.Password)
		page.PageOptions.DisableLocalFileAccess.Set(true)
		page.PageOptions.NoImages.Set(true)

		// pdfg type PDFGenerator
		pdfg := gowkhtmltopdf.NewPDFPreparer()
		pdfg.AddPage(page)

		// set options
		pdfg.Dpi.Set(600)
		pdfg.PageSize.Set(pdfoptions.PageSize)
		pdfg.MarginBottom.Set(pdfoptions.MarginBottom)
		pdfg.MarginTop.Set(pdfoptions.MarginTop)
		pdfg.MarginLeft.Set(pdfoptions.MarginLeft)
		pdfg.MarginRight.Set(pdfoptions.MarginRight)

		// The html string is also saved as base64 string in the JSON file
		jsonBytes, err := pdfg.ToJSON()
		if err != nil {
			log.Fatal(err)
		}

		// Server code, create a new PDF generator from JSON, also looks for the wkhtmltopdf executable
		pdfgFromJSON, err := gowkhtmltopdf.NewPDFGeneratorFromJSON(bytes.NewReader(jsonBytes))
		if err != nil {
			log.Fatal(err)
		}

		// Create the PDF
		err = pdfgFromJSON.Create()
		if err != nil {
			log.Fatal(err)
		}

		// return dfpbyte
		pdfbyte := pdfgFromJSON.Bytes()
		return c.JSON(http.StatusOK, pdfbyte)
	}
}
