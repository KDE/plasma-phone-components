/*
 *   Copyright 2014 Marco Martin <notmart@gmail.com>
 *             2020 Devin Lin <espidev@gmail.com
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

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQml.Models 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.kirigami 2.12 as Kirigami

SortFilterModel {
    id: pinnedSettings
    
    property int startIndex
    property int endIndex
    property var settingsComponent
    
    filterAcceptsItem: (item) => item.index <= endIndex && item.index >= startIndex;
    lessThan: (left, right) => left.index < right.index;
    model: settingsComponent.model
    
    delegate: QuickSettingsDelegate {
        id: delegateItem
        size: quickSettingsPanel.quickSettingSize
        textVisibility: quickSettingsPanel.allSettingsOpacity
        
        Connections {
            target: delegateItem
            onCloseRequested: settingsComponent.closeRequested();
        }
        Connections {
            target: settingsComponent
            onClosed: delegateItem.panelClosed();
        }
    }
}
