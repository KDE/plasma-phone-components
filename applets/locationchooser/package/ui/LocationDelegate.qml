/*   vim:set foldenable foldmethod=marker:
 *
 *   Copyright (C) 2012 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.1 as QML

import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

PlasmaComponents.ListItem {
    id: main
    enabled: true
    opacity: 1-Math.abs(x)/width
    signal removeAsked

    /* property declarations --------------------------{{{ */
    property alias title: label.text
    /* }}} */

    /* signal declarations ----------------------------{{{ */
    /* }}} */

    /* JavaScript functions ---------------------------{{{ */
    /* }}} */

    /* object properties ------------------------------{{{ */
    /* }}} */

    /* child objects ----------------------------------{{{ */
    PlasmaComponents.Label {
        id: label

        elide: QML.Text.ElideRight
        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 8 + iconClose.width
        }
    }

    QML.MouseArea {
        anchors.fill: parent

        onClicked: main.clicked()

        onPressAndHold: {
            // show actions...
        }
        drag {
            target: main
            axis: QML.Drag.XAxis
        }
        onReleased: {
            if (main.x < -main.width/2) {
                removeAnimation.exitFromRight = false
                removeAnimation.running = true
            } else if (main.x > main.width/2 ) {
                removeAnimation.exitFromRight = true
                removeAnimation.running = true
            } else {
                resetAnimation.running = true
            }
        }
    }

    PlasmaCore.SvgItem {
        id: iconClose

        svg: configIconsSvg
        elementId: "close"
        width: theme.mediumIconSize
        height: theme.mediumIconSize
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: 12
        }
        QML.MouseArea {
            anchors.fill: parent
            onClicked: {
                removeAnimation.running = true
            }
        }
    }

    QML.SequentialAnimation {
        id: removeAnimation
        property bool exitFromRight: true
        QML.NumberAnimation {
            target: main
            properties: "x"
            to: removeAnimation.exitFromRight ? main.width : -main.width
            duration: 250
            easing.type: QML.Easing.InQuad
        }
        QML.NumberAnimation {
            target: main
            properties: "height"
            to: 0
            duration: 250
            easing.type: QML.Easing.InOutQuad
        }
        QML.ScriptAction {
            script: removeAsked()
        }
    }
    QML.SequentialAnimation {
        id: resetAnimation
        QML.NumberAnimation {
            target: main
            properties: "x"
            to: 0
            duration: 250
            easing.type: QML.Easing.InOutQuad
        }
    }
    /* }}} */

    /* states -----------------------------------------{{{ */
    /* }}} */

    /* transitions ------------------------------------{{{ */
    /* }}} */
}
