#ifndef GPXWRITER_H
#define GPXWRITER_H

#include <QObject>
#include <QXmlStreamWriter>
#include <QFile>
#include <QDateTime>
#include <QVariant>

class GpxWriter : public QObject
{
    Q_OBJECT
public:
    explicit GpxWriter(QObject *parent = 0);
    Q_INVOKABLE bool createFile();
    Q_INVOKABLE bool writeCoordinate(double latitude, double longitude,
                                     double altitude, QDateTime timeStamp);
    Q_INVOKABLE void closeFile();

signals:

public slots:

private:
    QXmlStreamWriter xmlWriter;
    QFile xmlFile;
};

#endif // GPXWRITER_H
