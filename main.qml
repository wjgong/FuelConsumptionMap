import QtQuick 2.5
import QtQuick.Controls 1.4
import QtPositioning 5.6
import QtLocation 5.6
import QtSensors 5.3
import QtQuick.Dialogs 1.2
import QtQuick.XmlListModel 2.0
import QtQml 2.2
import tieto.project.fuelmap 1.0

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
                var coordinate = position.coordinate;
                mapViewer.myLocation.coordinate = coordinate;

                mapViewer.myDirection.coordinate = coordinate;
                if (mapViewer.state === "DIRECTION"
                        && mainForm.recordCtrlBtn.state === "recording") {
                    var currentDateTime = new Date();
                    mapViewer.routePolyline.addCoordinate(coordinate);
                    mainForm.writeGpxFile(positionSource.position);
                }
            }
        }

        Compass {
            id: compass
            active: true

            property double azimuth: 0

            onReadingChanged: {
                if (mapViewer.state === "DIRECTION") {
                    mapViewer.myDirection.rotation = reading.azimuth + 45;
                }
            }
        }

        FileDialog {
            id: fileDialog
            title: qsTr("Choose a route file")
            nameFilters: [qsTr("GPS files (*.gpx)")]
            folder: shortcuts.documents

            width: mainForm.width

            onAccepted: {
                mainForm.loadingIndicator.running = true;
                mainForm.parseGpx(fileUrl);
            }
        }

        XmlListModel {
            id: routeModel
            namespaceDeclarations: "declare default element namespace 'http://www.topografix.com/GPX/1/1';"
            query: "/gpx/trk/trkseg/trkpt"

            XmlRole { name: "lat";  query: "@lat/number()" }
            XmlRole { name: "lon";  query: "@lon/number()" }
            XmlRole { name: "ele";  query: "ele/number()" }
            XmlRole { name: "time"; query: "time/string()"}

            onStatusChanged: {
                switch(status) {
                case XmlListModel.Loading:
                    console.log("loading coordinates...");
                    break;

                case XmlListModel.Ready:
                    console.log("display the route on the map", count);
                    mainForm.calculateRouteInfo(routeModel);
                    mainForm.removeRouteByFuel();
                    mainForm.renderRouteByFuel();
                    mainForm.loadingIndicator.running = false;
                    break;

                case XmlListModel.Error:
                    console.log("xml loading error: ", errorString());
                    break;
                }
            }
        }

        MapComponet {
            id: mapViewer
            parent: mainForm.mapPanel
        }

        Component.onCompleted: {
            for (var i = 0, l = mapViewer.supportedMapTypes.length; i < l; i ++) {
                var type = mapViewer.supportedMapTypes[i];
                if (type.style === MapType.TerrainMap) {
                    mapViewer.activeMapType = type;
                    break;
                }
            }

            var coordinate = positionSource.position.coordinate;
            mapViewer.myLocation.coordinate = coordinate;
            mapViewer.myDirection.coordinate = coordinate;
            mapViewer.center = coordinate;
        }

        myLocationBtn.onClicked: PropertyAnimation {
            target: mapViewer
            property: "center"
            to: positionSource.position.coordinate
        }

        loadRouteBtn.onClicked: fileDialog.open()

        cleanRouteBtn.onClicked: {
            resetRouteInfo();
            removeRouteByFuel();
        }

        recordCtrlBtn.onClicked: processRecordCtrlBtnState()

        saveRouteBtn.onClicked: processSaveRouteBtnState()

        routeInfoBtn.onClicked: showRouteInfoPanel(routeInfoBtn.checked)

        modeSwitch.onCheckedChanged: {
            if (modeSwitch.checked === false) {
                console.log("state from RECORDING to ROUTE_VIEWER");
                mainForm.state = "ROUTE_VIEWER";
                mapViewer.state = "LOCATION";
            } else {
                console.log("state from ROUTE_VIEWER to RECORDING");
                mainForm.state = "RECORDING";
                mapViewer.state = "DIRECTION";
            }
        }

        PropertyAnimation {
            id: showRouteInfoPanelAni
            target: mainForm.routeInfoPanel
            property: "y"
            to: 0
            easing.type: Easing.OutQuad
        }

        PropertyAnimation {
            id: hideRouteInfoPanelAni
            target: mainForm.routeInfoPanel
            property: "y"
            to: -mainForm.routeInfoPanel.height
            easing.type: Easing.OutQuad
        }

        RotationAnimator {
            id: rotateLoadingIndicator
            target: mainForm.loadingIndicator
            running: mainForm.loadingIndicator.running
            loops: Animation.Infinite
            duration: 1000
            from: 0; to : 360
        }

        function parseGpx(fileUrl) {
            console.log("parsing gpx file url: ", fileUrl);
            routeModel.source = fileUrl;
        }

        function resetRouteInfo() {
            routeDistance   = 0.0;
            fuelConsumption = 0.0;
            amountOfFuel    = 0.0;
            averageSpeed    = 0.0;
        }

        function calculateRouteInfo(routeGpxModel) {
            var startPoint;
            var endPoint;

            routeDistance = 0;
            var length = routeGpxModel.count - 1;
            for (var i = 0; i < length; i++) {
                startPoint = QtPositioning.coordinate(routeGpxModel.get(i).lat,
                                                      routeGpxModel.get(i).lon);
                endPoint = QtPositioning.coordinate(routeGpxModel.get(i+1).lat,
                                                    routeGpxModel.get(i+1).lon);
                routeDistance += startPoint.distanceTo(endPoint);
            }
            routeDistance = Math.round(routeDistance/1000);

            fuelConsumption = 8.8;

            amountOfFuel = (fuelConsumption * routeDistance / 100).toFixed(3);

            var startTime = new Date(routeGpxModel.get(0).time);
            var endTime = new Date(routeGpxModel.get(length).time);
            var duration = (endTime.getTime() - startTime.getTime()) / 1000 / 3600;
            averageSpeed = Math.round(routeDistance / duration);
        }

        function showRouteInfoPanel(checked) {
            if (checked === true) {
                showRouteInfoPanelAni.running = true;
            } else {
                hideRouteInfoPanelAni.running = true;
            }
        }

        function paintRoute() {
            for (var i = 0, l = routeModel.count; i < l; i ++) {
                var coordinate = QtPositioning.coordinate(routeModel.get(i).lat,
                                                          routeModel.get(i).lon,
                                                          routeModel.get(i).ele);
                routePolyline.addCoordinate(coordinate);
            }
            routePolyline.visible = true;
            mapViewer.fitViewportToMapItems();
        }

        function cleanRoute() {
            mapViewer.routePolyline.visible = false;
            var path = mapViewer.routePolyline.path;
            path = [];
            mapViewer.routePolyline.path = path;
        }

        function renderRouteByFuel() {
            var subRoutes = [];
            var j = 0;
            var fuel = routeModel.get(0).ele

            subRoutes[0] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 3}',
                                              mapViewer);
            for (var i = 0, l = routeModel.count; i < l; i ++) {
                var coordinate;
                var routePoint = routeModel.get(i);
                if (fuel !== routePoint.ele) {
                    coordinate = QtPositioning.coordinate(routePoint.lat,
                                                          routePoint.lon,
                                                          routePoint.ele);
                    subRoutes[j].addCoordinate(coordinate);
                    fuel = routePoint.ele;
                    subRoutes[++j] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 3}',
                                                        mapViewer);
                }
                coordinate = QtPositioning.coordinate(routePoint.lat,
                                                      routePoint.lon,
                                                      routePoint.ele);
                subRoutes[j].addCoordinate(coordinate);
            }

            for (i = 0, l = subRoutes.length; i < l; i ++) {
                var subRoute = subRoutes[i];
                subRoute.line.width = 5;
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
            mapViewer.addMapItem(mapViewer.myLocation);
            mapViewer.addMapItem(mapViewer.myDirection);
        }

        function processRecordCtrlBtnState() {
            switch(recordCtrlBtn.state) {
            case "stopped":
                if (mapViewer.routePolyline.pathLength()) {
                    cleanRoute();
                }

                recordCtrlBtn.state = "recording";
                recordCtrlBtn.iconSource = "icon/recordPause.png";
                saveRouteBtn.enabled = true;
                positionSource.updateInterval = 3000;   // 3 seconds
                createGpxFile();
                mapViewer.routePolyline.visible = true;
                break;
            case "recording":
                recordCtrlBtn.state = "pause";
                recordCtrlBtn.iconSource = "icon/recordResume.png";
                break;
            case "pause":
                recordCtrlBtn.state = "recording";
                recordCtrlBtn.iconSource = "icon/recordPause.png";
                break;
            }
        }

        function processSaveRouteBtnState() {
            switch(recordCtrlBtn.state) {
            case "recording":
            case "pause":
                recordCtrlBtn.state = "stopped";
                recordCtrlBtn.iconSource = "icon/recordStart.png";
                saveRouteBtn.enabled = false;
                positionSource.updateInterval = 12000;
                closeGpxFile();
                break;
            }
        }

        function createGpxFile() {
            if (!GPXWriter.createFile())
                console.log("create gpx file failed");
        }

        function writeGpxFile(position) {
            var newCoordinate = position.coordinate;
            console.log("newCoordinate:",
                        newCoordinate.latitude, newCoordinate.longitude, newCoordinate.altitude);

            if (position.latitudeValid && position.longitudeValid) {
                var correctedAltitude = position.altitudeValid ? newCoordinate.altitude : 0;
                GPXWriter.writeCoordinate(newCoordinate.latitude,
                                          newCoordinate.longitude,
                                          correctedAltitude,
                                          position.timestamp);
            }
        }

        function closeGpxFile() {
            GPXWriter.closeFile();
        }
    }
}
