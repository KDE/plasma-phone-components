/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    
    required property var taskSwitcher    
    readonly property var taskSwitcherState: taskSwitcher.taskSwitcherState
    
    opacity: taskSwitcherState.wasInActiveTask ? 1 : Math.min(1, taskSwitcherState.yPosition / taskSwitcherState.openedYPosition)
    
    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: taskSwitcherState.currentScale
        yScale: taskSwitcherState.currentScale
    }
    
    // taphandler activates even if delegate touched
    TapHandler {
        onTapped: {
            // if tapped on the background, then hide
            if (root.childAt(eventPoint.position.x, eventPoint.position.y) === null) {
                taskSwitcher.hide();
            }
        }
        onPressedChanged: {
            if (pressed) {
                // ensure animations aren't running when finger is pressed
                taskSwitcherState.cancelAnimations();
            }
        }
    }
    
    Repeater {
        id: repeater
        model: taskSwitcher.model
        
        // left margin from root edge such that the task is centered
        readonly property real leftMargin: (root.width / 2) - (taskSwitcherState.taskWidth / 2) 
        
        delegate: Task {
            id: task
            
            readonly property int currentIndex: model.index
            
            // this is the x-position with respect to the list
            property real listX: taskSwitcherState.xPositionFromTaskIndex(currentIndex);
            
            Behavior on listX { 
                NumberAnimation { 
                    duration: PlasmaCore.Units.longDuration
                    easing.type: Easing.InOutQuad 
                } 
            }
            
            // this is the actual displayed x-position on screen
            x: listX + repeater.leftMargin - taskSwitcherState.xPosition
            
            // account for system header and footer offset (center the preview image)
            y: {
                let headerHeight = MobileShell.TopPanelControls.panelHeight;
                let footerHeight = MobileShell.TaskPanelControls.isPortrait ? MobileShell.TaskPanelControls.panelHeight : 0;
                let diff = headerHeight - footerHeight;
                
                let baseY = (taskSwitcher.height / 2) - (height / 2) - (taskSwitcherState.taskHeaderHeight / 2)
                
                return baseY + diff / 2 - MobileShell.TopPanelControls.panelHeight;
            }
            
            // ensure current task is above others
            z: taskSwitcherState.currentTaskIndex === currentIndex ? 1 : 0
            
            // only show header once task switcher is opened
            showHeader: !taskSwitcherState.currentlyBeingOpened
            
            // darken effect as task gets away from the centre of the screen
            darken: {
                let distFromCentreProgress = Math.abs(x - repeater.leftMargin) / taskSwitcherState.taskWidth;
                let upperBoundAdjust = Math.min(0.5, distFromCentreProgress) - 0.2;
                return Math.max(0, upperBoundAdjust);
            }
            
            width: taskSwitcherState.taskWidth
            height: taskSwitcherState.taskHeight
            previewWidth: taskSwitcherState.previewWidth
            previewHeight: taskSwitcherState.previewHeight
            
            taskSwitcher: root.taskSwitcher
            displaysModel: root.taskSwitcher.displaysModel
        }
    }
}
