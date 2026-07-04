import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property alias source: img.source
    property color color: "white"

    implicitWidth: 24
    implicitHeight: 24

    Image {
        id: img
        anchors.fill: parent
        visible: false
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
    }

    ColorOverlay {
        anchors.fill: img
        source: img
        color: root.color
    }
}
