/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import org.kde.plasma.core 2.0 as PlasmaCore

pragma Singleton

QtObject {
    id: root
    property real panelHeight: PlasmaCore.Units.gridUnit + PlasmaCore.Units.smallSpacing // set and updated in panel containment
}
