import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Extras 1.4

Item {
    width: 1280
    height: 720
    state: "ROUTE_VIEWER"

    property alias loadingIndicator: loadingIndicator
    property alias mapPanel: mapPanel
    property alias myLocationBtn: myLocationBtn
    property alias loadRouteBtn: loadRouteBtn
    property alias cleanRouteBtn: cleanRouteBtn
    property alias routeInfoBtn: routeInfoBtn
    property alias routeInfoPanel: routeInfoPanel
    property alias modeSwitch: modeSwitch
    property alias recordCtrlBtn: recordCtrlBtn
    property alias saveRouteBtn: saveRouteBtn

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
                    id: recordCtrlBtn
                    iconSource: "icon/recordStart.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true
                    Layout.maximumHeight: loadRouteBtn.height
                    visible: false
                    state: "stopped"
                }

                Button {
                    id: cleanRouteBtn
                    iconSource: "icon/cleanRoute.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true
                    Layout.maximumHeight: loadRouteBtn.height
                }

                Button {
                    id: saveRouteBtn
                    iconSource: "icon/recordStop.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true
                    Layout.maximumHeight: loadRouteBtn.height
                    visible: false
                    enabled: false
                }

                ToggleButton {
                    id: routeInfoBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.maximumWidth: ctrlPanel.width/2
                    Layout.maximumHeight: loadRouteBtn.height
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Route\n  Info")
                        font.pointSize: 9
                    }
                }

                ToggleButton {
                    id: routeStatusBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.maximumWidth: ctrlPanel.width/2
                    Layout.maximumHeight: loadRouteBtn.height
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Route\nStatus")
                        font.pointSize: 9
                    }
                    visible: false
                }

                Switch {
                    id: modeSwitch
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    checked: false
                    style: SwitchStyle {
                        groove: Rectangle {
                            implicitWidth: loadRouteBtn.width/2
                            implicitHeight: loadRouteBtn.height/2
                            radius: 9
                            color: "slategray"
                            border.color: control.activeFocus ? "darkblue" : "gray"
                            border.width: 1
                        }
                        handle: Rectangle {
                            color: "red"
                            border.color: "black"
                            implicitWidth: loadRouteBtn.width/4
                            implicitHeight: loadRouteBtn.height/2
                            radius: 9
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "grey"}
                                GradientStop { position: 0.5; color: "red"}
                                GradientStop { position: 1.0; color: "grey"}
                            }
                            rotation: 90
                        }
                    }
                    Text {
                        anchors.left: parent.right
                        text: qsTr(" Recording\n Mode")
                        font.pointSize: 10
                    }
                }
            }
        }

        Rectangle {
            id: mapPanel
            color: "blue"
            Layout.fillWidth: true
            Layout.fillHeight: true

            BusyIndicator {
                id: loadingIndicator
                z: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                running: false
            }

            Column {
                id: fuelConsumptionColorTbl
                spacing: 1
                anchors.right: parent.right
                anchors.top: parent.top
                opacity: 0.5
                z: 1

                Rectangle {
                    color: "red";         width: 50; height: mapPanel.height/10
                    Text {
                        text: ">12"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Rectangle {
                    color: "maroon";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "12"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "saddlebrown";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "11"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "darkorange";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "10"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "yellow";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "9"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "greenyellow";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "8"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "green";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "7"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "springgreen";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "6"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "steelblue";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "5"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }
                }
                Rectangle {
                    color: "blue";         width: 50; height: mapPanel.height/10
                    Text {
                        text: "<5"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                id: routeInfoPanel
                color: "lightsteelblue"
                width: routeInfoGrid.width
                height: routeInfoGrid.height
                anchors.right: fuelConsumptionColorTbl.left
                y: -height
                z: 1
                opacity: 0.5

                Grid {
                    id: routeInfoGrid
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

    states: [
        State {
            name: "ROUTE_VIEWER"
            PropertyChanges { target: myLocationBtn; iconSource: "icon/myLocation.svg" }

            PropertyChanges { target: loadRouteBtn; visible: true }
            PropertyChanges { target: cleanRouteBtn; visible: true }
            PropertyChanges { target: routeInfoBtn; visible: true }
            PropertyChanges { target: routeInfoPanel; visible: true }
            PropertyChanges { target: fuelConsumptionColorTbl; visible: true }

            PropertyChanges { target: recordCtrlBtn; visible: false }
            PropertyChanges { target: saveRouteBtn; visible: false }
            PropertyChanges { target: routeStatusBtn; visible: false }
        },
        State {
            name: "RECORDING"
            PropertyChanges { target: myLocationBtn; iconSource: "icon/myDirection.png" }

            PropertyChanges { target: loadRouteBtn; visible: false }
            PropertyChanges { target: cleanRouteBtn; visible: false }
            PropertyChanges { target: routeInfoBtn; visible: false }
            PropertyChanges { target: routeInfoPanel; visible: false }
            PropertyChanges { target: fuelConsumptionColorTbl; visible: false }

            PropertyChanges { target: recordCtrlBtn; visible: true }
            PropertyChanges { target: saveRouteBtn; visible: true }
            PropertyChanges { target: routeStatusBtn; visible: true }
        }

    ]
}
