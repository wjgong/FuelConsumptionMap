#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "gpxwriter.h"

static QObject *tieto_gpx_writer_provider(QQmlEngine *engine,
                                          QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    GpxWriter *gpxWriter = new GpxWriter();
    return gpxWriter;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterSingletonType<GpxWriter>("tieto.project.fuelmap", 1, 0, "GPXWriter",
                                      tieto_gpx_writer_provider);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
