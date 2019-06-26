import QtQuick 2.0

import Box2D 2.0

import Ros 1.0

TouchPoint {

    id: touch

    property string name: "touch"
    property bool movingItem: false
    property var itemMoved: ""
    property bool drawing: false

    // when used to draw on the background:
    property var currentStroke: []
    property color color: "black"

    property MouseJoint joint: MouseJoint {
        bodyA: anchor
        dampingRatio: 1
        maxForce: 1
    }

    onXChanged: {

        if(movingItem) {
            joint.target = Qt.point(x, y);
        }

        // (only add stroke point in one dimension (Y) to avoid double drawing)
    }

    onYChanged: {
        if(movingItem) {
            joint.target = Qt.point(x, y);
        }
    }
    onPressedChanged: {
        var obj = interactiveitems.childAt(x, y);
        if (pressed) {
            // find out whether we touched an item
            if (obj.objectName === "interactive" && obj.movable) {
                movingItem = true;
                itemMoved = obj;
                joint.maxForce = obj.body.getMass() * 500;
                joint.target = Qt.point(x, y);
                joint.bodyB = obj.body;
            }
        }
        else { // released
            if(movingItem) {
                //itemMoved.testCloseImages()
                joint.bodyB = null;
                movingItem = false;
                //itemMoved.checkProximity()
            }
        }
    }
}

