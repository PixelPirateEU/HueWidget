import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configPage

    property alias cfg_bridgeIp: bridgeIpField.text
    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_pollInterval: pollIntervalSpinner.value
    property alias cfg_hiddenLights: hiddenLightsField.text

    property alias cfg_transparentBackground: transparentBackgroundCheck.checked
    property alias cfg_useCustomColors: useCustomColorsCheck.checked
    property alias cfg_colorGlow: colorGlowField.text
    property alias cfg_colorIconOn: colorIconOnField.text
    property alias cfg_colorIconOff: colorIconOffField.text
    property alias cfg_colorText: colorTextField.text

    property string regStatus: ""
    property bool regLoading: false

    property string devicesStatus: ""
    readonly property alias devicesModel: devicesModel

    onCfg_bridgeIpChanged: fetchDevices()
    onCfg_apiKeyChanged: fetchDevices()

    // Hidden config inputs for custom tracking
    TextField { id: hiddenLightsField; visible: false }
    TextField { id: colorGlowField; visible: false }
    TextField { id: colorIconOnField; visible: false }
    TextField { id: colorIconOffField; visible: false }
    TextField { id: colorTextField; visible: false }

    TextField {
        id: bridgeIpField
        Kirigami.FormData.label: i18n("Bridge IP-Adresse:")
        placeholderText: "z.B. 192.168.1.100"
        Layout.fillWidth: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("API-Key (Username):")
        Layout.fillWidth: true

        TextField {
            id: apiKeyField
            placeholderText: "Ihr Hue API-Key"
            echoMode: TextInput.PasswordEchoOnEdit
            Layout.fillWidth: true
        }

        Button {
            text: i18n("API-Key erstellen")
            enabled: bridgeIpField.text !== "" && !regLoading
            onClicked: requestApiKey()
        }
    }

    // Helper text for registration status
    Label {
        text: regStatus
        visible: regStatus !== ""
        color: regStatus.indexOf("Erfolgreich") !== -1 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.neutralTextColor
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
    }

    SpinBox {
        id: pollIntervalSpinner
        Kirigami.FormData.label: i18n("Aktualisierungsintervall (Sekunden):")
        from: 2
        to: 120
        stepSize: 1
    }

    // Design & Colors Section
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Design & Farben")
    }

    CheckBox {
        id: transparentBackgroundCheck
        Kirigami.FormData.label: i18n("Hintergrund:")
        text: i18n("Widget-Hintergrund transparent machen")
    }

    CheckBox {
        id: useCustomColorsCheck
        Kirigami.FormData.label: i18n("Farben:")
        text: i18n("Benutzerdefinierte Farben aktivieren")
    }

    ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        Layout.fillWidth: true
        visible: useCustomColorsCheck.checked
        Layout.leftMargin: Kirigami.Units.gridUnit

        // Glow Color
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: i18n("Leucht-Glow (Lampe an):")
                Layout.fillWidth: true
            }
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: colorGlowField.text || "#ffd600"
                border.width: 1
                border.color: Kirigami.Theme.textColor
            }
            Button {
                text: i18n("Wählen...")
                onClicked: {
                    colorDialog.targetField = colorGlowField
                    colorDialog.selectedColor = colorGlowField.text || "#ffd600"
                    colorDialog.open()
                }
            }
        }

        // Active Icon Color
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: i18n("Glühbirne (Lampe an):")
                Layout.fillWidth: true
            }
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: colorIconOnField.text || "#ffd600"
                border.width: 1
                border.color: Kirigami.Theme.textColor
            }
            Button {
                text: i18n("Wählen...")
                onClicked: {
                    colorDialog.targetField = colorIconOnField
                    colorDialog.selectedColor = colorIconOnField.text || "#ffd600"
                    colorDialog.open()
                }
            }
        }

        // Inactive Icon Color
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: i18n("Glühbirne (Lampe aus):")
                Layout.fillWidth: true
            }
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: colorIconOffField.text || "#888888"
                border.width: 1
                border.color: Kirigami.Theme.textColor
            }
            Button {
                text: i18n("Wählen...")
                onClicked: {
                    colorDialog.targetField = colorIconOffField
                    colorDialog.selectedColor = colorIconOffField.text || "#888888"
                    colorDialog.open()
                }
            }
        }

        // Text Color
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: i18n("Textfarbe (Namen/Status):")
                Layout.fillWidth: true
            }
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: colorTextField.text || Kirigami.Theme.textColor
                border.width: 1
                border.color: Kirigami.Theme.textColor
            }
            Button {
                text: i18n("Wählen...")
                onClicked: {
                    colorDialog.targetField = colorTextField
                    colorDialog.selectedColor = colorTextField.text || Kirigami.Theme.textColor
                    colorDialog.open()
                }
            }
            Button {
                text: i18n("Zurücksetzen")
                visible: colorTextField.text !== ""
                onClicked: {
                    colorTextField.text = ""
                }
            }
        }
    }

    // Devices Section
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Geräte ein-/ausblenden")
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            text: i18n("Wählen Sie aus, welche Lampen im Widget sichtbar sein sollen:")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            opacity: 0.8
        }
        Button {
            icon.name: "view-refresh"
            text: i18n("Laden")
            onClicked: fetchDevices()
        }
    }

    Label {
        text: devicesStatus
        visible: devicesStatus !== ""
        font.italic: true
        opacity: 0.7
        Layout.fillWidth: true
    }

    ColumnLayout {
        Layout.fillWidth: true
        implicitHeight: devicesListView.visible ? devicesListView.implicitHeight : 0

        ListView {
            id: devicesListView
            Layout.fillWidth: true
            implicitHeight: Math.min(Kirigami.Units.gridUnit * 10, contentHeight)
            visible: devicesModel.count > 0
            clip: true
            model: devicesModel
            spacing: Kirigami.Units.smallSpacing

            delegate: CheckBox {
                text: model.name
                
                checked: {
                    var dummy = cfg_hiddenLights;
                    return !isLightHidden(model.lightId);
                }
                
                onToggled: {
                    setLightVisibility(model.lightId, checked);
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }

    ListModel {
        id: devicesModel
    }

    ColorDialog {
        id: colorDialog
        title: i18n("Farbe wählen")
        property var targetField: null
        onAccepted: {
            if (targetField) {
                targetField.text = selectedColor;
            }
        }
    }

    function isLightHidden(id) {
        var hidden = cfg_hiddenLights.split(",").filter(function(x) { return x.trim() !== ""; });
        return hidden.indexOf(String(id)) !== -1;
    }

    function setLightVisibility(id, isVisible) {
        var idStr = String(id);
        var hidden = cfg_hiddenLights.split(",").filter(function(x) { return x.trim() !== ""; });
        var index = hidden.indexOf(idStr);
        
        if (isVisible) {
            if (index !== -1) {
                hidden.splice(index, 1);
            }
        } else {
            if (index === -1) {
                hidden.push(idStr);
            }
        }
        cfg_hiddenLights = hidden.join(",");
    }

    function fetchDevices() {
        var ip = bridgeIpField.text.trim();
        var key = apiKeyField.text.trim();
        if (!ip || !key) {
            devicesStatus = "Konfigurieren Sie IP und API-Key, um Geräte anzuzeigen.";
            devicesModel.clear();
            return;
        }

        devicesStatus = "Geräte werden geladen...";
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://" + ip + "/api/" + key + "/lights");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (Array.isArray(response) && response.length > 0 && response[0].error) {
                            devicesStatus = "Fehler: " + response[0].error.description;
                            devicesModel.clear();
                        } else {
                            devicesStatus = "";
                            devicesModel.clear();
                            var keys = Object.keys(response);
                            for (var i = 0; i < keys.length; i++) {
                                var id = keys[i];
                                var light = response[id];
                                devicesModel.append({
                                    "lightId": id,
                                    "name": light.name || "Lampe " + id
                                });
                            }
                            if (keys.length === 0) {
                                devicesStatus = "Keine Lampen gefunden.";
                            }
                        }
                    } catch (e) {
                        devicesStatus = "Fehler beim Lesen der Antwort.";
                        devicesModel.clear();
                    }
                } else {
                    devicesStatus = "Keine Verbindung zur Bridge.";
                    devicesModel.clear();
                }
            }
        };
        xhr.send();
    }

    function requestApiKey() {
        var ip = bridgeIpField.text.trim();
        if (!ip) {
            regStatus = "Bitte zuerst IP-Adresse eingeben.";
            return;
        }

        regStatus = "Verbindung wird aufgebaut...";
        regLoading = true;

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://" + ip + "/api");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                regLoading = false;
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (Array.isArray(response) && response.length > 0) {
                            var item = response[0];
                            if (item.error) {
                                if (item.error.type === 101) {
                                    regStatus = "Link-Button nicht gedrückt. Bitte drücken Sie den runden Button auf der Bridge und versuchen Sie es noch einmal.";
                                } else {
                                    regStatus = "Fehler: " + item.error.description;
                                }
                            } else if (item.success && item.success.username) {
                                apiKeyField.text = item.success.username;
                                regStatus = "Erfolgreich verbunden! API-Key wurde eingetragen. Bitte klicken Sie unten auf 'Anwenden' oder 'OK'.";
                                fetchDevices();
                            } else {
                                regStatus = "Unerwartete Antwort erhalten.";
                            }
                        } else {
                            regStatus = "Unerwartetes Antwortformat.";
                        }
                    } catch (e) {
                        regStatus = "Fehler beim Lesen der Antwort.";
                    }
                } else {
                    regStatus = "Verbindung fehlgeschlagen (Status: " + xhr.status + "). Ist die IP-Adresse korrekt?";
                }
            }
        };
        
        xhr.send(JSON.stringify({
            "devicetype": "kde_plasma_widget#hue_control"
        }));
    }
}
