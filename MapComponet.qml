import QtQuick 2.5
import QtPositioning 5.6
import QtLocation 5.6

Map {
    property alias myLocation: myLocation
    property alias routePolyline: routePolyline

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

    MapPolyline {
        id: routePolyline
        line.width: 5
        line.color: 'green'
    }

    states: [
        State {
            name: "LOCATION"
            PropertyChanges { target: iconMyLocation; source: "icon/myLocation.svg"}
            PropertyChanges { target: myLocation; rotation: 0}
        },
        State {
            name: "DIRECTION"
            PropertyChanges { target: iconMyLocation; source: "icon/myDirection.png"}
        }
    ]
}
