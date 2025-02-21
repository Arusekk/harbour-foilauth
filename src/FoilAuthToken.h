/*
 * Copyright (C) 2019-2021 Jolla Ltd.
 * Copyright (C) 2019-2021 Slava Monich <slava@monich.com>
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer
 *      in the documentation and/or other materials provided with the
 *      distribution.
 *   3. Neither the names of the copyright holders nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef FOILAUTH_TOKEN_H
#define FOILAUTH_TOKEN_H

#include "FoilAuthTypes.h"

#include <QString>
#include <QByteArray>
#include <QVariantMap>
#include <QList>

class FoilAuthToken : public FoilAuthTypes {
class Private;
public:
    static const QString ALGORITHM_MD5;
    static const QString ALGORITHM_SHA1;
    static const QString ALGORITHM_SHA256;
    static const QString ALGORITHM_SHA512;

    static const int MIN_DIGITS = 1;
    static const int MAX_DIGITS = 9;

    static const QString KEY_VALID;
    static const QString KEY_TYPE;
    static const QString KEY_LABEL;
    static const QString KEY_SECRET;
    static const QString KEY_ISSUER;
    static const QString KEY_DIGITS;
    static const QString KEY_COUNTER;
    static const QString KEY_TIMESHIFT;
    static const QString KEY_ALGORITHM;

    static const QString TYPE_TOTP;
    static const QString TYPE_HOTP;

    FoilAuthToken();
    FoilAuthToken(const FoilAuthToken& aToken);
    FoilAuthToken(AuthType aType, QByteArray aBytes, QString aLabel,
        QString aIssuer, int aDigits = DEFAULT_DIGITS,
        quint64 aCounter = DEFAULT_COUNTER,
        int aTimeShift = DEFAULT_TIMESHIFT,
        DigestAlgorithm aAlgorithm = DEFAULT_ALGORITHM);

    FoilAuthToken& operator=(const FoilAuthToken& aToken);
    bool operator==(const FoilAuthToken& aToken) const;
    bool operator!=(const FoilAuthToken& aToken) const;

    bool isValid() const;
    bool setDigits(int aDigits);
    bool setType(AuthType aType);
    bool setAlgorithm(DigestAlgorithm aAlgorithm);
    bool parseUri(QString aUri);
    uint password(quint64 aTime) const;
    QString passwordString(quint64 aTime) const;
    bool equals(const FoilAuthToken& aToken) const;
    bool equals(const FoilAuthToken* aToken) const;

    QString toUri() const;
    QVariantMap toVariantMap() const;
    QByteArray toProtoBuf() const;

    static QList<FoilAuthToken> fromProtoBuf(const QByteArray& aData);
    static QByteArray toProtoBuf(const QList<FoilAuthToken>& aTokens);
    static QList<QByteArray> toProtoBufs(const QList<FoilAuthToken>& aTokens,
        int aPrefBatchSize = 1000, int aMaxBatchSize = 2000);

public:
    AuthType iType;
    DigestAlgorithm iAlgorithm;
    QByteArray iBytes;
    QString iLabel;
    QString iIssuer;
    quint64 iCounter;
    int iDigits;
    int iTimeShift; // Seconds
};

inline bool FoilAuthToken::isValid() const
    { return !iBytes.isEmpty(); }
inline bool FoilAuthToken::operator==(const FoilAuthToken& aToken) const
    { return equals(aToken); }
inline bool FoilAuthToken::operator!=(const FoilAuthToken& aToken) const
    { return !equals(aToken); }
inline bool FoilAuthToken::equals(const FoilAuthToken* aToken) const
    { return (this == aToken) || (aToken && equals(*aToken)); }

#endif // FOILAUTH_TOKEN_H
