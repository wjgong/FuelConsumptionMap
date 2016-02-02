import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Extras 1.4

Item {
    width: 1280
    height: 720

    property alias mapPanel: mapPanel
    property alias myLocationBtn: myLocationBtn
    property alias loadRouteBtn: loadRouteBtn
    property alias cleanRouteBtn: cleanRouteBtn
    property alias routeInfoBtn: routeInfoBtn
    property alias routeInfoPanel: routeInfoPanel

    property real routeDistance: 0.0
    property real fuelConsumption: 0.0
    property real amountOfFuel: 0.0
    property real averageSpeed: 0.0

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

                ToggleButton {
                    id: routeInfoBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.maximumWidth: ctrlPanel.width/2
                    Layout.maximumHeight: loadRouteBtn.height
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Route Info")
                        font.pointSize: 9
                    }
                }
            }
        }

        Rectangle {
            id: mapPanel
            color: "blue"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                id: fuelConsumptionColorTbl
                spacing: 1
                anchors.right: parent.right
                anchors.top: parent.top
                opacity: 0.5
                z: 1

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

            Rectangle {
                id: routeInfoPanel
                color: "lightsteelblue"
                width: mapPanel.width/2
                height: mapPanel.height/4
                anchors.right: fuelConsumptionColorTbl.left
                y: -height
                z: 1
                opacity: 0.5

                Grid {
                    columns: 2
                    spacing: 3
                    anchors.top: routeInfoPanel.top
                    anchors.left: routeInfoPanel.left

                    Text {
                        id: distanceLabel
                        text: qsTr("Distance: ")
                    }
                    Text {
                        id: distanceValue
                        text: routeDistance + "km"
                    }

                    Text {
                        id: fuelConspLabel
                        text: qsTr("Fuel Consumption: ")
                    }
                    Text {
                        id: fuelConspValue
                        text: fuelConsumption + "L/100km"
                    }

                    Text {
                        id: amountFuelLabel
                        text: qsTr("The Amount of Fuel: ")
                    }
                    Text {
                        id: amountFuelValue
                        text: amountOfFuel + "L"
                    }

                    Text {
                        id: avgSpeedLabel
                        text: qsTr("Average Speed: ")
                    }
                    Text {
                        id: avgSpeedValue
                        text: averageSpeed + "km/h"
                    }
                }
            }
        }
    }
}
