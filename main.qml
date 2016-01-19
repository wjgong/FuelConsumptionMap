import QtQuick 2.5
import QtQuick.Controls 1.4
import QtPositioning 5.5
import QtLocation 5.5

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: qsTr("Fuel Consumption Map")

    MainForm {
        id: mainForm
        anchors.fill: parent

        PositionSource {
            id: positionSource
            active: true
            updateInterval: 120000 // 2 mins
            onPositionChanged:  {
                var currentPosition = positionSource.position.coordinate
                mainForm.mapViewer.center = currentPosition
            }
        }
    }
}
