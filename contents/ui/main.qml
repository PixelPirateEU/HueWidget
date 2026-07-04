import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import Qt5Compat.GraphicalEffects

PlasmoidItem {
    id: root

    // Configuration properties helper
    readonly property string bridgeIp: plasmoid.configuration.bridgeIp
    readonly property string apiKey: plasmoid.configuration.apiKey
    readonly property int pollInterval: plasmoid.configuration.pollInterval
    readonly property string hiddenLights: plasmoid.configuration.hiddenLights

    readonly property bool transparentBackground: plasmoid.configuration.transparentBackground
    readonly property bool useCustomColors: plasmoid.configuration.useCustomColors
    readonly property string colorGlow: plasmoid.configuration.colorGlow
    readonly property string colorIconOn: plasmoid.configuration.colorIconOn
    readonly property string colorIconOff: plasmoid.configuration.colorIconOff
    readonly property string colorText: plasmoid.configuration.colorText

    Plasmoid.backgroundHints: transparentBackground ? PlasmaCore.Types.NoBackground : (PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground)

    // Widget states
    property string statusText: ""
    property bool isLoading: false

    // Compact Representation (when in panel)
    compactRepresentation: Item {
        id: compactRoot
        width: Kirigami.Units.gridUnit * 2
        height: Kirigami.Units.gridUnit * 2

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: parent.height * 0.7
            radius: width / 2
            color: useCustomColors ? colorGlow : "#ffd600"
            opacity: anyLightOn() ? 0.6 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        ColorMaskIcon {
            anchors.fill: parent
            source: Qt.resolvedUrl("assets/lightbulb.svg")
            color: anyLightOn() ? (useCustomColors ? colorIconOn : "#ffd600") : (useCustomColors ? colorIconOff : Kirigami.Theme.textColor)
            opacity: anyLightOn() ? 1.0 : 0.6
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        // Return true if at least one light in model is on
        function anyLightOn() {
            for (var i = 0; i < lightsModel.count; i++) {
                if (lightsModel.get(i).isOn) {
                    return true;
                }
            }
            return false;
        }
    }

    // Full Representation (popup or on desktop)
    fullRepresentation: Item {
        id: fullRoot
        implicitWidth: Kirigami.Units.gridUnit * 20
        implicitHeight: Kirigami.Units.gridUnit * 25

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            // Header Layout
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing

                ColorMaskIcon {
                    source: Qt.resolvedUrl("assets/lightbulb.svg")
                    color: useCustomColors && colorText ? colorText : Kirigami.Theme.textColor
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    
                    PlasmaComponents.Label {
                        text: "Philips Hue Steuerung"
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                        color: useCustomColors && colorText ? colorText : Kirigami.Theme.textColor
                    }

                    PlasmaComponents.Label {
                        text: statusText
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.85
                        color: useCustomColors && colorText ? colorText : Kirigami.Theme.textColor
                        opacity: 0.7
                        visible: text !== ""
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                // Alle aus Button
                PlasmaComponents.ToolButton {
                    id: allOffBtn
                    text: "Alle aus"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    onClicked: setAllLights(false)
                    
                    contentItem: ColorMaskIcon {
                        source: Qt.resolvedUrl("assets/lightbulb.svg")
                        color: useCustomColors ? colorIconOff : "#888888"
                        opacity: allOffBtn.hovered ? 1.0 : 0.6
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                    }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: "Alle Lampen ausschalten"
                }

                // Alle an Button
                PlasmaComponents.ToolButton {
                    id: allOnBtn
                    text: "Alle an"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    onClicked: setAllLights(true)
                    
                    contentItem: ColorMaskIcon {
                        source: Qt.resolvedUrl("assets/lightbulb.svg")
                        color: useCustomColors ? colorIconOn : "#ffd600"
                        opacity: allOnBtn.hovered ? 1.0 : 0.8
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                    }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: "Alle Lampen einschalten"
                }

                // Refresh Button
                PlasmaComponents.ToolButton {
                    icon.name: "view-refresh"
                    text: "Aktualisieren"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    onClicked: getLights()
                    
                    // Simple rotation animation when loading
                    RotationAnimation on rotation {
                        running: isLoading
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        duration: 1000
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            // Main Content Area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Info state if setup is missing or empty
                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    spacing: Kirigami.Units.largeSpacing
                    visible: lightsModel.count === 0 && !isLoading

                    Kirigami.Icon {
                        source: "preferences-system-network"
                        Layout.alignment: Qt.AlignHCenter
                        width: Kirigami.Units.iconSizes.large
                        height: Kirigami.Units.iconSizes.large
                        opacity: 0.5
                    }

                    PlasmaComponents.Label {
                        text: (!bridgeIp || !apiKey) 
                              ? "IP-Adresse oder API-Key fehlt.\nBitte konfigurieren Sie das Widget in den Einstellungen." 
                              : "Verbindung zur Hue Bridge wird aufgebaut..."
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        opacity: 0.8
                    }
                }

                // Loading Indicator
                PlasmaComponents.BusyIndicator {
                    anchors.centerIn: parent
                    running: isLoading && lightsModel.count === 0
                }

                // Scrollable List of lights
                ScrollView {
                    anchors.fill: parent
                    visible: lightsModel.count > 0
                    clip: true

                    ListView {
                        id: listView
                        model: lightsModel
                        spacing: Kirigami.Units.smallSpacing

                        delegate: Rectangle {
                            id: delegateRoot
                            width: listView.width
                            height: delegateColumn.implicitHeight + Kirigami.Units.largeSpacing * 2
                            color: "transparent"
                            
                            Rectangle {
                                anchors.fill: parent
                                color: Kirigami.Theme.hoverColor
                                opacity: hoverHandler.hovered ? 0.08 : 0
                                radius: Kirigami.Units.smallSpacing
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                            
                            HoverHandler {
                                id: hoverHandler
                            }

                            ColumnLayout {
                                id: delegateColumn
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: Kirigami.Units.largeSpacing
                                }
                                spacing: Kirigami.Units.smallSpacing

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.largeSpacing

                                    // Glow Icon
                                    Item {
                                        width: Kirigami.Units.iconSizes.medium
                                        height: Kirigami.Units.iconSizes.medium

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.width * 0.8
                                            height: parent.height * 0.8
                                            radius: width / 2
                                            color: useCustomColors ? colorGlow : "#ffd600"
                                            opacity: model.isOn ? (model.bri / 254.0) * 0.6 + 0.4 : 0.0
                                            Behavior on opacity { NumberAnimation { duration: 250 } }
                                        }

                                        ColorMaskIcon {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("assets/lightbulb.svg")
                                            color: model.isOn ? (useCustomColors ? colorIconOn : "#ffd600") : (useCustomColors ? colorIconOff : Kirigami.Theme.textColor)
                                            opacity: model.isOn ? 1.0 : 0.4
                                            Behavior on opacity { NumberAnimation { duration: 250 } }
                                        }
                                    }

                                    // Light Name & Room
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        PlasmaComponents.Label {
                                            text: model.name
                                            font.bold: true
                                            color: useCustomColors && colorText ? colorText : Kirigami.Theme.textColor
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        PlasmaComponents.Label {
                                            text: model.isOn ? "An - " + Math.round((model.bri / 254) * 100) + "%" : "Aus"
                                            font.pointSize: font.pointSize * 0.85
                                            color: useCustomColors && colorText ? colorText : Kirigami.Theme.textColor
                                            opacity: 0.6
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // Toggle Switch
                                    PlasmaComponents.Switch {
                                        id: stateSwitch
                                        checked: model.isOn
                                        
                                        Binding on checked {
                                            value: model.isOn
                                            when: !stateSwitch.pressed
                                        }
                                        
                                        onToggled: {
                                            toggleLight(model.lightId, checked);
                                        }
                                    }
                                }

                                // Brightness Slider (collapses if off)
                                RowLayout {
                                    Layout.fillWidth: true
                                    visible: model.isOn
                                    spacing: Kirigami.Units.largeSpacing

                                    ColorMaskIcon {
                                        source: Qt.resolvedUrl("assets/brightness-low.svg")
                                        color: useCustomColors && colorText ? colorText : Kirigami.Theme.textColor
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                        opacity: 0.5
                                    }

                                    PlasmaComponents.Slider {
                                        id: briSlider
                                        Layout.fillWidth: true
                                        from: 1
                                        to: 254
                                        
                                        Binding on value {
                                            value: model.bri
                                            when: !briSlider.pressed
                                        }

                                        onMoved: {
                                            setBrightness(model.lightId, value);
                                        }
                                    }

                                    ColorMaskIcon {
                                        source: Qt.resolvedUrl("assets/brightness-high.svg")
                                        color: useCustomColors && colorText ? colorText : Kirigami.Theme.textColor
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                        opacity: 0.8
                                    }
                                }

                                Kirigami.Separator {
                                    Layout.fillWidth: true
                                    opacity: 0.2
                                    Layout.topMargin: Kirigami.Units.smallSpacing
                                }
                            }
                        }
                    }
                }
            }


        }

        // Fetch lights status when widget full view is shown
        Component.onCompleted: {
            getLights();
        }
    }

    // Lights Model
    ListModel {
        id: lightsModel
    }

    // Polling Timer
    Timer {
        id: pollTimer
        interval: Math.max(2, pollInterval) * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getLights();
        }
    }

    // Re-fetch when config variables change
    onBridgeIpChanged: getLights()
    onApiKeyChanged: getLights()
    onHiddenLightsChanged: getLights()

    // ==========================================
    // REST API Functions
    // ==========================================

    function getLights() {
        if (!bridgeIp || !apiKey) {
            statusText = "Setup unvollständig";
            return;
        }

        isLoading = true;
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://" + bridgeIp + "/api/" + apiKey + "/lights");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false;
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        
                        // Check if Hue Bridge returned an API error array
                        if (Array.isArray(response) && response.length > 0 && response[0].error) {
                            statusText = "API-Fehler: " + response[0].error.description;
                            lightsModel.clear();
                        } else {
                            statusText = "";
                            updateLightsModel(response);
                        }
                    } catch (e) {
                        statusText = "Ungültige Antwort von Bridge";
                    }
                } else {
                    statusText = "Verbindungsfehler (" + xhr.status + ")";
                }
            }
        };
        xhr.send();
    }

    function isLightHidden(id) {
        var hidden = (hiddenLights || "").split(",").filter(function(x) { return x.trim() !== ""; });
        return hidden.indexOf(String(id)) !== -1;
    }

    function updateLightsModel(response) {
        var keys = Object.keys(response);
        var existing = {};
        
        for (var i = 0; i < lightsModel.count; i++) {
            var item = lightsModel.get(i);
            existing[item.lightId] = i;
        }

        for (var j = 0; j < keys.length; j++) {
            var id = keys[j];
            if (isLightHidden(id)) {
                continue;
            }
            var light = response[id];
            var name = light.name || "Lampe " + id;
            var isOn = !!(light.state && light.state.on);
            var bri = (light.state && light.state.bri !== undefined) ? light.state.bri : 254;

            if (existing.hasOwnProperty(id)) {
                var index = existing[id];
                lightsModel.setProperty(index, "name", name);
                lightsModel.setProperty(index, "isOn", isOn);
                lightsModel.setProperty(index, "bri", bri);
                delete existing[id];
            } else {
                lightsModel.append({
                    "lightId": id,
                    "name": name,
                    "isOn": isOn,
                    "bri": bri
                });
            }
        }

        // Clean up removed lights
        var toRemove = Object.values(existing).sort(function(a, b) { return b - a; });
        for (var k = 0; k < toRemove.length; k++) {
            lightsModel.remove(toRemove[k]);
        }
    }

    function toggleLight(id, isOn) {
        if (!bridgeIp || !apiKey) return;

        // Optimistically update model state for snappy UI feel
        for (var i = 0; i < lightsModel.count; i++) {
            if (lightsModel.get(i).lightId === id) {
                lightsModel.setProperty(i, "isOn", isOn);
                break;
            }
        }

        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "http://" + bridgeIp + "/api/" + apiKey + "/lights/" + id + "/state");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) {
                    statusText = "Fehler beim Schalten (" + id + ")";
                    // Revert state on error by fetching again
                    getLights();
                }
            }
        };
        xhr.send(JSON.stringify({ "on": isOn }));
    }

    function setBrightness(id, value) {
        if (!bridgeIp || !apiKey) return;

        var targetBri = Math.max(1, Math.min(254, Math.round(value)));

        // Optimistically update model state
        for (var i = 0; i < lightsModel.count; i++) {
            if (lightsModel.get(i).lightId === id) {
                lightsModel.setProperty(i, "bri", targetBri);
                break;
            }
        }

        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "http://" + bridgeIp + "/api/" + apiKey + "/lights/" + id + "/state");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) {
                    statusText = "Fehler bei Helligkeit (" + id + ")";
                    getLights();
                }
            }
        };
        xhr.send(JSON.stringify({ "bri": targetBri }));
    }

    function setAllLights(isOn) {
        if (!bridgeIp || !apiKey) return;

        // Loop through all lights in local model and trigger request for each
        for (var i = 0; i < lightsModel.count; i++) {
            var lightId = lightsModel.get(i).lightId;
            toggleLight(lightId, isOn);
        }
    }
}
