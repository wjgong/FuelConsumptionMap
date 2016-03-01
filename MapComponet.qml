import QtQuick 2.5
import QtPositioning 5.6
import QtLocation 5.6

Map {
    property alias myLocation: myLocation
    property alias myDirection: myDirection
    property alias routePolyline: routePolyline

    anchors.fill: parent
    plugin: Plugin {
        name: "osm"
    }
    zoomLevel: 13

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
        id: myDirection
        sourceItem: Image {
            id: iconMyDirection
            source: "icon/myDirection.png"
        }
        antialiasing: true
        visible: false
        anchorPoint.x: iconMyDirection.width/2
        anchorPoint.y: iconMyDirection.height/2
    }

    MapPolyline {
        id: routePolyline
        line.width: 3
        line.color: 'green'
    }

    states: [
        State {
            name: "LOCATION"
            PropertyChanges { target: myLocation; visible: true }
            PropertyChanges { target: myDirection; visible: false }
        },
        State {
            name: "DIRECTION"
            PropertyChanges { target: myLocation; visible: false }
            PropertyChanges { target: myDirection; visible: true }
        }
    ]
}
