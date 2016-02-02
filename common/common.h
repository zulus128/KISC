//
//  common.h
//
//  Created by renat.karimov on 2/13/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#ifndef __common_h
#define __common_h

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include <sys/stat.h>
#include <pwd.h>

#include "cptumar.h"
#include "tdefs.h"
#include "wdefs.h"

/**
 * Безопасное удаление объекта.
 * Сообщение, посланное объекту со значением nil, вернет nil
 */
#define SAFERELEASE(O) [(O) release]; (O) = nil;

/**
 * Безопасное удаление объекта.
 * "Для избежания повреждения кучи некоторые руководства по языку Си рекомендуют обнулять каждый освобождаемый указатель." - взято из wikipedia.org
 */
#define SAFEFREE(O) free((O)); (O) = NULL;

// Если какие-то данные отличаются от Ваших, то измените их
#define CMP_USER_ID @"test" // Идентификатор пользователя
#define CMP_USER_SECRET @"1234567890" // Секрет пользователя

#define DATA_FOR_TSP @"ABCD"
#define TSP_POLICY "1.2.3"

#define DATA_FOR_PKCS7 @"EFGH"

// Электронная цифровая подпись в формате PKCS#7
#define PKCS7_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"pkcs7.p7b"]

// Электронная цифровая подпись в формате PKCS#7 c вложенной TimeStamp квитанцией
#define PKCS7_WITH_TIMESTAMP_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"pkcs7WithTimestamp.p7b"]

#define DEVICE @"file" // file - если необходимо использовать ключ на файловой системе. kztoken - если необходимо использовать ключ на JaCarta
#define DEVICE_PASSWORD @"1234567890" // Пароль для доступа к ключевому контейнеру

// Директория с данными
#if TARGET_IPHONE_SIMULATOR
    // На симуляторе корневой директорией для TumarCSP является "/"
    #define DATA_DIRECTORY userDirectory()
#else
    // На устройстве корневой директорией для TumarCSP является "директория Documents приложения"
    #define DATA_DIRECTORY applicationDocumentsDirectory()
#endif

#define LICENSE_NAME @"cptumar.reg" // Имя файла лицензии
#define KEY_CONTAINER_NAME @"key" // Наименование ключевого контейнера
#define KEY_CONTAINER_EXTENSION @"p12" // Расширение ключевого контейнера

#define CMP_TCP_HOST @"192.168.5.5" // Хост, на котором запущена служба CMP
#define CMP_TCP_PORT 62295 // Порт, к которому привязана служба CMP
// Запросы, отправляемые на службу CMP, и ответы, получаемые со службы CMP
#define INITIALIZATION_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"initializationRequest.bin"]
#define INITIALIZATION_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"initializationResponse.bin"]
#define CERTIFICATION_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"certificationRequest.bin"]
#define CERTIFICATION_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"certificationResponse.bin"]
#define POLLING_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"pollingRequest.bin"]
#define POLLING_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"pollingResponse.bin"]
#define REVOCATION_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"revocationRequest.bin"]
#define REVOCATION_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"revocationResponse.bin"]
#define CRL_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"crlRequest.bin"]
#define CRL_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"crlResponse.bin"]
#define TRANSFER_TO_DEPOSIT_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"transferToDepositRequest.bin"]
#define TRANSFER_TO_DEPOSIT_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"transferToDepositResponse.bin"]
#define REMOVE_FROM_DEPOSIT_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"removeFromDepositRequest.bin"]
#define REMOVE_FROM_DEPOSIT_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"removeFromDepositResponse.bin"]

#define OCSP_TCP_HOST @"192.168.5.5" // Хост, на котором запущена служба OCSP
#define OCSP_TCP_PORT 62265 // Порт, к которому привязана служба OCSP
// Запросы, отправляемые на службу OCSP, и ответы, получаемые со службы OCSP
#define OCSP_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"ocspRequest.bin"]
#define OCSP_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"ocspResponse.bin"]

#define TSP_TCP_HOST @"192.168.5.5" // Хост, на котором запущена служба TSP
#define TSP_TCP_PORT 62275 // Порт, к которому привязана служба TSP
// Запросы, отправляемые на службу TSP, и ответы, получаемые со службы TSP
#define TSP_REQUEST_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"tspRequest.bin"]
#define TSP_RESPONSE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"tspResponse.bin"]

// Данные
#define USER_CERTIFICATE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"userCertificate.cer"] // Сертификат пользователя
#define CA_CERTIFICATE_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"caCertificate.cer"] // Корневой сертификат
#define CRL_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"crl.crl"] // Список отозванных сертификатов

// PKIStatus
#define ACCEPTED 0
#define GRANTED_WITH_MODS 1
#define REJECTION 2
#define WAITING 3
#define REVOCATION_WARNING 4
#define REVOCATION_NOTIFICATION 5
#define KEY_UPDATE_WARNING 6

#define LOG_PATH [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, @"log.txt"] // Путь, по которому будет формироваться лог-файл

/**
 * Инициализация криптопровайдера. Необходимо вызывать всегда и только один раз при запуске программы.
 */
void _csp_init(void);

/**
 * Проверка существования директории
 *
 * @param path Путь к директории
 * @return YES, если директория существует, иначе NO
 */
BOOL isDirectoryExists(NSString *path);

/**
 * Получение пути до директории $HOME
 *
 * @return Путь до директории $HOME
 */
NSString* userDirectory(void);

/**
 * Получение пути до директории Documents
 *
 * @return Путь до директории Documents
 */
NSString* applicationDocumentsDirectory(void);

/**
 * Получение размера файла
 *
 * @param path Путь к файлу. in
 * @param size Размер файла. out
 * @return если вернулся 0, то операция успешно завершена, иначе ошибка
 */
int getFileLen(char *path, long *size);

/**
 * Чтение данных из файла
 *
 * @param path Путь к файлу. in
 * @param Mass Данные из файла. out
 * @param size Размер файла. in
 * @return если вернулся 0, то операция успешно завершена, иначе ошибка
 */
int readFile(char *path, unsigned char *Mass, long szMass);

/**
 * Запись файла
 *
 * @param path Путь к файлу. in
 * @param Mass Данные для записи. in
 * @param size Размер файла. in
 * @return если вернулся 0, то операция успешно завершена, иначе ошибка
 */
int writeFile(char *path, unsigned char *Mass, long szMass);

/**
 * Получение кода ошибки
 *
 * @param hProv Хендл на криптопровайдер
 * @return Код ошибки
 */
DWORD GetLastErrorCSP(HCRYPTPROV hProv);

/**
 * Инициализация лицензии
 *
 * @return если вернулся 0, то операция успешно завершена, иначе ошибка
 */
int initLicense(void);

/**
 * Формирование URL на ключ
 *
 * @param name Имя профайла
 * @param dev Устройство хранения.
 *            Используется при создании профайла, если профайла с таким именем не существует.
 *            Например, существуют следующие типы устройств:
 *            1) file;
 *            2) artoken;
 *            3) g-token;
 *            4) j-token;
 *            5) idcard;
 *            6) kztoken;
 *            7) picard;
 *            8) etokenpro.
 *            Примеры:
 *            1) file используется для создания профайла указывающего на ключ, хранящийся на файловой системе;
 *            2) kztoken используется для создания профайла указывающего на ключ, хранящийся на eToken PRO (Java);
 *            3) kztoken используется для создания профайла указывающего на ключ, хранящийся на KazToken;
 *            4) j-token используется для создания профайла указывающего на ключ, хранящийся на eToken PRO.
 *            Для устройств, работающих на iOS, можно указывать только "file".
 * @param user Имя ключевого контейнера
 * @param pass Пароль для доступа к ключевому контейнеру
 * @param param Параметр устройства хранения.
 *              Примеры:
 *              1) для ключевого контейнера на файловой системе (устройство хранения - file):
 *                1.1) путь к директории, где находится ключевой контейнер.
 *              2) для устройства eToken PRO (устройство хранения - j-token):
 *                2.1) 0, где 0 - это первое устройство, соединенное с компьютером;
 *                2.2) 1, где 1 - это второе устройство, соединенное с компьютером;
 *                2.3) ...;
 *                2.4) n, где n - это n-ое устройство, соединенное с компьютером.
 *              3) для устройства eToken PRO (Java) (устройство хранения - kztoken):
 *                3.1) Aladdin Token JC 0</b>, где Aladdin Token JC 0 - это первое устройство, соединенное с компьютером;
 *                3.2) Aladdin Token JC 1</b>, где Aladdin Token JC 0 - это второе устройство, соединенное с компьютером;
 *                3.3) ...;
 *                3.4) Aladdin Token JC n</b>, где Aladdin Token JC n - это n-ое устройство, соединенное с компьютером.
 *              4) для устройства KazToken (устройство хранения - kztoken):
 *                4.1) DigiFlow LLP. KAZTOKEN 0, где DigiFlow LLP. KAZTOKEN 0 - это первое устройство, соединенное с компьютером;
 *                4.2) DigiFlow LLP. KAZTOKEN 1, где DigiFlow LLP. KAZTOKEN 1 - это второе устройство,
 *                 соединенное с компьютером;
 *                4.3) ...;
 *                4.4) DigiFlow LLP. KAZTOKEN n, где DigiFlow LLP. KAZTOKEN n - это n-ое устройство, соединенное с компьютером.
 * @param cont Формат ключевого контейнера. Возможные форматы:
 *              1) bin;
 *              2) pfx;
 *              3) p12;
 *              4) pem.
 * @param algExch Алгоритм на ключевой обмен.
 *                Например, существуют следующие алгоритмы на ключевой обмен:
 *                1) "1.3.6.1.4.1.6801.1.8.2" - 0xA042;
 *                2) "1.3.6.1.4.1.6801.1.8.3" - 0xA043;
 *                3) "1.3.6.1.4.1.6801.1.8.4" - 0xA044;
 *                4) "1.3.6.1.4.1.6801.1.8.1" - 0xA04B;
 *                5) "1.3.6.1.4.1.6801.1.8.8" - 0xA045;
 *                6) "1.3.6.1.4.1.6801.1.8.14" - 0xA046;
 *                7) "1.3.6.1.4.1.6801.1.8.9" - 0xA049;
 *                8) "1.3.6.1.4.1.6801.1.8.10" - 0xA047;
 *                9) "1.3.6.1.4.1.6801.1.8.15" - 0xA048;
 *                10) "1.3.6.1.4.1.6801.1.8.20" - 0xA050;
 *                11) "1.3.6.1.4.1.6801.1.8.21" - 0xA051;
 *                12) "1.3.6.1.4.1.6801.1.8.22" - 0xA052;
 *                13) "1.3.6.1.4.1.6801.1.8.23" - 0xA053;
 *                14) "1.3.6.1.4.1.6801.1.8.24" - 0xA054.
 *                 </ul>
 * @param algSign Алгоритм на подпись.
 *                Например, существуют следующие алгоритмы на подпись:
 *                1) "1.3.6.1.4.1.6801.1.5.1" - 0xAA32;
 *                2) "1.3.6.1.4.1.6801.1.5.2" - 0xAA33;
 *                3) "1.3.6.1.4.1.6801.1.5.3" - 0xAA34;
 *                4) "1.3.6.1.4.1.6801.1.5.4" - 0xAA35;
 *                5) "1.3.6.1.4.1.6801.1.5.5" - 0xAA36;
 *                6) "1.3.6.1.4.1.6801.1.4.4" - 0xAA21;
 *                7) "1.3.6.1.4.1.6801.1.5.12" - 0xAA3E;
 *                8) "1.3.6.1.4.1.6801.1.5.13" - 0xAA3F;
 *                9) "1.3.6.1.4.1.6801.1.5.16" - 0xAA49;
 *                10) "1.3.6.1.4.1.6801.1.5.8" - 0xAA3A;
 *                11) "1.3.6.1.4.1.6801.1.5.14" - 0xAA40;
 *                12) "1.3.6.1.4.1.6801.1.5.15" - 0xAA41;
 *                13) "1.3.6.1.4.1.6801.1.5.9" - 0xAA3B;
 *                14) "1.3.6.1.4.1.6801.1.5.10" - 0xAA3C;
 *                15) "1.3.6.1.4.1.6801.1.5.11" - 0xAA3D;
 *                16) "1.3.6.1.4.1.6801.1.5.20" - 0xA450;
 *                17) "1.3.6.1.4.1.6801.1.5.21" - 0xA451;
 *                18) "1.3.6.1.4.1.6801.1.5.22" - 0xA452;
 *                19) "1.3.6.1.4.1.6801.1.5.23" - 0xA453;
 *                20) "1.3.6.1.4.1.6801.1.5.24" - 0xA454.
 * @param sn Серийный номер сертификата
 * @param snSize Размер серийного номера сертификата
 * @return URL для доступа к ключу
 * @exception NSException Исключение
 */
NSString* createUrl(NSString *name, NSString *dev, NSString *user, NSString *pass, NSString *param, NSString *cont, int algExch, int algSign, unsigned char *sn, int snSize);

/**
 * Вывод всех URL для доступа к ключам
 * @param sn URL для доступа к самым актуальным ключам
 *
 * @return если вернулся 0, то операция успешно завершена, иначе ошибка
 */
int printUrlsToKeys(NSString *url);

/**
 * Вывод в лог-файл и на консоль
 *
 * @param format Формат. in
 * @param ... Параметры
 * @return если вернулся 0, то операция успешно завершена, иначе ошибка
 */
int logMessage(NSString *format, ...);

/**
 * Чтение содержимого лог-файла
 *
 * @return Содержимое лог-файла
 */
NSString* readLogFile(void);

/**
 * Удаление лог-файла
 */
void deleteLogFile(void);

#endif
