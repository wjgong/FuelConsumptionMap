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
    property alias cleanRouteBtn: cleanRouteBtn
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

                Button {
                    id: cleanRouteBtn
                    iconSource: "icon/cleanRoute.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true
                    Layout.maximumHeight: loadRouteBtn.height
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

            Column {
                id: fuelConsumptionColorTbl
                spacing: 1
                anchors.right: parent.right
                anchors.top: parent.top
                opacity: 0.5

                Rectangle {
                    color: "red";         width: 50; height: 70
                    Text {
                        text: ">12"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "maroon";         width: 50; height: 70
                    Text {
                        text: "12"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "saddlebrown";         width: 50; height: 70
                    Text {
                        text: "11"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "darkorange";         width: 50; height: 70
                    Text {
                        text: "10"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "yellow";         width: 50; height: 70
                    Text {
                        text: "9"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "greenyellow";         width: 50; height: 70
                    Text {
                        text: "8"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "green";         width: 50; height: 70
                    Text {
                        text: "7"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "springgreen";         width: 50; height: 70
                    Text {
                        text: "6"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "steelblue";         width: 50; height: 70
                    Text {
                        text: "5"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "blue";         width: 50; height: 70
                    Text {
                        text: "<5"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
            }
        }
    }
}
