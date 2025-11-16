document.addEventListener('DOMContentLoaded', () => {

    const preview = window.location.pathname.endsWith('preview.html');

    if (!preview) {
        const items = document.getElementById('items');
        const temp = document.getElementById('rowTemplate');
        const addBtn = document.getElementById('addButton');
        const remBtn = document.getElementById('removeButton');

        function addRow() {
            const row = temp.content.firstElementChild.cloneNode(true);
            items.appendChild(row);
        }

        function removeLastRow() {
            const rows = items.querySelectorAll('.item_row');
            if (rows.length > 1) {
                rows[rows.length - 1].remove();
            } else {
                rows[0].querySelectorAll('input').forEach(inp => inp.value = '');
            }
        }

        addBtn.addEventListener('click', addRow);
        remBtn.addEventListener('click', removeLastRow);
        addRow();

        const form = document.querySelector("form");

        form.addEventListener("submit", (e) => {
            e.preventDefault();

            if (!form.reportValidity()) return;

            const formData = new FormData(form);

            const seller = {
                nazwa: formData.get("seller_name"),
                nip: formData.get("seller_nip"),
                adres: formData.get("seller_address"),
                kod: formData.get("seller_zip")
            };

            const client = {
                nazwa: formData.get("client_name"),
                nip: formData.get("client_nip"),
                adres: formData.get("client_address"),
                kod: formData.get("client_zip")
            };

            const invoice = {
                numer: formData.get("nr_f"),
                data: formData.get("date")
            };

            const names = formData.getAll("name[]");
            const units = formData.getAll("unit[]");
            const counts = formData.getAll("count[]");
            const prices = formData.getAll("price[]");
            const taxes = formData.getAll("tax[]");

            let sumNetto = 0, sumVAT = 0, sumBrutto = 0;
            const pozycjeXML = [];

            for (let i = 0; i < names.length; i++) {
                const nazwa = names[i];
                const jednostka = units[i];
                const ilosc = Number(counts[i]);
                const cena = Number(prices[i]);
                const podatek = Number(taxes[i]);

                const netto = ilosc * cena;
                const vat = netto * (podatek / 100);
                const brutto = netto + vat;

                sumNetto += netto;
                sumVAT += vat;
                sumBrutto += brutto;

                pozycjeXML.push(
                    `<pozycja>
                    <nazwa> ${nazwa} </nazwa>
                    <jednostka> ${jednostka} </jednostka>
                    <ilosc> ${ilosc.toFixed(2)} </ilosc>
                    <cena> ${cena.toFixed(2)} </cena>
                    <vat> ${podatek.toFixed(2)} </vat>
                    <netto> ${netto.toFixed(2)} </netto>
                    <kwotaVat> ${vat.toFixed(2)} </kwotaVat>
                    <brutto> ${brutto.toFixed(2)} </brutto>		
                    </pozycja>`
                );
            }

            const xml = `<?xml version="1.0" encoding="UTF-8"?>
            <faktura>
                <numer> ${invoice.numer} </numer>
                <dataWystawienia> ${invoice.data} </dataWystawienia>
                
                <sprzedawca> 
                    <nazwa> ${seller.nazwa} </nazwa>
                    <nip> ${seller.nip} </nip>
                    <adres> ${seller.adres} </adres>
                    <kod> ${seller.kod} </kod>
                </sprzedawca>

                <nabywca> 
                    <nazwa> ${client.nazwa} </nazwa>
                    <nip> ${client.nip} </nip>
                    <adres> ${client.adres} </adres>
                    <kod> ${client.kod} </kod>
                </nabywca>
                
                <pozycje> ${pozycjeXML.join("\n")} </pozycje>
                
                <suma> 
                    <netto> ${sumNetto.toFixed(2)} </netto>
                    <vat> ${sumVAT.toFixed(2)} </vat>
                    <brutto> ${sumBrutto.toFixed(2)} </brutto>
                </suma>
            </faktura>`;

            sessionStorage.setItem("fakturaXML", xml);
            window.open("preview.html", "_blank");
        });

    } else {
        const xmlString = sessionStorage.getItem("fakturaXML");
        const targetId = "faktura_kontener";

        const xsl = "faktura.xsl";
        
        (async () => {
        try {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(xmlString, "application/xml");

            const response = await fetch(xsl);
            if (!response.ok) {
                document.getElementById(targetId).innerHTML =
                    "Blad: Nie mozna zaladowac pliku faktura.xsl.";
                return;
            }

            const xslText = await response.text();
            const xslDoc = parser.parseFromString(xslText, "application/xml");

            const xsltProcessor = new XSLTProcessor();
            xsltProcessor.importStylesheet(xslDoc);

            const resultDocument = xsltProcessor.transformToFragment(xmlDoc, document);

            const container = document.getElementById(targetId);
            container.innerHTML = "";
            container.appendChild(resultDocument);

        } catch (error) {
            document.getElementById(targetId).innerHTML =
                `Blad Konwersji: ${error.message}`;
        }
    })();
    }
});
