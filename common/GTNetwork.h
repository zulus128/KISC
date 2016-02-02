//
//  GTNetwork.h
//
//  Created by renat.karimov on 2/13/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#define CMP_TCP_VER 10
#ifndef drct_l
#define drct_l(l) l=(((l<<24)|(l>>8))&0xFF00FF00)|(((l<<8)|(l>>24))&0x00FF00FF)
#endif
#define HEADER_SIZE_0 0
#define HEADER_SIZE_5 5
#define HEADER_SIZE_7 7
#define DIFF_BETWEEN_HEADER_SIZES 2

/**
 * Сетевые коммуникации
 *
 * Размеры заголовков для различных форматов сообщений
 * TSP/OCSP
 * -RFC 3161 (Time-Stamp Protocol (TSP)) http://www.ietf.org/rfc/rfc3161.txt
 * --3.3. Socket Based Protocol
 * ---header size is 5
 *
 * APP
 * ---header size is 5
 *
 * CMP
 * -draft-ietf-pkix-cmp-transport-protocols-10.txt (Transport Protocols for CMP) http://tools.ietf.org/html/draft-ietf-pkix-cmp-transport-protocols-10
 * --4. TCP-Based Management Protocol
 * ---header size is 7
 *
 * CMC
 * -RFC 5273 (Certificate Management over CMS (CMC): Transport Protocols) http://tools.ietf.org/html/rfc5273
 * --5. TCP-Based Protocol
 * ---header size is 0
 */

#include <netinet/in.h>
#include <netdb.h>

@interface GTNetwork : NSObject

/**
 * Создание дескриптора сокета и соединение с хостом
 *
 * @param host Хост. Например, 192.168.1.3
 * @param port Порт. Например, 62295
 * @return Дескриптор сокета
 * @exception NSException Исключение
 */
- (int)createSocketDescriptorAndConnectToHost:(NSString *)host withPort:(int)port;

/**
 * Закрытие дескриптора сокета
 *
 * @param socketDescriptor Дескриптор сокета
 */
- (void)closeSocketDescriptor:(int)socketDescriptor;

/**
 * Запись данных в сокет (отправка данных на сервер)
 *
 * @param request Запрос
 * @param size Размер запроса
 * @param headerSize Размер заголовка запроса
 * @param socketDescriptor Дескриптор сокета
 * @return Количество отправленных байт
 * @exception NSException Исключение
 */
- (long)sendRequest:(unsigned char *)request withSize:(long)size andHeaderSize:(int)headerSize usingSocketDescriptor:(int)socketDescriptor;

/**
 * Чтение буфера данных с сокета
 *
 * @param buffer Буфер
 * @param size Размер буфера
 * @param socketDescriptor Дескриптор сокета
 * @return Количество прочитанных байтов
 */
- (long)retryReadBuffer:(unsigned char *)buffer withSize:(long)size usingSocketDescriptor:(int)socketDescriptor;

/**
 * Чтение строки с сокета
 *
 * @param line Строка
 * @param socketDescriptor Дескриптор сокета
 * @exception NSException Исключение
 */
- (void)readLine:(char **)line usingSocketDescriptor:(int)socketDescriptor;

/**
 * Чтение буфера данных с сокета
 *
 * @param buffer Буфер
 * @param size Размер буфера
 * @param socketDescriptor Дескриптор сокета
 * @exception NSException Исключение
 */
- (void)readBytes:(unsigned char *)bytes withSize:(long)size usingSocketDescriptor:(int)socketDescriptor;

/**
 * Запись буфера данных в сокет
 *
 * @param buffer Буфер
 * @param size Размер буфера
 * @param socketDescriptor Дескриптор сокета
 * @exception NSException Исключение
 */
- (void)writeBytes:(const unsigned char *)bytes withSize:(long)size usingSocketDescriptor:(int)socketDescriptor;

/**
 * Чтение данных с сокета (получение данных с сервера)
 * @param response Ответ
 * @param size Размер ответ
 * @param socketDescriptor Дескриптор сокета
 * @exception NSException Исключение
 */
- (void)receiveResponse:(unsigned char **)response withSize:(long *)size usingSocketDescriptor:(int)socketDescriptor;

/**
 * Процесс отправки запроса и получения ответа. Включает в себя этапы:
 * 1) cоздание дескриптора сокета и соединение с хостом;
 * 2) запись данных в сокет (отправка данных на сервер);
 * 3) чтение данных с сокета (получение данных с сервера);
 * 4) закрытие дескриптора сокета.
 *
 * @param request Запрос.
 * @param requestSize Размер запроса.
 * @param headerSize Размер заголовка запроса
 * @param host Хост. Например, 192.168.1.3
 * @param port Например, 62295
 * @param response Ответ. Память на ответ выделяется внутри класса и освобождается в методе dealloc
 * @param responseSize Размер ответа.
 * @exception NSException Исключение
 */
- (void)processRequest:(unsigned char *)request withRequestSize:(long)requestSize withHeaderSize:(int)headerSize onHost:(NSString *)host withPort:(int)port withResponse:(unsigned char **)response withResponseSize:(long *)responseSize;

@end
