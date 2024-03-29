#ifndef SQLPLUGIN_H
#define SQLPLUGIN_H

#include <QDebug>
#include <QJsonArray>
#include <QList>
#include <QObject>
#include <QQmlListProperty>
#include <QQmlPropertyMap>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlResult>
#include <QVariant>
#include <QVector>
#include <QtQml>
class SqlPlugin : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool initDB READ initDB NOTIFY databaseOpened)
    Q_PROPERTY(QString dbName READ dbName WRITE setDbName NOTIFY dbNameChanged)
    Q_PROPERTY(QString hostname READ hostname WRITE setHostName NOTIFY hostNameChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString driver READ driver WRITE setDriver NOTIFY driverChanged)
public:

    explicit SqlPlugin(QObject *parent = nullptr);

    QString dbName();
    void setDbName(QString name);

    QString driver();
    void setDriver(QString value);

    QString hostname() const;
    void setHostName(QString host);

    QString username() const;
    void setUsername(QString usernam);

    QString password() const;
    void setPassword(QString pass);

    bool initDB(){
        if(_opened){
            return true;
        }
        return _opened;
    }

    void close();

    Q_INVOKABLE void open();
    Q_INVOKABLE QMap<QString, QVariant> execute(QString queryText);
    Q_INVOKABLE QVariant records() const;
signals:
    void dbNameChanged();
    void databaseOpened();
    void driverChanged();
    void recordsChanged();
    void usernameChanged();
    void passwordChanged();
    void hostNameChanged();

private:
    QSqlDatabase db;

    QString _dbName;
    QString _driver;
    QString _hostname;
    QString _username;
    QString _password;

    QList<QVariant> _records;
    bool _opened=false;

};

#endif // SQLPLUGIN_H
