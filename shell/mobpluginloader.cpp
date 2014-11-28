/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
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

#include "mobpluginloader.h"
#include "mobileactivitythumbnails/mobileactivitythumbnails.h"

#include <Plasma/DataEngine>

MobPluginLoader::MobPluginLoader()
    : Plasma::PluginLoader()
{
}

MobPluginLoader::~MobPluginLoader()
{
}

MobileActivityThumbnails *MobPluginLoader::activityThumbnails() const
{
    return m_activityThumbnails.data();
}

Plasma::DataEngine* MobPluginLoader::internalLoadDataEngine(const QString &name)
{
    if (name == "org.kde.mobileactivitythumbnails") {
        if (!m_activityThumbnails) {
            m_activityThumbnails = new MobileActivityThumbnails(0, QVariantList());
        }
        return m_activityThumbnails.data();
    } else {
        return 0;
    }
}