import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtPositioning 5.5
import QtLocation 5.5

Item {
    width: 1280
    height: 720

    property alias mapViewer: mapViewer
    property alias location: location

    Plugin {
        id: osmPlugin
        name: "osm"
    }

    Map {
        id: mapViewer
        anchors.fill: parent
        plugin: osmPlugin
        zoomLevel: 13

        gesture.enabled: true
        gesture.activeGestures: MapGestureArea.ZoomGesture | MapGestureArea.PanGesture
        MouseArea {
            anchors.fill: parent
        }

        MapQuickItem {
            id: location
            sourceItem: Image {
                source: "icon/location.svg"
            }
            scale: 2
            antialiasing: true
        }
    }
}
