/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobileshell 0.1 as MobileShell

Item {
    id: homeScreen;
    objectName: "homeScreen";
    x: 0;
    y: 0;
    width: 800;
    height: 480;
    signal nextActivityRequested
    signal previousActivityRequested
    signal newActivityRequested
    state : "Normal"
    signal transformingChanged(bool transforming)
    property bool locked: true

    property QtObject activeWallpaper
    onActiveWallpaperChanged: {
        print("Current wallpaper path"+activeWallpaper.wallpaperPath);
    }

    property QGraphicsWidget activeContainment
    onActiveContainmentChanged: {
        activeContainment.visible=true
        spareSlot.containment = activeContainment
        activeContainment.parent = spareSlot
        activeContainment.visible = true
        activeContainment.x = 0
        activeContainment.y = 0
        activeContainment.size = width + "x" + height
        //view the main containment
        state = "Slide"
        transformingChanged(true);
    }

    function finishTransition()
    {
        //spareSlot.containment = undefined
        if (mainSlot.containment) {
            mainSlot.containment.visible = false
        }
        mainSlot.containment = activeContainment
        activeContainment.parent = mainSlot
        activeContainment.x = 0
        activeContainment.y = 0

        //hide the activity switcher
        rightEdgePanel.x = homeScreen.width
        rightEdgePanel.state = "hidden"

        state = "Normal"
        transformingChanged(false);
        switcher.current=0
    }

    onLockedChanged: {
        if (locked) {
            lockScreenItem.opacity = 1
        } else {
            lockScreenItem.opacity = 0
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    Image {
        //TODO: take scale mode from Wallpaper config
        asynchronous: true
        source: activeWallpaper.wallpaperPath
        width: Math.max(homeScreen.width, sourceSize.width)
        height: Math.max(homeScreen.height, sourceSize.height)
        //Parallax: the background moves for is width
        x: (mainContainments.width-width)*(1-((mainContainments.x+mainContainments.width)/(mainContainments.width*3)))
    }

    //this item will define Corona::availableScreenRegion() for simplicity made by a single rectangle
    Item {
        id: availableScreenRect
        objectName: "availableScreenRect"
        anchors.fill: parent
        anchors.topMargin: 40
        anchors.bottomMargin: 12

        //this properties will define "structs" for reserved screen of the panels
        property int leftReserved: 0
        property int topReserved: anchors.topMargin
        property int rightReserved: 0
        property int bottomReserved: 0
    }

    Item {
        id: alternateSlot;
        objectName: "alternateSlot";
        x: -width
        y: 0
        width: homeScreen.width;
        height: homeScreen.height;
    }

    Item {
        id: mainContainments
        width: homeScreen.width
        height: homeScreen.height
        x: 0
        y: 0

        Item {
            id: mainSlot;
            objectName: "mainSlot"
            x: 0;
            y: 0;
            width: homeScreen.width
            height: homeScreen.height
            property QGraphicsWidget containment
        }
    }

    RecommendationsPanel {
        id: leftEdgePanel
        objectName: "leftEdgePanel"

        anchors.verticalCenter: parent.verticalCenter
        x: - width
    }

    states: [
            State {
                name: "Normal"
                /*PropertyChanges {
                    target: mainSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    y: -homeScreen.height;
                }*/
                PropertyChanges {
                    target: spareSlot;
                    scale: 0.3;
                }
                PropertyChanges {
                    target: spareSlot;
                    opacity: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    x: homeScreen.width/4
                }

            },
            State {
                name: "Slide"
                PropertyChanges {
                    target: spareSlot;
                    y: 0;
                }
                PropertyChanges {
                    target: spareSlot;
                    scale: 1;
                }
                PropertyChanges {
                    target: spareSlot;
                    opacity: 1;
                }
                PropertyChanges {
                    target: spareSlot;
                    x: 0
                }
            }
    ]

    transitions: Transition {
            from: "Normal"
            to: "Slide"
            SequentialAnimation {

                ParallelAnimation {
                    NumberAnimation {
                        target: spareSlot;
                        property: "opacity";
                        easing.type: "OutQuad";
                        duration: 300;
                    }
                    NumberAnimation {
                        target: spareSlot;
                        property: "scale";
                        easing.type: "OutQuad";
                        duration: 300;
                    }
                    NumberAnimation {
                        target: spareSlot;
                        property: "x";
                        easing.type: "OutQuad";
                        duration: 300;
                    }
                }
                ScriptAction {
                    script: finishTransition();
                }
            }
        }

    MobileShell.MobilePanel {
        id: slidingPanel
        visible: true
        mainItem: SystrayPanel {
            id: topEdgePanel
            objectName: "topEdgePanel"
        }
        onActiveWindowChanged: {
            if (acceptsFocus && !activeWindow) {
                topEdgePanel.state = "Hidden"
            }
        }
    }

    ActivityPanel {
        id: activityPanel

        anchors.verticalCenter: parent.verticalCenter
        x: parent.width - width
    }

    Item {
        id : spareSlot
        objectName: "spareSlot"
        x: 0
        y: 0
        width: homeScreen.width
        height: homeScreen.height
        property QGraphicsWidget containment
    }

    LockScreen {
        id: lockScreenItem
        anchors.fill: parent

        onUnlocked: {
            homeScreen.locked = false
        }
    }
}
