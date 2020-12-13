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

Control {
    id: quickSettingsPanel
    
    // 0 - closed, 1 - pinned settings visible, 2 - all settings visible
    property double stateGradient
    property int panelState
    
    property int quickSettingSize: Kirigami.Units.gridUnit * 3
    property double allSettingsOpacity: stateGradient > 1 ? stateGradient - 1 : 0
    
    property int pinnedColumns: 5 // number of columns when pinned settings are visible
    property int columns: 4 // number of columns when all settings are visible
    property int rows: 2
    
    implicitWidth: parent.implicitWidth
    height: {
        let baseHeight = quickSettingSize + Kirigami.Units.gridUnit * 4;
        if (stateGradient <= 1) {
            return baseHeight;
        } else {
            return baseHeight + (quickSettingSize * 6 - baseHeight) * (stateGradient - 1);
        }
    }
    implicitHeight: height
    clip: true
    
    leftPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

    // panel background
    background: Rectangle {
        id: container
        color: Kirigami.ColorUtils.adjustColor(PlasmaCore.Theme.backgroundColor, {"alpha": 0.9*255})
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.largeSpacing
        radius: PlasmaCore.Units.smallSpacing
    }
    
    QuickSettings {
        id: quickSettings
        onCloseRequested: {
            slidingPanel.hide()
        }
    }
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }
    
    // pinned settings model
    SortFilterModel {
        id: pinnedSettingsShown
        filterAcceptsItem: (item) => item.index < quickSettingsPanel.columns;
        lessThan: (left, right) => left.index < right.index;
        model: quickSettings.model
        
        delegate: QuickSettingsDelegate {
            id: delegateItem
            size: quickSettingsPanel.quickSettingSize
            textVisibility: quickSettingsPanel.allSettingsOpacity
            
            Connections {
                target: delegateItem
                onCloseRequested: quickSettings.closeRequested();
            }
            Connections {
                target: quickSettings
                onClosed: delegateItem.panelClosed();
            }
        }
    }
    
    // pinned settings 2 model
    SortFilterModel {
        id: pinnedSettingsToHide
        filterAcceptsItem: (item) => item.index < quickSettingsPanel.pinnedColumns && item.index >= quickSettingsPanel.columns;
        lessThan: (left, right) => left.index < right.index;
        model: quickSettings.model
        
        delegate: QuickSettingsDelegate {
            id: delegateItem
            size: quickSettingsPanel.quickSettingSize
            opacity: 1 - 4 * (quickSettingsPanel.stateGradient - 1)
            visible: quickSettingsPanel.stateGradient < 1.5
            textVisibility: quickSettingsPanel.allSettingsOpacity
            
            Connections {
                target: delegateItem
                onCloseRequested: quickSettings.closeRequested();
            }
            Connections {
                target: quickSettings
                onClosed: delegateItem.panelClosed();
            }
        }
    }
    
    // actual panel contents
    contentItem: ColumnLayout {
        id: panelContent
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Kirigami.Units.largeSpacing
            leftMargin: Kirigami.Units.gridUnit
            rightMargin: Kirigami.Units.gridUnit
        }
        
        property int fullIconSpacing: (panelContent.width - quickSettingsPanel.quickSettingSize * quickSettingsPanel.columns) / (quickSettingsPanel.columns + 1)
        property double iconSpacing: {
            let pinnedSpacing = (panelContent.width - quickSettingsPanel.quickSettingSize * quickSettingsPanel.pinnedColumns) / (quickSettingsPanel.pinnedColumns + 1);
            if (quickSettingsPanel.stateGradient <= 1) {
                return pinnedSpacing;
            } else {
                return pinnedSpacing + (fullIconSpacing - pinnedSpacing) * (stateGradient - 1);
            }
        }
        spacing: Kirigami.Units.largeSpacing
        
        // time text
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: Qt.formatTime(timeSource.data["Local"]["DateTime"], root.is24HourTime ? "h:mm" : "h:mm ap")
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                text: Qt.formatDateTime(timeSource.data["Local"]["DateTime"], "ddd MMMM d")
                horizontalAlignment: Text.AlignRight
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
            }
        }
        
        // quick settings
        SwipeView {
            id: quickSettingsView
            currentIndex: 0
            Layout.fillWidth: true
            clip: true
            
            // first page is special, as it has pinned
            ColumnLayout {
                id: firstPage
                Layout.fillWidth: true
                spacing: panelContent.fullIconSpacing
                // pinned row of delegates
                RowLayout {
                    spacing: panelContent.iconSpacing
                    Layout.leftMargin: spacing
                    Repeater {
                        model: pinnedSettingsShown
                    }
                    Repeater {
                        model: pinnedSettingsToHide
                    }
                }
                
                // rows below
                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: columnSpacing
                    Layout.rightMargin: columnSpacing
                    columnSpacing: panelContent.fullIconSpacing
                    rowSpacing: panelContent.fullIconSpacing - Kirigami.Units.smallSpacing
                    columns: quickSettingsPanel.columns
                    opacity: quickSettingsPanel.allSettingsOpacity
                    
                    SettingsRowModel {
                        id: rowModel
                        startIndex: columns
                        endIndex: (columns*rows)-1
                        settingsComponent: quickSettings
                    }
                    
                    Repeater {
                        model: rowModel
                    }
                }
            }
            
            // other pages
            Repeater {
                implicitHeight: firstPage.height
                implicitWidth: firstPage.width
                model: Math.floor(quickSettings.model.count / (columns * rows))
                
                Item {
                    implicitHeight: firstPage.height
                    implicitWidth: grid.width
                    Layout.leftMargin: panelContent.fullIconSpacing
                    SettingsRowModel {
                        id: rowModel
                        startIndex: (index + 1) * (quickSettingsPanel.columns*quickSettingsPanel.rows)
                        endIndex: (index + 2) * (quickSettingsPanel.columns*quickSettingsPanel.rows) - 1
                        settingsComponent: quickSettings
                    }
                    
                    GridLayout {
                        id: grid
                        implicitHeight: firstPage.height
                        columnSpacing: panelContent.fullIconSpacing
                        rowSpacing: panelContent.fullIconSpacing - Kirigami.Units.smallSpacing
                        columns: quickSettingsPanel.columns
                        rows: quickSettingsPanel.rows
                        opacity: quickSettingsPanel.allSettingsOpacity
                        
                        Repeater {
                            model: rowModel
                        }
                    }
                }
            }
        }
        
        PageIndicator {
            count: quickSettingsView.count
            currentIndex: quickSettingsView.currentIndex
            Layout.alignment: Qt.AlignCenter
        }

        // brightness slider
        BrightnessItem {
            opacity: quickSettingsPanel.allSettingsOpacity
            id: brightnessSlider
            width: quickSettingsPanel.implicitWidth
            icon: "video-display-brightness"
            label: i18n("Display Brightness")
            value: quickSettings.screenBrightness
            maximumValue: quickSettings.maximumScreenBrightness
            onMoved: quickSettings.screenBrightness = brightnessSlider.value
            Connections {
                target: quickSettings
                onScreenBrightnessChanged: brightnessSlider.value = quickSettings.screenBrightness
            }
        }
    }
}
