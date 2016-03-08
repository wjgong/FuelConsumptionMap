import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Extras 1.4

Item {
    id: rootItem
    width: 1280
    height: 720
    state: "ROUTE_VIEWER"

    property alias loadingIndicator: loadingIndicator
    property alias mapPanel: mapPanel
    property alias myLocationBtn: myLocationBtn
    property alias loadRouteBtn: loadRouteBtn
    property alias cleanRouteBtn: cleanRouteBtn
    property alias routeInfoSwitch: routeInfoSwitch
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
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: ctrlPanel
            color: 'black'
            width: rootItem.width/6
            height: rootItem.height

            Column {
                id: ctrlPanelLayout
                spacing: 0

                anchors.fill: parent

                Button {
                    id: myLocationBtn
                    width: parent.width
                    height: parent.height/5

                    style: ButtonStyle {
                        background: Rectangle {
                            color: "black"
                            border.color: "gray"
                            border.width: 3
                        }

                        label: Text {
                            text: qsTr("Locate")
                            color: "white"
                            font.bold: true
                            font.pointSize: 20
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Button {
                    id: loadRouteBtn
                    width: parent.width
                    height: parent.height/5

                    style: ButtonStyle {
                        background: Rectangle {
                            color: "black"
                            border.color: "gray"
                            border.width: 3
                        }

                        label: Text {
                            text: qsTr("Load\nRoute")
                            color: "white"
                            font.bold: true
                            font.pointSize: 20
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Button {
                    id: cleanRouteBtn
                    width: parent.width
                    height: parent.height/5

                    style: ButtonStyle {
                        background: Rectangle {
                            color: "black"
                            border.color: "gray"
                            border.width: 3
                        }

                        label: Text {
                            text: qsTr("Remove\nRoute")
                            color: "white"
                            font.bold: true
                            font.pointSize: 20
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Switch {
                    id: routeInfoSwitch
                    width: parent.width
                    height: parent.height/5
                    checked: false
                    style: SwitchStyle {
                        padding.top: -8
                        padding.bottom: -8
                        groove: Rectangle {
                            width: control.width-40
                            height: control.height/3
                            x: 20
                            color: control.checked ? "yellow" : "black"
                            border.color: "white"
                            border.width: 4
                        }
                        handle: Rectangle {
                            color: "white"
                            border.color: "black"
                            border.width: 4
                            width: control.width/4
                            x: 20
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        border.color: "gray"
                        border.width: 3
                        z: -1
                    }
                    Text {
                        text: qsTr("Route Info")
                        x: 20
                        color: "white"
                        font.pointSize: 13
                        font.bold: true
                        z: 1
                    }
                }

                Switch {
                    id: modeSwitch
                    width: parent.width
                    height: parent.height/5
                    checked: false
                    style: SwitchStyle {
                        padding.top: -8
                        padding.bottom: -8
                        groove: Rectangle {
                            width: control.width-40
                            height: control.height/3
                            x: 20
                            color: control.checked ? "yellow" : "black"
                            border.color: "white"
                            border.width: 4
                        }
                        handle: Rectangle {
                            color: "white"
                            border.color: "black"
                            border.width: 4
                            width: control.width/4
                            x: 20
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        border.color: "gray"
                        border.width: 3
                        z: -1
                    }
                    Text {
                        text: qsTr("Recording Mode")
                        x: 20
                        color: "white"
                        font.pointSize: 13
                        font.bold: true
                        z: 1
                    }
                }

                Button {
                    id: recordCtrlBtn
                    iconSource: "icon/recordStart.png"
                    width: parent.width
                    height: parent.height/5
                    visible: false
                    state: "stopped"
                }

                Button {
                    id: saveRouteBtn
                    iconSource: "icon/recordStop.png"
                    width: parent.width
                    height: parent.height/5
                    visible: false
                    enabled: false
                }

                //                ToggleButton {
                //                    id: routeInfoBtn
                //                    anchors.horizontalCenter: parent.horizontalCenter
                //                    Layout.maximumWidth: ctrlPanel.width/2
                //                    Layout.maximumHeight: loadRouteBtn.height
                //                    Text {
                //                        anchors.centerIn: parent
                //                        text: qsTr("Route\n  Info")
                //                        font.pointSize: 9
                //                    }
                //                }

                ToggleButton {
                    id: routeStatusBtn
                    width: parent.width
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Route\nStatus")
                        font.pointSize: 9
                    }
                    visible: false
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
            //            PropertyChanges { target: myLocationBtn; iconSource: "icon/myLocation.svg" }

            PropertyChanges { target: loadRouteBtn; visible: true }
            PropertyChanges { target: cleanRouteBtn; visible: true }
            PropertyChanges { target: routeInfoSwitch; visible: true }
            PropertyChanges { target: routeInfoPanel; visible: true }
            PropertyChanges { target: fuelConsumptionColorTbl; visible: true }

            PropertyChanges { target: recordCtrlBtn; visible: false }
            PropertyChanges { target: saveRouteBtn; visible: false }
            PropertyChanges { target: routeStatusBtn; visible: false }
        },
        State {
            name: "RECORDING"
            //            PropertyChanges { target: myLocationBtn; iconSource: "icon/myDirection.png" }

            PropertyChanges { target: loadRouteBtn; visible: false }
            PropertyChanges { target: cleanRouteBtn; visible: false }
            PropertyChanges { target: routeInfoSwitch; visible: false }
            PropertyChanges { target: routeInfoPanel; visible: false }
            PropertyChanges { target: fuelConsumptionColorTbl; visible: false }

            PropertyChanges { target: recordCtrlBtn; visible: true }
            PropertyChanges { target: saveRouteBtn; visible: true }
            PropertyChanges { target: routeStatusBtn; visible: true }
        }

    ]
}
