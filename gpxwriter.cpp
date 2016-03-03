#include "gpxwriter.h"

GpxWriter::GpxWriter(QObject *parent) : QObject(parent)
{

}

bool GpxWriter::createFile()
{

    QString fileName = QDateTime::currentDateTimeUtc().toString("yyyy-MM-dd_hhmmss");
    if (fileName.isNull())
        return false;

    xmlFile.setFileName("/storage/emulated/0/fuelmap_" + fileName + ".gpx");
    if (!xmlFile.open(QIODevice::WriteOnly | QIODevice::Unbuffered))
        return false;

    xmlWriter.setDevice(&xmlFile);
    xmlWriter.writeStartDocument("1.0");

    xmlWriter.writeStartElement("gpx");
    xmlWriter.writeAttribute("version", "1.0");
    xmlWriter.writeAttribute("creator", "wenjie.gong@tieto.com");
    xmlWriter.writeDefaultNamespace("http://www.topografix.com/GPX/1/1");

    xmlWriter.writeStartElement("metadata");
    xmlWriter.writeTextElement("name", fileName);
    xmlWriter.writeEndElement();    // end "metadata"

    xmlWriter.writeStartElement("trk");
    xmlWriter.writeTextElement("name", "Sequence 1");
//    xmlWriter.writeEmptyElement("desc");
    xmlWriter.writeStartElement("trkseg");

    return true;
}

bool GpxWriter::writeCoordinate(double latitude, double longitude,
                                double altitude, QDateTime timeStamp)
{
    if (!xmlFile.isWritable())
        return false;

    xmlWriter.writeStartElement("trkpt");
    xmlWriter.writeAttribute("lat", QVariant(latitude).toString());
    xmlWriter.writeAttribute("lon", QVariant(longitude).toString());
    xmlWriter.writeTextElement("ele", QVariant(altitude).toString());
    xmlWriter.writeTextElement("time", timeStamp.toUTC().toString(Qt::ISODate));
    xmlWriter.writeEndElement();    // end "trkpt"

    return true;
}

void GpxWriter::closeFile()
{
    xmlWriter.writeEndDocument();
    xmlFile.close();
}
