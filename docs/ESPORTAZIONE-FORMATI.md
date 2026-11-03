# Esportare da Zim in Word, PDF, LaTeX e Markdown

Questa guida riguarda la versione Windows di Zim. Il comando **File → Esporta** include già HTML, LaTeX, Markdown e RST. Word e PDF richiedono un programma esterno per la conversione o la compilazione.

## Formati disponibili

| Formato | Come viene prodotto | Requisiti |
|---|---|---|
| Markdown (.md) | Esportazione nativa di Zim | Zim |
| LaTeX (.tex) | Esportazione nativa di Zim | Zim |
| Word (.docx) | Zim esporta Markdown, poi Pandoc converte in DOCX | Zim e Pandoc |
| PDF (.pdf) | Zim esporta LaTeX, poi latexmk compila il PDF | Zim e una distribuzione LaTeX con latexmk |

## Installazione dei requisiti aggiuntivi

1. Installa Pandoc da https://pandoc.org/installing.html per creare file Word.
2. Per creare PDF, installa una distribuzione LaTeX per Windows, ad esempio MiKTeX (https://miktex.org/download), e verifica che il comando latexmk sia disponibile nel PATH.
3. Chiudi e riapri PowerShell dopo l'installazione, così Windows aggiorna il PATH.

Markdown e LaTeX non richiedono questi programmi aggiuntivi.

## Esportazione tramite PowerShell

Il repository include lo script tools/export-document.ps1.

Apri PowerShell e usa uno dei seguenti comandi, sostituendo i percorsi di esempio con quelli reali:

### Word
~~~powershell
.\tools\export-document.ps1 -NotebookPath "C:\Users\Nome\Notes" -Format word -OutputPath "C:\Users\Nome\Desktop\Quaderno.docx"
~~~

### PDF
~~~powershell
.\tools\export-document.ps1 -NotebookPath "C:\Users\Nome\Notes" -Format pdf -OutputPath "C:\Users\Nome\Desktop\Quaderno.pdf"
~~~

### LaTeX
~~~powershell
.\tools\export-document.ps1 -NotebookPath "C:\Users\Nome\Notes" -Format latex -OutputPath "C:\Users\Nome\Desktop\Quaderno.tex"
~~~

### Markdown
~~~powershell
.\tools\export-document.ps1 -NotebookPath "C:\Users\Nome\Notes" -Format markdown -OutputPath "C:\Users\Nome\Desktop\Quaderno.md"
~~~

Per esportare una singola pagina, aggiungi -Page "Nome della pagina" al comando.

Se Windows blocca l'esecuzione dello script, puoi avviare una singola sessione PowerShell con:
~~~powershell
powershell -ExecutionPolicy Bypass -File .\tools\export-document.ps1 -NotebookPath "C:\Users\Nome\Notes" -Format word -OutputPath "C:\Users\Nome\Desktop\Quaderno.docx"
~~~

## Nota importante

Questo è un primo strumento di esportazione per Windows, non aggiunge ancora Word e PDF come voci native nel menu grafico **File → Esporta**. Il PDF dipende dai pacchetti LaTeX installati e la conversione Word dipende da Pandoc. Prima di distribuire una build come completa, occorre provare lo script su un notebook reale, verificare immagini, allegati, tabelle e collegamenti, e successivamente integrare i comandi nell'interfaccia grafica.
