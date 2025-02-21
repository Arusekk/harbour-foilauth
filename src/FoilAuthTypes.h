/*
 * Copyright (C) 2021 Jolla Ltd.
 * Copyright (C) 2021 Slava Monich <slava@monich.com>
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

#ifndef FOILAUTH_TYPES_H
#define FOILAUTH_TYPES_H

#define FOILAUTH_TYPE_TOTP          "totp"
#define FOILAUTH_TYPE_HOTP          "hotp"
#define FOILAUTH_TYPE_DEFAULT       FOILAUTH_TYPE_TOTP

#define FOILAUTH_ALGORITHM_MD5      "MD5"
#define FOILAUTH_ALGORITHM_SHA1     "SHA1"
#define FOILAUTH_ALGORITHM_SHA256   "SHA256"
#define FOILAUTH_ALGORITHM_SHA512   "SHA512"
#define FOILAUTH_ALGORITHM_DEFAULT  FOILAUTH_ALGORITHM_SHA1

class FoilAuthTypes {
public:
    enum AuthType {
        AuthTypeTOTP,
        AuthTypeHOTP
    };

    enum DigestAlgorithm {
        DigestAlgorithmMD5,
        DigestAlgorithmSHA1,
        DigestAlgorithmSHA256,
        DigestAlgorithmSHA512
    };

    static const AuthType DEFAULT_AUTH_TYPE = AuthTypeTOTP;
    static const DigestAlgorithm DEFAULT_ALGORITHM = DigestAlgorithmSHA1;
    static const int DEFAULT_DIGITS = 6;
    static const int DEFAULT_COUNTER = 0;
    static const int DEFAULT_TIMESHIFT = 0;
};

#endif // FOILAUTH_TYPES_H
