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
                mainForm.mapViewer.center = positionSource.position.coordinate
                mainForm.location.coordinate = positionSource.position.coordinate
            }
        }

        Component.onCompleted: {
            for (var i = 0; i < mapViewer.supportedMapTypes.length; i++) {
                var type = mapViewer.supportedMapTypes[i];
                if (type.style === MapType.TerrainMap) {
                    mapViewer.activeMapType = type;
                    break;
                }
            }

            location.coordinate = positionSource.position.coordinate
        }
    }
}
