/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

#include "qmlappletscript.h"
#include "../bindings/plasmabindings.h"

#include <QDeclarativeComponent>
#include <QDeclarativeEngine>
#include <QGraphicsLinearLayout>

#include <KGlobalSettings>
#include <KConfigGroup>
#include <KDebug>

#include <Plasma/Applet>

K_EXPORT_PLASMA_APPLETSCRIPTENGINE(qmlscripts, QmlAppletScript)

extern void setupBindings();

class QmlAppletScriptPrivate
{
public:
    QmlAppletScriptPrivate(QmlAppletScript* appletScript) :
          engine(0), component(0),
          loaded(false), q(appletScript)
    {
    }

    void errorPrint();
    void execute(const QUrl &fileName);
    void finishExecute();
    QDeclarativeEngine* engine;
    QDeclarativeComponent* component;

    bool loaded;
    QmlAppletScript* q;
};

void QmlAppletScriptPrivate::errorPrint()
{
    loaded=false;
    QString errorStr = "Error loading QML file.\n";
    if(component->isError()){
        QList<QDeclarativeError> errors = component->errors();
        foreach (const QDeclarativeError &error, errors) {
            errorStr += (error.line()>0?QString::number(error.line()) + ": ":"")
                + error.description() + '\n';
        }
    }
    kWarning() << errorStr;
}

void QmlAppletScriptPrivate::execute(const QUrl &fileName)
{
    if (fileName.isEmpty())
      return;
    if (engine)
      delete engine;
    if (component)
      delete component;
    
    engine = new QDeclarativeEngine(q);
    component = new QDeclarativeComponent(engine, fileName, q);

    if(component->isReady() || component->isError())
        finishExecute();
    else
        QObject::connect(component, SIGNAL(statusChanged(QDeclarativeComponent::Status)), q, SLOT(finishExecute()));
}

void QmlAppletScriptPrivate::finishExecute()
{
    if(component->isError()) {
        errorPrint();
    }
    QObject *root = component->create();
    if (!root) {
        errorPrint();
    }
    QGraphicsLayoutItem *layoutItem = dynamic_cast<QGraphicsLayoutItem*>(root);
    if (layoutItem) {
        QGraphicsLinearLayout* layout = new QGraphicsLinearLayout(q->applet());
        layout->setContentsMargins(0, 0, 0, 0);
        layout->setSpacing(0);
        layout->addItem(layoutItem);
        q->applet()->setLayout(layout);
        QObject *object = dynamic_cast<QObject *>(layoutItem);
        if (object)
            object->setParent(q->applet());
    } else {
        //TODO It's a QDeclarativeItem
    }
}

QmlAppletScript::QmlAppletScript(QObject *parent, const QVariantList &args)
    : Plasma::AppletScript(parent), d(new QmlAppletScriptPrivate(this))
{
    setupBindings();
    Q_UNUSED(args);
}

QmlAppletScript::~QmlAppletScript()
{
    delete d;
}

bool QmlAppletScript::init()
{
    d->execute(mainScript());
    return true;
}

#include "qmlappletscript.moc"

