import QtQuick 2.0
import QtMultimedia 5.8
import Box2D 2.0

InteractiveItem {
    id: character

    property double scale: initialScale
    property double initialScale: 1
    property double bbScale: 1.0

    property var stash: parent
    property var food: []
    property double initialLife: 1
    property double life: 0
    property bool eating: false
    property double fleeX: 0
    property double fleeY: 0
    property bool alive: false
    property bool isMoved: false
    property double targetLife: 0
    property bool movable: true
    property bool fleeing: fleeAnim.running
    property int predatorLevel: 0
    property string target: ""
    visible: false
    x: -100
    y: -100
    property int centerX: x+width/2
    property int centerY: y+height/2

    width: 2 * scale * parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    rotation: 0

    onRotationChanged: rotation = 0
    onXChanged: if(isMoved && !fleeing) testCloseImages()

    property double bbRadius: bbScale * character.width/2
    property point bbOrigin: Qt.point(character.width/2, character.height/2)

    property alias friction: bbpoly.friction
    property alias restitution: bbpoly.restitution
    property alias density: bbpoly.density
    property alias collidesWith: bbpoly.collidesWith

    boundingbox: Polygon {
                id:bbpoly
                vertices: [
                    Qt.point(bbOrigin.x + bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y + bbRadius),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x - bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y - bbRadius),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius)
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }

    ParallelAnimation{
        id:fleeAnim
        NumberAnimation {target: character; property: "x"; from: x; to: x+fleeX; duration: 500; easing.type: Easing.OutInBounce}
        NumberAnimation {target: character; property: "y";from: y; to: y+fleeY; duration: 500; easing.type: Easing.InOutBounce}
    }
    NumberAnimation {id: lifeChangeAnimation; target: character; property: "life"; from: life; to: targetLife; duration: 800; onRunningChanged: {if(!running) eating = false}}
    NumberAnimation {id: death; target: character; property: "scale"; from: scale; to: 0.1; duration: 1000}


    Lifebar {
        id: lifeSlider
        ratio: life/initialLife
        enabled:false
    }

    Audio {
        id: soundPlayer
        property bool isPlaying: false
        property var startTime: 0
        property int yuckMax: 7
        property int yumMax: 8
        property int fleeMax: 7
        property int eatenMax: 7
        source: "res/yuck1.mp3"
        onPlaying: {
            startTime = new Date()
            isPlaying = true
        }
        onStopped: {
            var stopTime = new Date()
            var diff =stopTime.getTime()-startTime.getTime()
            isPlaying = false
            if(diff<200){
                play()
                console.log("Replay")
            }
        }
        function runYuck(){
            var i = Math.floor(Math.random() * yuckMax) + 1
            if (i>yuckMax)
                i=yuckMax
            source = "/res/yuck"+i+".mp3"
            play()
        }
        function runYum(){
            var i = Math.floor(Math.random() * yumMax) + 1
            if (i>yumMax)
                i=yumMax
            source = "/res/yummy"+i+".mp3"
            play()
        }
        function runFlee(){
            var i = Math.floor(Math.random() * fleeMax) + 1
            if (i>fleeMax)
                i=fleeMax
            source = "/res/flee"+i+".mp3"
            play()
        }
        function runEaten(){
            var i = Math.floor(Math.random() * eatenMax) + 1
            if (i>eatenMax)
                i=eatenMax
            source = "/res/eaten"+i+".mp3"
            play()
        }
    }

    function testCloseImages(){
        if(!visible || !alive)
            return
        var list = interactiveitems.getActiveItems()
        for(var i=0 ; i < list.length; i++){
            if(list[i].visible && !list[i].fleeing && list[i].life > 0 && testProximity(list[i])){
                if(food.indexOf(list[i].name)>-1){
                    list[i].flee()
                    if(!eating && list[i].life>0){// && life < .95*initialLife){
                        list[i].changeLife(-.25)
                        target = list[i].name
                        changeLife(0.3)
                        soundPlayer.runYum()
                    }
                }
                else if(list[i].food.indexOf(name)>-1){
                    flee()
                    soundPlayer.runEaten()
                    if (!list[i].eating && life>0){// && list[i].life < .95*list[i].initialLife){
                        changeLife(-.25)
                        list[i].target = name
                        list[i].changeLife(.3)
                    }
                }
                else if (list[i].predatorLevel <= predatorLevel){
                    failInteraction(name, list[i].name)
                    list[i].flee()
                    soundPlayer.runYuck()
                    blink("gold")
                }
                else{
                    flee()
                    failInteraction(name, list[i].name)
                    soundPlayer.runFlee()
                    blink("darkturquoise")
                }
            }
        }

        list = interactiveitems.getStaticItems()
        for(var i=0 ; i < list.length; i++){
            if(testProximity(list[i]) && !eating && list[i].life>0){// && life < .95*initialLife){
                if(food.indexOf(list[i].type)>-1){
                    list[i].changeLife(-.25)
                    target = list[i].name
                    changeLife(0.3)
                    soundPlayer.runYum()
                }
                else{
                    if(!soundPlayer.isPlaying){
                        failInteraction(name, list[i].name)
                        soundPlayer.runYuck()
                        blink("gold")
                    }
                }
            }
        }

        //checkProximity()
    }
    onLifeChanged: {
        if(life>initialLife)
            life = initialLife
        if(life<=0){
            life = 0
            alive = false
        }
    }
    onAliveChanged: {
        if(alive){
            sandbox.livingAnimals++
            visible = true

        }
        else {
            death.start()
        }
    }
    onScaleChanged: {
        if(scale <= 0.1 && visible){
            x=-100
            y=-100
            sandbox.livingAnimals--
            visible = false
            scale = initialScale
            animalDying(name)
        }
    }

    function relocate(){
        if(!visible)
            return
        var good = false
        while(!good){
            good = true
            x = drawingarea.width * (.15 + 0.7 * Math.random())
            y = drawingarea.height * (.15 + 0.7 * Math.random())
            var list = interactiveitems.getActiveItems()
            for(var i=0 ; i < list.length; i++){
                var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                 if(dist<60000 && list[i].name !== name){
                     good = false
                 }
            }
            list = interactiveitems.getStaticItems()
            for(var i=0 ; i < list.length; i++){
                var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                 if(dist<60000 && list[i].name !== name){
                     good = false
                 }
            }
        }
    }

    function  checkProximity(){
        if(isMoved || !alive)
            return
        var list = interactiveitems.getActiveItems()
        for(var i=0 ; i < list.length; i++){
            if(testProximity(list[i])){
                x += 20/(x-list[i].x)
                y += 20/(y-list[i].y)
                startProximityTimer()
                list[i].startProximityTimer()
            }
        }
    }
    Timer {
        id: proximityTimer
        interval: 10; running: false; repeat: false
        onTriggered: {
            checkProximity()
        }
    }
    function startProximityTimer(){
        proximityTimer.running = true
    }

    function testProximity(item){
        var dist = Math.pow(centerX-item.centerX,2)+Math.pow(centerY-item.centerY,2)
        if(dist<Math.pow(item.width*1.1/2.+width*1.1/2.,2) && item.name !== name)
            return true
        else
            return false
    }

    function flee(){
        var angle = 0
        var distance = 0
        var good = false
        var counter = 0
        while(!good){
            counter++
            good = true
            angle = 2 * Math.PI * Math.random()
            distance = 50 + counter + 200 * Math.random()
            fleeX = distance * Math.cos(angle)
            fleeY = distance * Math.sin(angle)
            if (x+fleeX < 100 || x+fleeX > sandbox.width - 100 || y+fleeY< 100 || y+fleeY>sandbox.height - 100){
                good=false
                continue
            }
            if(counter > 1500){
                break
            }
            var list = interactiveitems.getActiveItems()
            for(var i=0 ; i < list.length; i++){
                var dist = Math.pow(x+fleeX-list[i].x,2)+Math.pow(y+fleeY-list[i].y,2)
                 if(dist<60000 && list[i].name !== name){
                     good = false
                 }
            }
        }

        fleeAnim.start()
    }

    function changeLife(value){
        targetLife = life + value
        lifeChangeAnimation.start()
        if(value<0){
            blink("red")
        }
        else{
            blink("green")
            eating=true
        }
    }

    function blink(color){
            lifeSlider.blinkColor = color
            lifeSlider.animation.start()
    }

    function initiate(){
        visible = true
        relocate()
        alive = true
        life = initialLife
        scale = initialScale

    }


    function release(){
        releaseTimer.start()
    }

    function touched(){
        isMoved = true
        releaseTimer.stop()
    }

    Timer{
        id: releaseTimer
        interval: 500
        onTriggered: isMoved = false
    }

    onEatingChanged:{
        if (eating){
            animalEating(name,target)
        }
    }
 }
