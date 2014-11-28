/*********************************************************************/
/* Copyright 2010 by Marco Martin <mart@kde.org>                     */
/*                                                                   */
/* This program is free software; you can redistribute it and/or     */
/* modify it under the terms of the GNU General Public License       */
/* as published by the Free Software Foundation; either version 2    */
/* of the License, or (at your option) any later version.            */
/*                                                                   */
/* This program is distributed in the hope that it will be useful,   */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of    */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     */
/* GNU General Public License for more details.                      */
/*                                                                   */
/* You should have received a copy of the GNU General Public License */
/* along with this program; if not, write to the Free Software       */
/* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA     */
/* 02110-1301, USA.                                                  */
/*********************************************************************/

#ifndef APPLETSCONTAINER_H
#define APPLETSCONTAINER_H

#include <QGraphicsWidget>
#include <QList>
#include <QMap>

namespace Plasma
{
    class AbstractToolBox;
    class Applet;
    class Containment;
    class IconWidget;
}

class QGraphicsLinearLayout;
class QTimer;

class AppletsOverlay;
class InputBlocker;

class AppletsContainer : public QGraphicsWidget
{
    Q_OBJECT
    friend class AppletsView;

public:
    AppletsContainer(QGraphicsItem *parent, Plasma::Containment *containment);
    ~AppletsContainer();

    void setCurrentApplet(Plasma::Applet *applet);
    Plasma::Applet *currentApplet() const;

    Plasma::Containment *containment() const;

    void setAppletsOverlayVisible(const bool visible);
    bool isAppletsOverlayVisible() const;

    void relayoutApplet(Plasma::Applet *, const QPointF &post);

    void completeStartup();

    void setOrientation(const Qt::Orientation orientation);
    Qt::Orientation orientation() const;

public Q_SLOTS:
    void layoutApplet(Plasma::Applet *applet, const QPointF &post);
    void appletRemoved(Plasma::Applet*);
    void hideAppletsOverlay();
    void repositionToolBox();

protected:
    void syncOverlayGeometry();

    //reimp
    void resizeEvent(QGraphicsSceneResizeEvent *event);

protected Q_SLOTS:
    void relayout();

private:
    QGraphicsLinearLayout *m_layout;
    Plasma::Containment *m_containment;
    Plasma::AbstractToolBox *m_toolBox;
    QTimer *m_relayoutTimer;
    QWeakPointer<Plasma::Applet> m_currentApplet;
    AppletsOverlay *m_appletsOverlay;
    InputBlocker *m_inputBlocker;
    QList<Plasma::Applet *> m_applets;
    //used only at restore, then thrown away
    QMap<int, Plasma::Applet *>m_startingApplets;
    bool m_startupCompleted;
    Qt::Orientation m_orientation;
};

#endif