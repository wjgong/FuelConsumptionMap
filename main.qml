import QtQuick 2.5
import QtQuick.Controls 1.4
import QtPositioning 5.6
import QtLocation 5.6
import QtQuick.Dialogs 1.2
import QtQuick.XmlListModel 2.0
import QtQml 2.2

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
                mainForm.myLocation.coordinate =
                        positionSource.position.coordinate
            }
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

        XmlListModel {
            id: routeModel
            namespaceDeclarations: "declare default element namespace 'http://www.topografix.com/GPX/1/1';"
            query: "/gpx/trk/trkseg/trkpt"

            XmlRole { name: "lat";  query: "@lat/number()" }
            XmlRole { name: "lon";  query: "@lon/number()" }
            XmlRole { name: "ele";  query: "ele/number()" }

            onStatusChanged: {
                switch(status) {
                case XmlListModel.Loading:
                    console.log("loading coordinates...");
                    break;

                case XmlListModel.Ready:
                    console.log("display the route on the map", count);
                    mainForm.removeRouteByFuel();
                    mainForm.renderRouteByFuel();
                    break;

                case XmlListModel.Error:
                    console.log("xml loading error: ", errorString());
                    break;
                }
            }
        }

        Component.onCompleted: {
            for (var i = 0, l = mapViewer.supportedMapTypes.length; i < l; i ++) {
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

        loadRouteBtn.onClicked: fileDialog.open()

        cleanRouteBtn.onClicked: removeRouteByFuel()

        function parseGpx(fileUrl) {
            console.log("parsing gpx file url: ", fileUrl);
            routeModel.source = fileUrl;
        }

        function paintRoute() {
            for (var i = 0, l = routeModel.count; i < l; i ++) {
                //                console.log("(" + get(i).lat + ", " + get(i).lon + ", " + get(i).ele + ")");
                var coordinate = QtPositioning.coordinate(routeModel.get(i).lat,
                                                          routeModel.get(i).lon,
                                                          routeModel.get(i).ele);
                routePolyline.addCoordinate(coordinate);
            }
            routePolyline.visible = true;
            mapViewer.fitViewportToMapItems();
        }

        function cleanRoute() {
            routePolyline.visible = false;
            var path = routePolyline.path;
            path = [];
            routePolyline.path = path;
        }

        function renderRouteByFuel() {
            var subRoutes = [];
            var j = 0;
            var fuel = routeModel.get(0).ele
            console.log("fuel " + fuel);
            subRoutes[0] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 3}', mapViewer);
            for (var i = 0, l = routeModel.count; i < l; i ++) {
                var routePoint = routeModel.get(i);
                if (fuel !== routePoint.ele) {
                    var coordinate = QtPositioning.coordinate(routePoint.lat,
                                                              routePoint.lon,
                                                              routePoint.ele);
                    subRoutes[j].addCoordinate(coordinate);
                    console.log("subRoute " + j + " point count " + subRoutes[j].pathLength());
                    fuel = routePoint.ele;
                    console.log("fuel " + fuel);

                    subRoutes[++j] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 3}',
                                                        mapViewer);
                }
                coordinate = QtPositioning.coordinate(routePoint.lat,
                                                      routePoint.lon,
                                                      routePoint.ele);
                subRoutes[j].addCoordinate(coordinate);
            }

            console.log("subRoutes.length: " + subRoutes.length);
            for (i = 0, l = subRoutes.length; i < l; i ++) {
                var subRoute = subRoutes[i];
                subRoute.line.width = 3;
                subRoute.line.color = mappingColor(subRoute.path[0].altitude);
                mapViewer.addMapItem(subRoute);
                subRoute.visible = true;
            }

            mapViewer.fitViewportToMapItems();
        }

        function mappingColor(fuel) {
            var colors = ["blue", "steelblue", "springgreen", "green",
                          "greenyellow", "yellow", "darkorange", "saddlebrown",
                          "maroon", "red"];
            return colors[fuel % 10];
        }

        function removeRouteByFuel() {
            mapViewer.clearMapItems();
            mapViewer.addMapItem(myLocation);
        }
    }
}
