import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtPositioning 5.6
import QtLocation 5.6

Item {
    width: 1280
    height: 720

    property alias mapViewer: mapViewer
    property alias myLocation: myLocation
    property alias myLocationBtn: myLocationBtn
    property alias loadRouteBtn: loadRouteBtn
    property alias routePolyline: routePolyline

    RowLayout {
        id: mainLayout
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        anchors.fill: parent
        spacing: 6

        Rectangle {
            id: ctrlPanel
            color: 'lightsteelblue'
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 200

            ColumnLayout {
                id: ctrlPanelLayout
                anchors.rightMargin: 5
                anchors.leftMargin: 5
                anchors.bottomMargin: 5
                anchors.topMargin: 5
                anchors.fill: parent

                Button {
                    id: myLocationBtn
                    iconSource: "icon/myLocation.svg"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true
                }

                Button {
                    id: loadRouteBtn
                    iconSource: "icon/routes.svg"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true
                }
            }
        }

        Rectangle {
            id:mapPanel
            color: 'blue'
            Layout.fillWidth: true
            Layout.fillHeight: true

            Map {
                id: mapViewer
                anchors.fill: parent
                plugin: Plugin {
                    name: "osm"
                }
                zoomLevel: 13

                gesture.enabled: true
                gesture.acceptedGestures: MapGestureArea.PinchGesture | MapGestureArea.PanGesture | MapGestureArea.FlickGesture
                gesture.flickDeceleration: 3000

                MapQuickItem {
                    id: myLocation
                    sourceItem: Image {
                        source: "icon/myLocation.svg"
                    }
                    antialiasing: true
                }

                MapPolyline {
                    id: routePolyline
                    line.width: 3
                    line.color: 'green'
                }
            }
        }
    }
}
