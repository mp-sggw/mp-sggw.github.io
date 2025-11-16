<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="/faktura">
    <html>
    <head>
        <title>Faktura VAT - Numer: <xsl:value-of select="numer"/></title>
        <style>
            /* --- CSS dla całej faktury (Wbudowane style) --- */
            body { 
                font-family: 'Outfit', Arial, sans-serif; 
                line-height: 1.6; 
                padding: 20px; 
                background-color: #f4f4f4; 
                color: #333; 
                font-size: 14px;
            }

            .invoice-wrapper {
                border: 1px solid #ccc;
                padding: 40px;
                margin: 20px auto;
                max-width: 900px;
                background-color: white;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                border-radius: 8px;
            }

            h1 {
                text-align: center;
                color: #1a56a0;
                border-bottom: 3px solid #1a56a0;
                padding-bottom: 15px;
                margin-bottom: 30px;
                font-size: 28px;
                font-weight: 700;
            }

            .header-info {
                text-align: right;
                margin-bottom: 30px;
                font-size: 15px;
            }

            .header-info strong {
                color: #1a56a0;
            }

            .parties-container {
                margin-bottom: 30px;
            }

            .parties-container::after {
                content: "";
                display: table;
                clear: both;
            }

            .party {
                width: 48%;
                float: left;
                padding: 15px;
                border: 1px solid #e0e0e0;
                border-radius: 6px;
            }

            .party.seller {
                margin-right: 4%;
            }

            .party h3 {
                margin-top: 0;
                color: #555;
                border-bottom: 1px solid #e0e0e0;
                padding-bottom: 5px;
                font-size: 18px;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 25px;
                font-size: 14px;
            }

            thead th {
                background-color: #1a56a0;
                color: white;
                padding: 12px 10px;
                border: none;
                text-transform: uppercase;
                font-weight: 400;
            }

            tbody td {
                border: 1px solid #e0e0e0;
                padding: 10px;
            }

            tbody tr:nth-child(even) {
                background-color: #f9f9f9;
            }

            tfoot td {
                border: none;
                padding: 8px 10px;
            }

            .total-row {
                background-color: #e8f0f8;
                font-weight: bold;
            }

            .final-total {
                text-align: right;
                margin-top: 20px;
                padding: 15px;
                border-top: 2px solid #1a56a0;
                font-size: 1.6em;
                color: #000;
            }

            .final-total strong {
                color: #c0392b;
                font-weight: 700;
            }

            .invoice-wrapper > div:last-child p {
                margin-top: 30px;
                text-align: center;
                font-style: italic;
                color: #888;
            }
        </style>
    </head>
    <body>
        <div class="invoice-wrapper">
            <div class="header-info">
                <h1>FAKTURA VAT</h1>
                <p>Numer Faktury: <strong><xsl:value-of select="numer"/></strong></p>
                <p>Data Wystawienia: <strong><xsl:value-of select="dataWystawienia"/></strong></p>
            </div>

            <div class="parties-container">
                <div class="party seller">
                    <h3>Sprzedawca</h3>
                    <p><strong><xsl:value-of select="sprzedawca/nazwa"/></strong></p>
                    <p>NIP: <xsl:value-of select="sprzedawca/nip"/></p>
                    <p>Adres: <xsl:value-of select="sprzedawca/adres"/>, <xsl:value-of select="sprzedawca/kod"/></p>
                </div>
                
                <div class="party client">
                    <h3>Nabywca</h3>
                    <p><strong><xsl:value-of select="nabywca/nazwa"/></strong></p>
                    <p>NIP: <xsl:value-of select="nabywca/nip"/></p>
                    <p>Adres: <xsl:value-of select="nabywca/adres"/>, <xsl:value-of select="nabywca/kod"/></p>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Lp.</th>
                        <th>Nazwa Usługi/Towaru</th>
                        <th>Jedn.</th>
                        <th>Ilość</th>
                        <th>Cena Netto</th>
                        <th>VAT %</th>
                        <th>Wartość Netto</th>
                        <th>Kwota VAT</th>
                        <th>Wartość Brutto</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="pozycje/pozycja">
                        <tr>
                            <td><xsl:value-of select="position()"/></td>
                            <td><xsl:value-of select="nazwa"/></td>
                            <td><xsl:value-of select="jednostka"/></td>
                            <td><xsl:value-of select="ilosc"/></td>
                            <td><xsl:value-of select="cena"/></td>
                            <td><xsl:value-of select="vat"/></td>
                            <td><xsl:value-of select="netto"/></td>
                            <td><xsl:value-of select="kwotaVat"/></td>
                            <td><xsl:value-of select="brutto"/></td>
                        </tr>
                    </xsl:for-each>
                </tbody>
                <tfoot>
                    <tr class="total-row">
                        <td colspan="6" style="text-align: right;">Suma Netto:</td>
                        <td><xsl:value-of select="suma/netto"/></td>
                        <td></td>
                        <td></td>
                    </tr>
                    <tr class="total-row">
                        <td colspan="7" style="text-align: right;">Suma VAT:</td>
                        <td><xsl:value-of select="suma/vat"/></td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
            
            <div class="final-total">
                Kwota do zapłaty (Brutto): <strong><xsl:value-of select="suma/brutto"/> PLN</strong>
            </div>

            <div style="margin-top: 30px; text-align: center;">
                <p>Dokument wygenerowany przez strona Kacpra Olszewskiego.</p>
            </div>
        </div>
    </body>
    </html>
</xsl:template>
</xsl:stylesheet>