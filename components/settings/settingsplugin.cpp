/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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

#include "settingsplugin.h"
#include <kdebug.h>

#include <QtDeclarative/qdeclarative.h>

#include "settingsmoduleloader.h"
#include "settingsmodulesmodel.h"

void SettingsPlugin::registerTypes(const char *uri)
{
    //Q_ASSERT(uri == QLatin1String("org.kde.runnermodel"));
    kDebug() << " ======================== SettingsModulePlugin: " << uri;
    qmlRegisterType<SettingsModuleLoader>(uri, 0, 1, "Settings");
    qmlRegisterType<SettingsModulesModel>(uri, 0, 1, "SettingsModulesModel");
    qmlRegisterType<SettingsModulesItem>(uri, 0, 1, "SettingsModulesItem");
}

#include "settingsplugin.moc"

