/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "mobview.h"
#include "mobcorona.h"
#include "plasmaapp.h"

#include <QAction>
#include <QCoreApplication>
#include <QDBusConnection>

#include <KWindowSystem>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/Corona>
#include <Plasma/Containment>

#ifndef QT_NO_OPENGL
#include <QtOpenGL/QtOpenGL>
#endif

MobView::MobView(Plasma::Containment *containment, int uid, QWidget *parent)
    : Plasma::View(containment, uid, parent),
      m_useGL(false),
      m_direction(Plasma::Up)
{
    setFocusPolicy(Qt::NoFocus);
    setWindowFlags(windowFlags());
    connectContainment(containment);
    //setOptimizationFlags(QGraphicsView::DontSavePainterState);
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setAttribute(Qt::WA_OpaquePaintEvent);
    setAttribute(Qt::WA_NoSystemBackground);
    viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewport()->setAttribute(Qt::WA_NoSystemBackground);
    setFrameStyle(0);
    setViewportUpdateMode(QGraphicsView::BoundingRectViewportUpdate);
    setAttribute(Qt::WA_TranslucentBackground, false);

    setTrackContainmentChanges(false);
}

MobView::~MobView()
{
}

void MobView::setUseGL(const bool on)
{
#ifndef QT_NO_OPENGL
    if (on) {
      QGLWidget *glWidget = new QGLWidget;
      glWidget->setAutoFillBackground(false);
      setViewport(glWidget);
    }
#endif
    m_useGL = on;
}

bool MobView::useGL() const
{
    return m_useGL;
}

void MobView::connectContainment(Plasma::Containment *containment)
{
    if (!containment) {
        return;
    }

    connect(containment, SIGNAL(activate()), this, SIGNAL(containmentActivated()), Qt::UniqueConnection);
    connect(this, SIGNAL(sceneRectAboutToChange()), this, SLOT(updateGeometry()), Qt::UniqueConnection);
    setWindowTitle(containment->activity());
}

void MobView::setContainment(Plasma::Containment *c)
{
    if (Plasma::Containment * oldCont = containment()) {
        disconnect(oldCont, 0, this, 0);
    }

    Plasma::View::setContainment(c);
    connectContainment(c);
    updateGeometry();
}

void MobView::drawBackground(QPainter *painter, const QRectF &rect)
{
    Q_UNUSED(painter)
    Q_UNUSED(rect)
    //don't do anything
}


bool MobView::event(QEvent *event)
{
    if (event->type() == QEvent::WindowActivate) {
        setFocus();
    }
    return Plasma::View::event(event);
}

void MobView::resizeEvent(QResizeEvent *event)
{
    Q_UNUSED(event)
    updateGeometry();
    emit geometryChanged();
}

void MobView::showEvent(QShowEvent *event)
{
    Q_UNUSED(event)
#ifdef Q_WS_X11
    Display *dpy = QX11Info::display();
    Atom atom = XInternAtom(dpy, "_KDE_FIRST_IN_WINDOWLIST", False);
    QVarLengthArray<long, 1> data(1);
    data[0] = 1;
    XChangeProperty(dpy, winId(), atom, atom, 32, PropModeReplace,
                    reinterpret_cast<unsigned char *>(data.data()), data.size());
#endif
}

void MobView::closeEvent(QCloseEvent *event)
{
    Q_UNUSED(event)
    event->ignore();
}

Plasma::Location MobView::location() const
{
    return containment()->location();
}

Plasma::FormFactor MobView::formFactor() const
{
    return containment()->formFactor();
}

void MobView::updateGeometry()
{
    Plasma::Containment *c = containment();
    if (!c) {
        return;
    }

    kDebug() << "New containment geometry is" << c->geometry();

    switch (c->location()) {
    case Plasma::TopEdge:
    case Plasma::BottomEdge:
        setMinimumWidth(0);
        setMaximumWidth(QWIDGETSIZE_MAX);
        setFixedHeight(c->size().height());
        emit locationChanged(this);
        break;
    case Plasma::LeftEdge:
    case Plasma::RightEdge:
        setMinimumHeight(0);
        setMaximumHeight(QWIDGETSIZE_MAX);
        setFixedWidth(c->size().width());
        emit locationChanged(this);
        break;
    //ignore changes in the main view
    default:
        break;
    }

    if (c->size().toSize() != size()) {
        c->setMaximumSize(size());
        c->setMinimumSize(size());
        c->resize(size());
    }
}

#include "mobview.moc"

