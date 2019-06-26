import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import Box2D 2.0
import QtTest 1.1

import Ros 1.0

Window {

    id: window

    visible: true
    //visibility: Window.FullScreen
    width:800
    height: 600

    property int prevWidth:800
    property int prevHeight:600

    onWidthChanged: {
        prevWidth=width;
    }
    onHeightChanged: {
        prevHeight=height;
    }
    color: "black"
    title: qsTr("Free-play sandbox")

    Item {
        id: sandbox
        anchors.fill:parent
        visible: true

        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        //property double pixel2meter: (physicalMapWidth / 1000) / drawingarea.paintedWidth
        property double pixel2meter: (physicalMapWidth / 1000) / parent.width
        Item {
            // this item sticks to the 'visual' origin of the map, taking into account
            // possible margins appearing when resizing
            id: mapOrigin
            property string name: "sandtray"
            rotation: parent.rotation
            x: parent.x // + (parent.width - parent.paintedWidth)/2
            y: parent.y //+ (parent.height - parent.paintedHeight)/2
        }
        Image {
            id: image
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: "res/map.svg"

            Item {
                // this item sticks to the 'visual' origin of the object, taking into account
                // possible margins appearing when resizing
                id: imageOrigin
                rotation: parent.rotation
                x: parent.x + (parent.width - parent.paintedWidth)/2
                y: parent.y + (parent.height - parent.paintedHeight)/2
            }
        }
        Item {
            id: interactiveitems
            anchors.fill: parent
            visible: true
            z:5

            property var collisionCategories: Box.Category2
            property bool showRobotChild: false
            property bool publishRobotChild: false

            MouseJoint {
                id: externalJoint
                bodyA: anchor
                dampingRatio: 1
                maxForce: 1
            }

            MultiPointTouchArea {
                id: touchArea
                anchors.fill: parent

                touchPoints: [
                    TouchJoint {id:touch1;name:"touch1"},
                    TouchJoint {id:touch2;name:"touch2"},
                    TouchJoint {id:touch3;name:"touch3"},
                    TouchJoint {id:touch4;name:"touch4"},
                    TouchJoint {id:touch5;name:"touch5"},
                    TouchJoint {id:touch6;name:"touch6"}
                ]
            }

            World {
                id: physicsWorld
                gravity: Qt.point(0.0, 0.0);

            }

            RectangleBoxBody {
                id: rightwall
                color: "#000000FF"
                width: 20
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    top: parent.top
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }
            RectangleBoxBody {
                id: leftwall
                color: "#000000FF"
                width: 20
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    top: parent.top
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }
            RectangleBoxBody {
                id: top
                color: "#000000FF"
                height: 20
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }
            RectangleBoxBody {
                id: ground
                color: "#000000FF"
                height: 20
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                world: physicsWorld
                friction: 1
                density: 1
                categories: Box.Category2
            }

            Body {
                id: anchor
                world: physicsWorld
            }

            InteractiveItem {
                id: base_link
                x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
                y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
                name: "base_link"
            }
            InteractiveItem {
                id: goal
                x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
                y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
                name: "goal"
            }
            InteractiveItem {
                id: human
                x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
                y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
                name: "human"
            }
            InteractiveItem {
                id: cube_0
                x: 0.2 * parent.width + Math.random() * 0.6 * parent.width
                y: 0.2 * parent.height + Math.random() * 0.6 * parent.height
                width: 0.2 * parent.width
                height: width/5
                name: "cube_0"
            }
            InteractiveItem {
                id: cube_1
                x: 0.2 * parent.width + Math.random() * 0.6 * parent.width
                y: 0.2 * parent.height + Math.random() * 0.6 * parent.height
                width: 0.2 * parent.width
                height: width/5
                name: "cube_1"
            }
            InteractiveItem {
                id: cube_2
                x: 0.2 * parent.width + Math.random() * 0.6 * parent.width
                y: 0.2 * parent.height + Math.random() * 0.6 * parent.height
                width: 0.2 * parent.width
                height: width/5
                name: "cube_2"
            }
            InteractiveItem {
                id: cube_3
                x: 0.2 * parent.width + Math.random() * 0.6 * parent.width
                y: 0.2 * parent.height + Math.random() * 0.6 * parent.height
                width: 0.2 * parent.width
                height: width/5
                name: "cube_3"
            }
            function getAllItems() {
                return [human, cube_0, cube_1, cube_2, cube_3]
            }
            FootprintsPublisher {
                id:footprints
                pixelscale: sandbox.pixel2meter

                // wait a bit before publishing the footprints to leave Box2D the time to settle
                Timer {
                    interval: 1000; running: true; repeat: false
                    onTriggered: parent.targets=interactiveitems.getAllItems()
                }
            }

        }
  }

    function sleep(milliseconds) {
      var start = new Date().getTime();
      for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds){
          break;
        }
      }
    }
}
