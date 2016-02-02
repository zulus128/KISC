//
//  common.m
//
//  Created by renat.karimov on 2/13/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#include "common.h"

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

BOOL isDirectoryExists(NSString *path) {
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL isDir;
    BOOL fileExists = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (fileExists && isDir) {
        return YES;
    }
    return NO;
}

NSString* userDirectory(void) {
//    NSString* realHomeDir = nil;
//    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
//        uid_t uid = getuid();
//        struct passwd *pw = getpwuid(uid);
//        realHomeDir = [NSString stringWithUTF8String:pw->pw_dir];
//    } else {
//        char *login = getlogin();
//        NSString *userName = [NSString stringWithUTF8String:login];
//        realHomeDir = [NSString stringWithFormat:@"/Users/%@", userName];
//        if (!isDirectoryExists(realHomeDir)) {
//            @throw [NSException exceptionWithName:@"commonException" reason:@"Please, set user directory in common.m in function userDirectory" userInfo:nil];
//        }
//    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *realHomeDir = paths.firstObject;
    return realHomeDir;
}

NSString* applicationDocumentsDirectory(void) {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

int getFileLen(char *path, long *size) {
    struct stat st;
    if (stat(path, &st)) {
        return -1;
    }
    (*size) = (long)st.st_size;
    return 0;
}

int readFile(char *path, unsigned char *Mass, long szMass) {
    int inf = 0;
    #ifdef WIND32
        if ((inf = open(path, O_RDONLY|O_BINARY)) == (-1)) {
            return -1;
        }
    #else
        if ((inf = open(path, O_RDONLY)) == (-1)) {
            return -1;
        }
    #endif
    if (read(inf, Mass, szMass) != szMass) {
        close(inf);
        return -2;
    }
    close(inf);
    return 0;
}

int writeFile(char *path, unsigned char *Mass, long szMass) {
    int ouf = 0;
    unlink(path);
    #ifdef WIND32
        _fmode = O_BINARY;
        #ifdef _MSC_VER
        if ((ouf = _creat(path, S_IWRITE)) < 0) {
            return -1;
        }
        #else
        if ((ouf = creat(path, S_IRUSR|S_IWUSR)) < 0) {
            return -1;
        }
        #endif
    #else
        if ((ouf = creat(path, S_IRUSR|S_IWUSR)) < 0) {
            return -1;
        }
    #endif
    if (write(ouf, Mass, szMass) != szMass) {
        close(ouf);
        return -2;
    }
    close(ouf);
    return 0;
}

DWORD GetLastErrorCSP(HCRYPTPROV hProv) {
    DWORD code = 0;
    DWORD len = sizeof(DWORD);
    if (!CPGetProvParam(hProv, PP_LAST_ERROR, (BYTE*)&code, &len, 0)) {
        CPGetProvParam(0, PP_LAST_ERROR, (BYTE*)&code, &len, 0);
    }
    return code;
}

int initLicense(void) {
    HCRYPTPROV hProv = 0;
    @try {
        USERLICENSE license;
        DWORD len = 0;
        
        NSString *licensePath = nil;
        #if TARGET_IPHONE_SIMULATOR
            // На симуляторе корневой директорией для TumarCSP является "/"
            licensePath = [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, LICENSE_NAME];
        #else
            // На устройстве корневой директорией для TumarCSP является "директория Documents приложения"
            licensePath = [NSString stringWithFormat:@"/%@", LICENSE_NAME];
        #endif
        // Вывод пути к лицензии
        logMessage(@"License will be loaded from file: \"%@\".\n", [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, LICENSE_NAME]);
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, LICENSE_NAME]]) {
            logMessage(@"File \"%@\" not found. Please, put license file by this path\n", [NSString stringWithFormat:@"%@/%@", DATA_DIRECTORY, LICENSE_NAME]);
            return -1;
        }
        // Загрузка лицензии
        if (!CPSetProvParam(0, PP_LICENSE_FILE, (BYTE *)[licensePath UTF8String], 0)) {
            logMessage(@"CPSetProvParam Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        len = sizeof(license);
        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, NULL, CRYPT_VERIFYCONTEXT, NULL)) {
            logMessage(@"CPAcquireContext Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        // Получение лицензии
        if (!CPGetProvParam(hProv, PP_ENUM_LICENSES, (BYTE *)&license, &len, CRYPT_FIRST)) {
            logMessage(@"CPGetProvParam Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Вывод информацию о лицензии
        logMessage(@"License. Created: %s. Expires: %s. Level: %s. Name: %s. User: %s\n", license.Created, license.Expires, license.Level, license.Name, license.User);
        return 0;
    }
    @finally {
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }
    return 0;
}

NSString* createUrl(NSString *name, NSString *dev, NSString *user, NSString *pass, NSString *param, NSString *cont, int algExch, int algSign, unsigned char *sn, int snSize) {
    DWORD cbData = 0;
    ContInfoEx contInfoEx;
    HCRYPTPROV hProv = 0;
    @try {
        strcpy(contInfoEx.name, [name UTF8String]);
        strcpy(contInfoEx.dev, [dev UTF8String]);
        strcpy(contInfoEx.user, [user UTF8String]);
        strcpy(contInfoEx.pass, [pass UTF8String]);
        strcpy(contInfoEx.param, [param UTF8String]);
        strcpy(contInfoEx.cont, [cont UTF8String]);
        memcpy(contInfoEx.sn, sn, snSize);
        contInfoEx.sn_size = snSize;
        contInfoEx.alg_exch = algExch;
        contInfoEx.alg_sign = algSign;
        cbData = sizeof(ContInfoEx);
        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, NULL, CRYPT_VERIFYCONTEXT, NULL)) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:GetLastErrorCSP(0)], @"code", nil];
            @throw [NSException exceptionWithName:@"commonException" reason:@"CPAcquireContext CRYPT_VERIFYCONTEXT error" userInfo:dictionary];
        }
        // Получение URL
        if (!CPGetProvParam(hProv, PP_PROF_TO_URL, (BYTE *)&contInfoEx, &cbData, 0)) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:GetLastErrorCSP(hProv)], @"code", nil];
            @throw [NSException exceptionWithName:@"commonException" reason:@"CPGetProvParam PP_PROF_TO_URL error" userInfo:dictionary];
        }
        return [[[NSString alloc] initWithUTF8String:contInfoEx.Url] autorelease];
    }
    @finally {
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }
    return nil;
}

int printUrlsToKeys(NSString *url) {
    HCRYPTPROV hProv = 0;
    HCRYPTKEY hKey = 0;
    @try {
        DWORD dw = 0;
        DWORD len = 0;
        CNT_PRIVATE_KEY privateKey;
        int counter = 0;
        
        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, (char *)[url UTF8String], 0, NULL)) {
            logMessage(@"CPAcquireContext Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        // Получение количества ключей, находящихся в ключевом контейнере
        len = sizeof(dw);
        if (!CPGetProvParam(hProv, PP_CNT_KEYS_COUNT, (BYTE *)&dw, &len, CRYPT_FIRST)) {
            logMessage(@"CPGetProvParam PP_CNT_KEYS_COUNT Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        len = sizeof(privateKey);
        if (CPGetProvParam(hProv, PP_ENUM_CNT_PRIV_KEYS, (BYTE *)&privateKey, &len, CRYPT_FIRST)) {
            do {
                // Формирование URL для доступа к ключу по серийному номеру
                NSString *param = @"";
                #if TARGET_IPHONE_SIMULATOR
                    // На симуляторе корневой директорией для TumarCSP является "/"
                    param = [NSString stringWithFormat:@"%@/", DATA_DIRECTORY];
                #else
                    // На устройстве корневой директорией для TumarCSP является "директория Documents приложения"
                    param = @"/";
                #endif
                NSString *urlToKey = createUrl(@"keyContainer", DEVICE, KEY_CONTAINER_NAME, @"", param, KEY_CONTAINER_EXTENSION, CALG_EC256_512G_A_Xch, CALG_EC256_512G_A, privateKey.serialNum.pbData, privateKey.serialNum.cbData);
                logMessage(@"URL %d: %@\n", counter, urlToKey);
                len = sizeof(privateKey);
                counter++;
            } while(CPGetProvParam(hProv, PP_ENUM_CNT_PRIV_KEYS, (BYTE *)&privateKey, &len, 0));
        }
        return 0;
    }
    @finally {
        if (hKey != 0) {
            CPDestroyKey(hProv, hKey);
        }
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }
    return 0;
}

int logMessage(NSString *format, ...) {
    NSString* formattedMessage = nil;
    FILE *pFile = NULL;
    @try {
        pFile = fopen([LOG_PATH UTF8String], "a");
        if (pFile == NULL) {
            return -1;
        }
        va_list argList;
        va_start(argList, format);
        formattedMessage = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);
        NSLog(@"%@", formattedMessage);
        fprintf(pFile, "%s", [formattedMessage UTF8String]);
        NSString *separator = @"----------------------------------------------------\n";
        fprintf(pFile, "%s", [separator UTF8String]);
        return 0;
    }
    @finally {
        if (pFile != NULL) {
            fclose(pFile);
        }
        SAFERELEASE(formattedMessage);
    }
}

NSString* readLogFile(void) {
    return [NSString stringWithContentsOfFile:LOG_PATH encoding:NSUTF8StringEncoding error:NULL];
}

void deleteLogFile(void) {
    remove([LOG_PATH UTF8String]);
}