import QtQuick 2.5
import QtPositioning 5.6
import QtLocation 5.6

Map {
    id: map
    property alias myLocation: myLocation
    property alias routePolyline: routePolyline
    property variant scaleLengths: [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000]
    property alias destLocation: destLocation
    property alias directionLine: directionLine

    anchors.fill: parent
    plugin: Plugin {
        name: "osm"
    }
    zoomLevel: 13
    state: "LOCATION"

    gesture.enabled: true
    gesture.acceptedGestures: MapGestureArea.PinchGesture | MapGestureArea.PanGesture | MapGestureArea.FlickGesture
    gesture.flickDeceleration: 3000

    MapQuickItem {
        id: myLocation
        sourceItem: Image {
            id: iconMyLocation
            source: "icon/myLocation.svg"
        }
        antialiasing: true
        anchorPoint.x: iconMyLocation.width/2
        anchorPoint.y: iconMyLocation.height/2
    }

    MapQuickItem {
        id: destLocation
        sourceItem: Image {
            id: iconDestLocation
            source: "icon/destFlag.png"
        }
        anchorPoint.x: 4
        anchorPoint.y: iconDestLocation.height
    }

    MapPolyline {
        id: directionLine
        line.width: 3
        line.color: "red"
    }

    MapPolyline {
        id: routePolyline
        line.width: 5
        line.color: "green"
    }

    Rectangle {
        id: northIndicator
        color: "white"
        opacity: 0.5
        border.color: "black"
        border.width: 2
        z: map.z + 1
        implicitWidth: northLabel.height
        implicitHeight: northLabel.height
        radius: width/2
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: northLabel
            text: qsTr("N")
            font.bold: true
            font.pointSize: 24
            anchors.centerIn: parent
            color: "red"
        }
    }
    Rectangle {
        id: southIndicator
        color: "white"
        opacity: 0.5
        border.color: "black"
        border.width: 2
        z: map.z + 1
        implicitWidth: southLabel.height
        implicitHeight: southLabel.height
        radius: width/2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false

        Text {
            id: southLabel
            text: qsTr("S")
            font.bold: true
            font.pointSize: 24
            anchors.centerIn: parent
        }
    }
    Rectangle {
        id: westIndicator
        color: "white"
        opacity: 0.5
        border.color: "black"
        border.width: 2
        z: map.z + 1
        implicitWidth: westLabel.height
        implicitHeight: westLabel.height
        radius: width/2
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        visible: false

        Text {
            id: westLabel
            text: qsTr("W")
            font.bold: true
            font.pointSize: 24
            anchors.centerIn: parent
        }
    }
    Rectangle {
        id: eastIndicator
        color: "white"
        opacity: 0.5
        border.color: "black"
        border.width: 2
        z: map.z + 1
        implicitWidth: eastLabel.height
        implicitHeight: eastLabel.height
        radius: width/2
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        visible: false

        Text {
            id: eastLabel
            text: qsTr("E")
            font.bold: true
            font.pointSize: 24
            anchors.centerIn: parent
        }
    }

    Item {
        id: scale
        z: map.z + 3
        visible: scaleText.text != "0 m"
        anchors.bottom: parent.bottom;
        anchors.right: parent.right
        anchors.bottomMargin: 20
        anchors.rightMargin: 80
        height: scaleText.height * 2
        width: scaleImage.width

        Image {
            id: scaleImageLeft
            source: "icon/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImage.left
        }
        Image {
            id: scaleImage
            source: "icon/scale.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImageRight.left
        }
        Image {
            id: scaleImageRight
            source: "icon/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
        Text {
            id: scaleText
            color: "#004EAE"
            anchors.centerIn: parent
            text: "0 m"
        }
        Component.onCompleted: {
            map.calculateScale();
        }
    }

    function calculateScale()
    {
        var coord1, coord2, dist, text, f
        f = 0
        coord1 = map.toCoordinate(Qt.point(0,scale.y))
        coord2 = map.toCoordinate(Qt.point(0+scaleImage.sourceSize.width*2,scale.y))
        dist = Math.round(coord1.distanceTo(coord2))

        if (dist === 0) {
            // not visible
        } else {
            for (var i = 0; i < scaleLengths.length-1; i++) {
                if (dist < (scaleLengths[i] + scaleLengths[i+1]) / 2 ) {
                    f = scaleLengths[i] / dist
                    dist = scaleLengths[i]
                    break;
                }
            }
            if (f === 0) {
                f = dist / scaleLengths[i]
                dist = scaleLengths[i]
            }
        }

        text = map.formatDistance(dist)
        scaleImage.width = (scaleImage.sourceSize.width*2 * f) - 2 * scaleImageLeft.sourceSize.width
        scaleText.text = text
    }

    function formatDistance(meters)
    {
        var dist = Math.round(meters)
        if (dist > 1000 ){
            if (dist > 100000){
                dist = Math.round(dist / 1000)
            }
            else{
                dist = Math.round(dist / 100)
                dist = dist / 10
            }
            dist = dist + " km"
        }
        else{
            dist = dist + " m"
        }
        return dist
    }

    Timer {
        id: scaleTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            map.calculateScale()
        }
    }

    onZoomLevelChanged: scaleTimer.restart()

    states: [
        State {
            name: "LOCATION"
            PropertyChanges { target: iconMyLocation; source: "icon/myLocation.svg"}
            PropertyChanges { target: myLocation; rotation: 0}
            PropertyChanges { target: southIndicator; visible: false }
            PropertyChanges { target: westIndicator; visible: false }
            PropertyChanges { target: eastIndicator; visible: false }
        },
        State {
            name: "DIRECTION"
            PropertyChanges { target: iconMyLocation; source: "icon/myDirection.png"}
            PropertyChanges { target: southIndicator; visible: true }
            PropertyChanges { target: westIndicator; visible: true }
            PropertyChanges { target: eastIndicator; visible: true }
        }
    ]
}
