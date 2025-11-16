<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="/faktura">
    <html>
    <head>
        <title>Faktura VAT - Numer: <xsl:value-of select="numer"/></title>
        <style>
            body {
                font-family: Arial, Helvetica, sans-serif;
                margin: 40px;
                background: #f7f7f7;
                color: #000;
            }
            .invoice-wrapper {
                background: white;
                padding: 35px 45px;
                max-width: 900px;
                margin: auto;
                border: 1px solid #d0d0d0;
                box-shadow: 0 0 10px rgba(0,0,0,0.15);
            }
            .header-info {
                border-bottom: 3px solid #1e65b8;
                padding-bottom: 15px;
                margin-bottom: 25px;
            }
            .header-info h1 {
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 8px;
            }
            .header-info p {
                font-size: 14px;
                margin: 3px 0;
            }
            .parties-container {
                display: flex;
                justify-content: space-between;
                margin-bottom: 35px;
                gap: 40px;
            }
            .party {
                width: 50%;
                border: 1px solid #c3d6f2;
                padding: 15px 18px;
                border-radius: 6px;
                background: #f0f6ff;
            }
            .party h3 {
                margin-bottom: 6px;
                font-size: 16px;
                color: #1e65b8;
                border-bottom: 1px solid #b5cff3;
                padding-bottom: 4px;
            }
            .party p {
                font-size: 13px;
                margin: 4px 0;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 30px;
                font-size: 13px;
            }
            th {
                background: #1e65b8;
                color: white;
                padding: 8px 5px;
                border: 1px solid #0f4178;
                text-align: center;
                font-weight: 600;
            }
            td {
                padding: 6px 4px;
                border: 1px solid #bfc8d1;
                text-align: center;
            }
            tbody tr:nth-child(even) {
                background: #f5f7fa;
            }
            .total-row td {
                background: #e6eefb;
                font-weight: bold;
            }
            .final-total {
                font-size: 18px;
                font-weight: 700;
                text-align: right;
                margin-top: 15px;
                padding: 12px;
                border-top: 3px solid #1e65b8;
                color: #b80000; /* czerwone dla ważnego komunikatu */
            }
            .invoice-wrapper > div:last-child p {
                font-size: 12px;
                color: #555;
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
        </div>
    </body>
    </html>
</xsl:template>

</xsl:stylesheet>

