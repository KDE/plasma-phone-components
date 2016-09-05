/*
 *   Copyright 2016 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.activities 0.1 as Activities

ListView {
    id: listView
    model: Activities.ActivityModel {
        id: activityModel
    }
    highlight: PlasmaComponents.Highlight {}
    delegate: PlasmaComponents.Label {
        text: model.name
        width: listView.width
        MouseArea {
            anchors.fill: parent
            onClicked: {
                listView.currentIndex = index;
                activityModel.setCurrentActivity(model.id, function() {});
            }
        }
    }
}