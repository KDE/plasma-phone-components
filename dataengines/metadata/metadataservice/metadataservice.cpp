/*
 *   Copyright 2010 Chani Armitage <chani@kde.org>
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "metadataservice.h"
#include "metadatajob.h"

#include <KDE/KActivities/Consumer>

MetadataService::MetadataService(const QString &resourceUrl)
    : m_resourceUrl(resourceUrl)
{
    setName("metadataservice");
    m_activityConsumer = new KActivities::Consumer(this);
}

ServiceJob *MetadataService::createJob(const QString &operation,
                                           QMap<QString, QVariant> &parameters)
{
    return new MetadataJob(m_activityConsumer, m_resourceUrl, operation, parameters, this);
}

#include "metadataservice.moc"