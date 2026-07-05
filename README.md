# HueWidget - Philips Hue Control for KDE Plasma 6

[![License](https://img.shields.io/badge/License-GPL_2.0--or--later-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
[![Plasma](https://img.shields.io/badge/KDE-Plasma_6-orange.svg)](https://kde.org/)

---

### [Deutsch](#deutsch) | [English](#english)

---

## Deutsch

Ein leichtgewichtiges, natives KDE Plasma 6 Widget zur Steuerung von Philips Hue Lampen direkt aus dem Panel oder vom Desktop über die lokale REST-API der Philips Hue Bridge.

### Features
* **Lampen einzeln schalten**: Schalte beliebige Lampen mit einem Klick ein oder aus.
* **Helligkeitsregelung**: Stufenlose Anpassung der Helligkeit über integrierte Schieberegler.
* **Sammelschalter**: Knöpfe für "Alle an" und "Alle aus", um die gesamte Beleuchtung auf einmal zu steuern.
* **Einfache Einrichtung**: Automatisches Generieren des API-Keys per Knopfdruck in den Einstellungen (kein manuelles Auslesen per Web-Browser nötig).
* **Geräte-Filter**: Blende bestimmte Lampen aus, um nur die gewünschten Geräte im Widget anzuzeigen.
* **Customizing**: Option für einen transparenten Hintergrund und frei wählbare Farben (für den Leucht-Glow aktiver Lampen, Icons und Texte).
* **Konfigurierbare Aktualisierung**: Einstellbares Intervall für die Abfrage des aktuellen Status von der Bridge.

### Installation

#### Option 1: Über das Terminal (Empfohlen)
Verwenden Sie das KDE-Pakettool `kpackagetool6` im Projektverzeichnis:
```bash
# Aus dem Quellcodeverzeichnis installieren:
kpackagetool6 --type Plasma/Applet --install .
```
Alternativ können Sie die vorkompilierte `.plasmoid`-Datei installieren:
```bash
kpackagetool6 --type Plasma/Applet --install org.kde.plasma.huecontrol.plasmoid
```

#### Option 2: Manuelle Installation (Kopieren)
Erstellen Sie das Zielverzeichnis und kopieren Sie die Dateien dorthin:
```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.huecontrol
cp -r contents metadata.json ~/.local/share/plasma/plasmoids/org.kde.plasma.huecontrol/
```

> [!NOTE]
> Nach der Installation müssen Sie eventuell die Plasma-Shell neu starten, damit das Widget in der Auswahl erscheint:
> ```bash
> plasmashell --replace &
> ```
> Alternativ können Sie sich einmal ab- und wieder anmelden.

### Einrichtungsanleitung

1. Fügen Sie das Widget **Philips Hue Control** zu Ihrem Panel oder Desktop hinzu.
2. Machen Sie einen Rechtsklick auf das Widget und wählen Sie **Philips Hue-Steuerung einrichten...** (bzw. **Configure Philips Hue Control...**).
3. Tragen Sie im Feld **Bridge IP-Adresse** die IP-Adresse Ihrer Philips Hue Bridge ein (z. B. `192.168.1.100`).
4. **API-Key (Username) erstellen**:
   * Gehen Sie zu Ihrer physischen Philips Hue Bridge und drücken Sie den großen, runden **Link-Button** in der Mitte.
   * Klicken Sie innerhalb von 30 Sekunden im Einstellungsfenster des Widgets auf die Schaltfläche **API-Key erstellen**.
   * Der API-Key wird automatisch generiert und eingetragen.
5. Klicken Sie unten auf **Anwenden** oder **OK**.
6. Unter **Geräte ein-/ausblenden** können Sie nun die Liste der erkannten Lampen einsehen und einzelne Geräte abwählen, die nicht im Widget auftauchen sollen.
7. (Optional) Aktivieren Sie unter **Design & Farben** benutzerdefinierte Farben für Leucht-Glows, Icons und Texte oder machen Sie den Hintergrund transparent.

---

## English

A lightweight, native KDE Plasma 6 widget to control Philips Hue lamps directly from your panel or desktop via the local Philips Hue Bridge REST API.

### Features
* **Individual Lamp Control**: Toggle any lamp on or off with a single click.
* **Brightness Adjustment**: Seamlessly adjust brightness using built-in sliders.
* **Global Switches**: "All On" and "All Off" buttons to control all visible lights at once.
* **Easy Setup**: Automatically generate the API key with the click of a button in the settings dialog (no manual REST client configuration required).
* **Device Filter**: Hide or show specific lamps to keep only the relevant ones in your widget.
* **Customization**: Option for a transparent background and customizable colors (for the light glow, active/inactive icons, and text).
* **Configurable Polling**: Adjust the status refresh interval according to your needs.

### Installation

#### Option 1: Via Terminal (Recommended)
Use the KDE package manager `kpackagetool6` inside the project directory:
```bash
# Install from source directory:
kpackagetool6 --type Plasma/Applet --install .
```
Or install the pre-packaged `.plasmoid` file:
```bash
kpackagetool6 --type Plasma/Applet --install org.kde.plasma.huecontrol.plasmoid
```

#### Option 2: Manual Installation (Copying)
Create the target directory and copy the widget source files:
```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.huecontrol
cp -r contents metadata.json ~/.local/share/plasma/plasmoids/org.kde.plasma.huecontrol/
```

> [!NOTE]
> After installation, you may need to restart the Plasma shell for the widget to appear in the "Add Widgets" menu:
> ```bash
> plasmashell --replace &
> ```
> Alternatively, log out and log back in.

### Configuration Guide

1. Add the **Philips Hue Control** widget to your panel or desktop.
2. Right-click the widget and select **Configure Philips Hue Control...**.
3. In the **Bridge IP Address** field, enter the IP address of your Philips Hue Bridge (e.g., `192.168.1.100`).
4. **Generate API-Key (Username)**:
   * Go to your physical Philips Hue Bridge and press the large, round **link button** in the center.
   * Within 30 seconds, click the **Create API-Key** (API-Key erstellen) button in the widget settings.
   * The API key will be generated and automatically filled into the field.
5. Click **Apply** or **OK** at the bottom.
6. Under **Show/Hide Devices** (Geräte ein-/ausblenden), you can see the list of detected lights and check/uncheck them to customize which ones are shown in the widget.
7. (Optional) Customize the appearance under **Design & Colors** (Design & Farben) to enable custom colors or transparent background.
