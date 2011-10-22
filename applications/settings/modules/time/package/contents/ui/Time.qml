// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1

Rectangle {
    id: timeModule
    objectName: "timeModule"

    TimeSettings {
        id: timeSettings
    }

    width: 800; height: 500
    //color: theme.backgroundColor

    PlasmaCore.Theme {
        id: theme
    }
    /*
    MobileComponents.Package {
        id: activeSettingsTime
        name: "org.kde.active.settings.time"
    }
    */
    /*
    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.margins: 10
        color: "orange"
        opacity: 0.2

    }
    */
    Column {
        anchors.fill: parent
        spacing: 12
        Text {
            color: theme.textColor
            text: "<h1>" + moduleTitle + "</h1>"
            opacity: 1
        }
        Text {
            color: theme.textColor
            text: moduleDescription
            //opacity: 1
        }
        Row {
            spacing: 8
            anchors.margins: 32

            anchors.verticalCenter: okButton.verticalCenter
            Text {
                color: theme.textColor
                text: i18n("Use 24-hour clock:")
                //opacity: 1
            }
            PlasmaWidgets.PushButton {
                id: okButton
                checkable: true
                checked: timeSettings.twentyFour

                text: timeSettings.twentyFour ? i18n("Enabled") : i18n("Disabled");
                onClicked : {
                    //print("24??" + checked);
                    timeSettings.twentyFour = checked
                }
            }
        }


    }
    Text {
        color: theme.textColor
        anchors.centerIn: parent
        text: "<h2> " + timeSettings.currentTime+ "</h2>"
        //opacity: 1
    }

    Component.onCompleted: {
        print("Time.qml done loading.");
        //print("settingsObject.name" + timeSettings.name);
    }
}
