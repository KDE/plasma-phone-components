/*
    SPDX-FileCopyrightText: 2021 Devin Lin <eespidev@gmail.com>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1

import "providers"

PlasmaCore.IconItem {
    id: paIcon
    required property VolumeProvider provider
    
    Layout.fillHeight: true
    Layout.preferredWidth: height
    source: provider.icon

    colorGroup: PlasmaCore.ColorScope.colorGroup

    visible: provider.isVisible
}
