/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: delegate

    //Workaround
    property bool active: model.IsActive
    onActiveChanged: {
        //sometimes the task switcher window itself appears, screwing up the state
        if (model.IsActive) {
           // window.currentTaskIndex = index
        }
    }

    function syncDelegateGeometry() {
        let pos = pipeWireLoader.mapToItem(tasksView, 0, 0);
        if (window.visible) {
            tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, pipeWireLoader.width, pipeWireLoader.height), pipeWireLoader);
        } else {
          //  tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, delegate.width, delegate.height), dummyWindowTask);
        }
    }
    Connections {
        target: tasksView
        onContentYChanged: {
            syncDelegateGeometry();
        }
    }
    Connections {
        target: window
        function onVisibleChanged() {
            syncDelegateGeometry();
        }
    }

    Component.onCompleted: syncDelegateGeometry();

    PlasmaCore.ColorScope {
        anchors {
            fill: parent
            margins: PlasmaCore.Units.smallSpacing
        }
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

        SequentialAnimation {
            id: slideAnim
            property alias to: internalSlideAnim.to
            NumberAnimation {
                id: internalSlideAnim
                target: background
                properties: "x"
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: {
                    if (background.x != 0) {
                        tasksModel.requestClose(tasksModel.index(model.index, 0));
                    }
                }
            }
        }
        Rectangle {
            id: background

            width: parent.width
            height: parent.height
            color: Qt.rgba(0, 0, 0, 0.6) // theme.backgroundColor
            opacity: 1 * (1-Math.abs(x)/width)

            MouseArea {
                anchors.fill: parent
                drag {
                    target: background
                    axis: Drag.XAxis
                }
                onPressed: delegate.z = 10;
                onClicked: {
                    window.setSingleActiveWindow(model.index, delegate);
                    if (!model.IsMinimized) {
                        window.visible = false;
                    }
                }
                onReleased: {
                    delegate.z = 0;
                    if (Math.abs(background.x) > background.width/2) {
                        slideAnim.to = background.x > 0 ? background.width*2 : -background.width*2;
                        slideAnim.running = true;
                    } else {
                        slideAnim.to = 0;
                        slideAnim.running = true;
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    Rectangle {
                        color: Qt.rgba(255, 255, 255, 0.7)
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Loader {
                            id: pipeWireLoader
                            anchors.fill: parent
                            source: Qt.resolvedUrl("./Thumbnail.qml")
                            onStatusChanged: {
                                if (status === Loader.Error) {
                                    source = Qt.resolvedUrl("./TaskIcon.qml");
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        z: 99
                        Layout.margins: PlasmaCore.Units.smallSpacing
                        Layout.fillWidth: true
                        spacing: PlasmaCore.Units.smallSpacing
                        PlasmaCore.IconItem {
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.smallMedium
                            usesPlasmaTheme: false
                            source: model.decoration
                        }
                        PlasmaComponents.Label {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            text: model.display
                        }
                        PlasmaComponents.ToolButton {
                            z: 99
                            icon.name: "mobile-close-app"
                            icon.width: PlasmaCore.Units.iconSizes.small
                            icon.height: PlasmaCore.Units.iconSizes.small
                            onClicked: {
                                slideAnim.to = -background.width*2;
                                slideAnim.running = true;
                            }
                        }
                    }
                }
            }
        }
    }
}

