document.addEventListener('DOMContentLoaded', () => {
    
    // Ustalenie, na ktĂłrej stronie jesteĹmy
    const isPreviewPage = window.location.pathname.endsWith('preview.html');

    if (!isPreviewPage) {
        // --- LOGIKA FORMULARZA (INDEX.HTML) ---
        const items = document.getElementById('items');
        const tpl = document.getElementById('rowTemplate');
        const addBtn = document.getElementById('addButton');
        const remBtn = document.getElementById('removeButton');

        function addRow() {
            const row = tpl.content.firstElementChild.cloneNode(true);
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

        // Podpinanie przyciskĂłw
        addBtn.addEventListener('click', addRow);
        remBtn.addEventListener('click', removeLastRow);
        addRow(); // Dodaj pierwszÄ pozycjÄ na starcie

        const form = document.querySelector("form");

        form.addEventListener("submit", (e) => {
            e.preventDefault();

            if (!form.reportValidity()) return;

            const formData = new FormData(form);

            // Zbieranie danych
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

            const uniqueData = {
                numer: formData.get("nr_f"),
                data: formData.get("date")
            };

            const names = formData.getAll("name[]");
            const units = formData.getAll("unit[]");
            const counts = formData.getAll("count[]");
            const prices = formData.getAll("price[]");
            const taxes = formData.getAll("tax[]");

            let sumNetto = 0, sumPodatek = 0, sumBrutto = 0;
            const pozycjeXML = [];

            // Obliczenia i generowanie XML dla pozycji
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
                sumPodatek += vat;
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

            // Generowanie caĹego ciÄgu XML
            const xml = `<?xml version="1.0" encoding="UTF-8"?>
            <faktura>
                <numer> ${uniqueData.numer} </numer>
                <dataWystawienia> ${uniqueData.data} </dataWystawienia>
                
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
                    <vat> ${sumPodatek.toFixed(2)} </vat>
                    <brutto> ${sumBrutto.toFixed(2)} </brutto>
                </suma>
            </faktura>`;

            // Zapis XML i przekierowanie
            sessionStorage.setItem("fakturaXML", xml);
            window.open("preview.html", "_blank");
        });

    } else {
        // --- LOGIKA TRANSFORMACJI (PREVIEW.HTML) ---
        const xmlString = sessionStorage.getItem("fakturaXML");
        const targetId = "faktura_kontener";
        
        if (!xmlString) {
            document.getElementById(targetId).innerHTML = "Brak danych faktury do wyĹwietlenia. WrĂłÄ do formularza i wypeĹnij dane.";
            return;
        }

        const xslUrl = "faktura.xsl"; 
        
        try {
            // 1. Parsowanie XML
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(xmlString, "application/xml");

            // 2. Wczytanie pliku XSLT
            const xslRequest = new XMLHttpRequest();
            xslRequest.open("GET", xslUrl, false); 
            xslRequest.send(null);
            const xslDoc = xslRequest.responseXML;
            
            if (xslRequest.status !== 200) {
                 document.getElementById(targetId).innerHTML = "BĹÄd: Nie moĹźna zaĹadowaÄ pliku faktura.xsl. Wymagany lokalny serwer WWW.";
                 return;
            }

            // 3. Transformacja i wyĹwietlenie
            const xsltProcessor = new XSLTProcessor();
            xsltProcessor.importStylesheet(xslDoc);
            
            const resultDocument = xsltProcessor.transformToFragment(xmlDoc, document);
            
            document.getElementById(targetId).innerHTML = '';
            document.getElementById(targetId).appendChild(resultDocument);
            
        } catch (error) {
            document.getElementById(targetId).innerHTML = `WystÄpiĹ nieoczekiwany bĹÄd transformacji: ${error.message}`;
        }
    }
});
