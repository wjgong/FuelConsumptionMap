import QtQuick 2.5
import QtQuick.Controls 1.4
import QtPositioning 5.5
import QtLocation 5.5
import QtQuick.Dialogs 1.2
import QtQuick.XmlListModel 2.0

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
                mainForm.myLocation.coordinate = positionSource.position.coordinate
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

            myLocation.coordinate = positionSource.position.coordinate
            mapViewer.center = positionSource.position.coordinate
        }

        myLocationBtn.onClicked: PropertyAnimation {
            target: mainForm.mapViewer
            property: "center"
            to: positionSource.position.coordinate
        }

        XmlListModel {
            id: routeModel
            query: "/gpx/trk/trkseg/trkpt"

            XmlRole { name: "lat";  query: "@lat/string()" }
            XmlRole { name: "lon";  query: "@lon/string()" }
            XmlRole { name: "ele";  query: "ele/number()" }

            onStatusChanged: {
                if (status === XmlListModel.Ready) {
                    console.log("display the route on the map", count);
                    for (var i = 0; i < routeModel.count; i ++) {
                        console.log(routeModel.get(i).ele);
                    }
                }

                if (status == XmlListModel.Error) {
                    console.log("xml loading error: ", errorString());
                }
            }
        }

        function parseGpx(fileUrl) {
            console.log("parsing gpx file url: ", fileUrl);
            routeModel.source = fileUrl;
        }

        FileDialog {
            id: fileDialog
            title: qsTr("Choose a route file")
            nameFilters: ["GPS files (*.gpx)"]
            folder: shortcuts.documents

            width: mainForm.width

            onAccepted: {
                mainForm.parseGpx(fileUrl)
            }
        }

        loadRouteBtn.onClicked: fileDialog.open()
    }
}
