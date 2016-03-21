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
                if (mapViewer.state === "DIRECTION") {
                    if ( mainForm.recordCtrlBtn.state === "recording") {
                        var currentDateTime = new Date();
                        mapViewer.routePolyline.addCoordinate(coordinate);
                        mainForm.writeGpxFile(positionSource.position);
                    }
                    if (mapViewer.directionLine.pathLength()) {
                        mapViewer.directionLine.replaceCoordinate(0, coordinate);
                    }
                }
            }
        }

        Compass {
            id: compass
            active: false

            onReadingChanged: {
                if (mapViewer.state === "DIRECTION") {
                    mapViewer.myLocation.rotation = reading.azimuth + 45;
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

        Dialog {
            id: waypointDialog
            title: "Set Waypoints"
            standardButtons: StandardButton.Ok | StandardButton.Cancel
            width: mainForm.width
            height: mainForm.height

            Text {
                id: dialogTitle
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 4
                text: qsTr("Set the coordinate of your destination")
                wrapMode: Text.WordWrap
                color: "white"
                font.bold: true
                font.pointSize: 32
            }

            Text {
                id: latLabel
                anchors.left: parent.left
                anchors.top: dialogTitle.bottom
                anchors.margins: 32
                color: "white"
                font.bold: true
                font.pointSize: 18
                text: qsTr("Latitude:")
            }
            Rectangle {
                id: latInputRect
                anchors.left: latLabel.right
                anchors.leftMargin: 8
                anchors.bottom: latLabel.bottom
                color: "black"
                border.color: "white"
                border.width: 4
                width: latInput.width + 16
                height: latInput.height + 16

                TextInput {
                    id: latInput
                    width: 280
                    height: 36
                    anchors.centerIn: parent
                    cursorVisible: true
                    color: "white"
                    maximumLength: 16
                    validator: DoubleValidator { bottom: -180.0; top: 180.0 }
                }
            }

            Text {
                id: longLabel
                anchors.left: latInputRect.right
                anchors.top: dialogTitle.bottom
                anchors.margins: 32
                color: "white"
                font.bold: true
                font.pointSize: 18
                text: qsTr("Longitude:")
            }
            Rectangle {
                id: longInputRect
                anchors.left: longLabel.right
                anchors.leftMargin: 8
                anchors.bottom: longLabel.bottom
                color: "black"
                border.color: "white"
                border.width: 4
                width: longInput.width + 16
                height: longInput.height + 16

                TextInput {
                    id: longInput
                    width: 280
                    height: 36
                    anchors.centerIn: parent
                    color: "white"
                    maximumLength: 16
                    validator: DoubleValidator { bottom: -90.0; top: 90.0 }
                }
            }

            onAccepted: {
                mainForm.setDestination(latInput.text, longInput.text);
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
            XmlRole { name: "fuel"; query: "fuel/number()"}

            onStatusChanged: {
                switch(status) {
                case XmlListModel.Loading:
                    console.log("loading coordinates...");
                    break;

                case XmlListModel.Ready:
                    console.log("display the route on the map", count);
                    if (count) {
                        mainForm.removeColoredRoute();

                        if (typeof routeModel.get(0).fuel === "string")
                            mainForm.renderRouteByAltitude();
                        else
                            mainForm.renderRouteByFuel();

                        mainForm.calculateRouteInfo(routeModel);
                    }
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
            removeColoredRoute();
        }

        recordCtrlBtn.onClicked: processRecordCtrlBtnState()

        saveRouteBtn.onClicked: processSaveRouteBtnState()

        routeInfoSwitch.onCheckedChanged: showRouteInfoPanel(routeInfoSwitch.checked)

        modeSwitch.onCheckedChanged: {
            if (modeSwitch.checked === false) {
                console.log("state from RECORDING to ROUTE_VIEWER");
                mainForm.state = "ROUTE_VIEWER";
                mapViewer.state = "LOCATION";
                compass.active = false;
                removeOrienteeringItems();
            } else {
                console.log("state from ROUTE_VIEWER to RECORDING");
                mainForm.state = "RECORDING";
                mapViewer.state = "DIRECTION";
                compass.active = true;
                resetRouteInfo();
                removeColoredRoute();
            }
        }

        waypointBtn.onClicked: waypointDialog.open()

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

        function setDestination(latitude, longitude) {
            mapViewer.directionLine.removeCoordinate(1);
            mapViewer.directionLine.removeCoordinate(0);
            // TODO: validate the coordinate first
            var destCoordinate = QtPositioning.coordinate(Number(latitude), Number(longitude));
            mapViewer.destLocation.coordinate = destCoordinate;
            mapViewer.addMapItem(mapViewer.destLocation);

            mapViewer.directionLine.addCoordinate(mapViewer.myLocation.coordinate);
            mapViewer.directionLine.addCoordinate(mapViewer.destLocation.coordinate);
            mapViewer.addMapItem(mapViewer.directionLine);

            mapViewer.fitViewportToMapItems();
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
            var hasFuel = false;
            var totalDistance = 0;

            if (typeof routeGpxModel.get(0).fuel != "string")
                hasFuel = true;
            amountOfFuel = 0;

            var length = routeGpxModel.count - 1;
            for (var i = 0; i < length; i++) {
                var gpxPointStart = routeGpxModel.get(i);
                var gpxPointEnd = routeGpxModel.get(i+1);

                startPoint = QtPositioning.coordinate(gpxPointStart.lat,
                                                      gpxPointStart.lon);
                endPoint = QtPositioning.coordinate(gpxPointEnd.lat,
                                                    gpxPointEnd.lon);

                var distance = startPoint.distanceTo(endPoint)
                totalDistance += distance;

                if (hasFuel) {
                    amountOfFuel +=
                            distance * (gpxPointStart.fuel + gpxPointEnd.fuel)/2;
                }
            }
            routeDistance = Math.round(totalDistance/1000);

            if (hasFuel) {
                amountOfFuel = (amountOfFuel / (1000 * 100)).toFixed(3);
                fuelConsumption = amountOfFuel / routeDistance * 100;
            } else {
                fuelConsumption = 8.8;
                amountOfFuel = (fuelConsumption * routeDistance / 100).toFixed(3);
            }

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

        function renderRouteByAltitude() {
            var subRoutes = [];
            var j = 0;
            var ele = routeModel.get(0).ele;
            var minEle = ele;
            var maxEle = ele;

            subRoutes[0] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 5}',
                                              mapViewer);
            for (var i = 0, l = routeModel.count; i < l; i ++) {
                var coordinate;
                var routePoint = routeModel.get(i);
                if (ele !== routePoint.ele) {
                    coordinate = QtPositioning.coordinate(routePoint.lat,
                                                          routePoint.lon,
                                                          routePoint.ele);
                    subRoutes[j].addCoordinate(coordinate);
                    ele = routePoint.ele;
                    subRoutes[++j] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 5}',
                                                        mapViewer);

                    if (ele < minEle)
                        minEle = ele;
                    if (ele > maxEle)
                        maxEle = ele;
                }
                coordinate = QtPositioning.coordinate(routePoint.lat,
                                                      routePoint.lon,
                                                      routePoint.ele);
                subRoutes[j].addCoordinate(coordinate);
            }

            for (i = 0, l = subRoutes.length; i < l; i ++) {
                var subRoute = subRoutes[i];
                subRoute.line.width = 5;
                subRoute.line.color = mapAltitudeToColor(subRoute.path[0].altitude,
                                                         minEle, maxEle);
                mapViewer.addMapItem(subRoute);
                subRoute.visible = true;
            }

            mapViewer.fitViewportToMapItems();
        }

        function mapAltitudeToColor(altitude, minAltitude, maxAltitude) {
            var colors = ["blue", "steelblue", "springgreen", "green",
                          "greenyellow", "yellow", "darkorange", "saddlebrown",
                          "maroon", "red"];
            return colors[Math.floor(9 * (altitude - minAltitude)/(maxAltitude - minAltitude))];
        }

        function renderRouteByFuel() {
            var subRoutes = [];
            var j = 0;
            var fuel = routeModel.get(0).fuel;

            subRoutes[0] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 5}',
                                              mapViewer);
            for (var i = 0, l = routeModel.count; i < l; i ++) {
                var coordinate;
                var routePoint = routeModel.get(i);
                if (fuel !== routePoint.fuel) {
                    coordinate = QtPositioning.coordinate(routePoint.lat,
                                                          routePoint.lon,
                                                          routePoint.ele);
                    subRoutes[j].addCoordinate(coordinate);
                    subRoutes[j].line.width = 5;
                    subRoutes[j].line.color = mapFuelToColor(fuel);
                    mapViewer.addMapItem(subRoutes[j]);
                    subRoutes[j].visible = true;

                    fuel = routePoint.fuel;
                    subRoutes[++j] = Qt.createQmlObject('import QtLocation 5.6; MapPolyline {width: 5}',
                                                        mapViewer);
                }
                coordinate = QtPositioning.coordinate(routePoint.lat,
                                                      routePoint.lon,
                                                      routePoint.ele);
                subRoutes[j].addCoordinate(coordinate);
            }

            subRoutes[j].line.width = 5;
            subRoutes[j].line.color = mapFuelToColor(fuel);
            mapViewer.addMapItem(subRoutes[j]);
            subRoutes[j].visible = true;

            mapViewer.fitViewportToMapItems();
        }

        function mapFuelToColor(fuel) {
            var colors = ["blue", "steelblue", "springgreen", "green",
                          "greenyellow", "yellow", "darkorange", "saddlebrown",
                          "maroon", "red"];
            var color = "green";

            if (fuel < 5)
                color = colors[0];
            else if (fuel >= 5 && fuel < 13)
                color = colors[Math.floor(fuel - 4)];
            else if (fuel >= 13)
                color = colors[9];

            return color;
        }

        function removeColoredRoute() {
            mapViewer.clearMapItems();
            mapViewer.addMapItem(mapViewer.myLocation);
        }

        function removeOrienteeringItems() {
            mapViewer.directionLine.removeCoordinate(1);
            mapViewer.directionLine.removeCoordinate(0);
            mapViewer.removeMapItem(mapViewer.directionLine);
            mapViewer.removeMapItem(mapViewer.destLocation);
        }

        function processRecordCtrlBtnState() {
            switch(recordCtrlBtn.state) {
            case "stopped":
                if (mapViewer.routePolyline.pathLength()) {
                    cleanRoute();
                }

                recordCtrlBtn.state = "recording";
                recordCtrlBtn.text = qsTr("Pause");
                saveRouteBtn.enabled = true;
                modeSwitch.enabled = false;
                positionSource.updateInterval = 3000;   // 3 seconds
                createGpxFile();
                mapViewer.routePolyline.visible = true;
                break;
            case "recording":
                recordCtrlBtn.state = "pause";
                recordCtrlBtn.text = qsTr("Resume");
                break;
            case "pause":
                recordCtrlBtn.state = "recording";
                recordCtrlBtn.text = qsTr("Pause");
                break;
            }
        }

        function processSaveRouteBtnState() {
            switch(recordCtrlBtn.state) {
            case "recording":
            case "pause":
                recordCtrlBtn.state = "stopped";
                recordCtrlBtn.text = qsTr("Start");
                saveRouteBtn.enabled = false;
                modeSwitch.enabled = true;
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
                // TODO: get fuel consumption from CAN bus
                var fuel = Number.NaN;
                fuel = 8.8 + (Math.random() * 4 - 4);
                fuel = Math.round(fuel * 10) / 10;
                console.log("fuel = ", fuel);
                if (fuel != Number.NaN)
                    GPXWriter.writeCoordinate(newCoordinate.latitude,
                                              newCoordinate.longitude,
                                              correctedAltitude,
                                              position.timestamp, fuel);
            }
        }

        function closeGpxFile() {
            GPXWriter.closeFile();
        }
    }
}
