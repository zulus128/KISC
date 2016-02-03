//
//  GTViewController.m
//  InitialRegistration
//
//  Created by renat.karimov on 2/14/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#import "GTViewController.h"

@interface GTViewController ()
- (int) createRequestWithUrl:(NSString *)url;
- (int) sendRequest;
- (int) verifyResponseWithUrl:(NSString *)url;
@end

@implementation GTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.textViewTask.layer.cornerRadius = 10.0f;
    self.textViewTask.layer.masksToBounds = YES;
    self.textViewTask.layer.borderColor = [[UIColor blackColor] CGColor];
    self.textViewTask.layer.borderWidth = 1.0f;

    self.textViewLog.layer.cornerRadius = 10.0f;
    self.textViewLog.layer.masksToBounds = YES;
    self.textViewLog.layer.borderColor = [[UIColor blackColor] CGColor];
    self.textViewLog.layer.borderWidth = 1.0f;
    
    self.buttonExecute.layer.cornerRadius = 10.0f;
    self.buttonExecute.layer.masksToBounds = YES;
    self.buttonExecute.layer.borderColor = [[UIColor blackColor] CGColor];
    self.buttonExecute.layer.borderWidth = 1.0f;
    
    self.buttonClose.layer.cornerRadius = 10.0f;
    self.buttonClose.layer.masksToBounds = YES;
    self.buttonClose.layer.borderColor = [[UIColor blackColor] CGColor];
    self.buttonClose.layer.borderWidth = 1.0f;
    
    self.textFieldUserIdentifier.placeholder = [NSString stringWithFormat:@"ID конверта, например: %@", @"KISCd490775c"/*CMP_USER_ID*/];
    self.textFieldSecret.placeholder = [NSString stringWithFormat:@"Секрет, например: %@", @"aa7fc547"/*CMP_USER_SECRET*/];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    SAFERELEASE(_scrollView);
    SAFERELEASE(_textViewTask);
    SAFERELEASE(_textFieldUserIdentifier);
    SAFERELEASE(_textFieldSecret);
    SAFERELEASE(_buttonExecute);
    SAFERELEASE(_textViewLog);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - Keyboard

- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height + keyboardSize.height);
}

- (void)keyboardDidHide:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height - keyboardSize.height);
}

#pragma mark - Events

- (IBAction)close:(id)sender {
    
    [self.view removeFromSuperview];
}

- (IBAction)execute:(id)sender {
    @try {
        // Окончание ввода данных
        [self.view endEditing:YES];
        
        logMessage(@"Logging - %@\n", [NSDate date]);
        logMessage(@"Data directory: %@\n", DATA_DIRECTORY);
        
        // Загрузка и проверка лицензии
        if (initLicense()) {
            return;
        }
        
        // Формирование URL для доступа к самым актуальному ключу, который содержится в ключевом контейнере
        NSString *param = @"";
        if ([DEVICE isEqualToString:@"file"]) {
            #if TARGET_IPHONE_SIMULATOR
                // На симуляторе корневой директорией для TumarCSP является "/"
                param = [NSString stringWithFormat:@"%@/", DATA_DIRECTORY];
            #else
                // На устройстве корневой директорией для TumarCSP является "директория Documents приложения"
                param = @"/";
            #endif
        } else if ([DEVICE isEqualToString:@"kztoken"]) {
            param = @"iCard Reader";
        } else {
            logMessage(@"Unknown device: %@\n", DEVICE);
            return;
        }
        NSString *url = createUrl(@"keyContainer", DEVICE, KEY_CONTAINER_NAME, DEVICE_PASSWORD, param, KEY_CONTAINER_EXTENSION, CALG_EC256_512G_A_Xch, CALG_EC256_512G_A, NULL, 0);
        logMessage(@"URL: %@\n", url);

        if ([DEVICE isEqualToString:@"file"]) {
            // Проверка наличия ключевого контейнера
            NSString *keyPath = [NSString stringWithFormat:@"%@/%@.%@", [NSString stringWithFormat:@"%@/", DATA_DIRECTORY], KEY_CONTAINER_NAME, KEY_CONTAINER_EXTENSION];
            if ([[NSFileManager defaultManager] fileExistsAtPath:keyPath]) {
                // Вывод всех URL для доступа к ключам
                if (printUrlsToKeys(url)) {
                    return;
                }
            }
        }

        // Проверка входных данных
        if (self.textFieldUserIdentifier.text == nil || self.textFieldUserIdentifier.text.length == 0 || self.textFieldSecret.text == nil || self.textFieldSecret.text.length == 0) {
            logMessage(@"Please, set user identifier and secret\n");
            return;
        }
        // Формирование запроса
        if ([self createRequestWithUrl:url]) {
            return;
        }
        // Отправка запроса
        if ([self sendRequest]) {
            return;
        }
        if ([DEVICE isEqualToString:@"file"]) {
            // Проверка наличия ключевого контейнера
            NSString *keyPath = [NSString stringWithFormat:@"%@/%@.%@", [NSString stringWithFormat:@"%@/", DATA_DIRECTORY], KEY_CONTAINER_NAME, KEY_CONTAINER_EXTENSION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:keyPath]) {
                logMessage(@"File \"%@\" not found. Please, put key file by this path\n", keyPath);
                return;
            }
        }
        // Проверка ответа сервера
        if ([self verifyResponseWithUrl:url]) {
            return;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception description: %@", [exception description]);
    }
    @finally {
        self.textViewLog.text = readLogFile();
        deleteLogFile();
    }
}

#pragma mark - Logic

- (int) createRequestWithUrl:(NSString *)url {
    HCRYPTPROV hProv = 0;
    HCRYPTKEY hKey = 0;
    HCRYPTKEY hExpKey = 0;
    @try {
        unsigned char request[8196];
        char transactionId[128];
        DWORD len = 0;
        ALG_ID algId = 0;

        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, (char *)[url UTF8String], CRYPT_NEWKEYSET, NULL)) {
            logMessage(@"CPAcquireContext Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        // Создание ключа подписи
        if (!CPGenKey(hProv, CALG_EC256_512G_A, CRYPT_EXPORTABLE, &hKey)) {
            logMessage(@"CPGenKey CALG_EC256_512G_A Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Создание ключа экспорта запроса CMP/Initialization Request
        if (!CPGenKey(hProv, CALG_CMP_KEY, CRYPT_EXPORTABLE, &hExpKey)) {
            logMessage(@"CPGenKey CALG_CMP_KEY Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Установка алгоритма формирования ключа
        algId = CALG_SHA_160;
        if (!CPSetKeyParam(hProv, hExpKey, KP_CMP_HASH_ALG, (BYTE *)&algId, 0)) {
            logMessage(@"CPSetKeyParam KP_CMP_HASH_ALG Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Установка алгоритма защиты с общим секретом
        algId = CALG_SHA_160_HMAC;
        if (!CPSetKeyParam(hProv, hExpKey, KP_CMP_MAC_ALG, (BYTE *)&algId, 0)) {
            logMessage(@"CPSetKeyParam KP_CMP_MAC_ALG Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Установка идентификатора пользователя
        if (!CPSetKeyParam(hProv, hExpKey, KP_CMP_SND_KID, (BYTE *)[self.textFieldUserIdentifier.text UTF8String], 0)) {
            logMessage(@"CPSetKeyParam KP_CMP_SND_KID Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Установка секрета
        if (!CPSetKeyParam(hProv, hExpKey, KP_CMP_SECRET, (BYTE *)[self.textFieldSecret.text UTF8String], 0)) {
            logMessage(@"CPSetKeyParam KP_CMP_SECRET Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Формирование запроса
        len = sizeof(request);
        if (!CPExportKey(hProv, hKey, hExpKey, PUBLICKEYBLOB_CMP, 0, request, &len)) {
            logMessage(@"CPExportKey PUBLICKEYBLOB_CMP Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Сохранение запроса
        if (writeFile((char *) [INITIALIZATION_REQUEST_PATH UTF8String], request, (long)len)) {
            logMessage(@"Request not saved to \"%@\"\n", INITIALIZATION_REQUEST_PATH);
            return -1;
        }
        //
        CPDestroyKey(hProv, hKey);
        hKey = 0;
        // Проверка полученного запроса
        if (!CPImportKey(hProv, request, len, 0, 0, &hKey)) {
            logMessage(@"CPImportKey request Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Вывод идентификатора транзакции сформированного запроса
        len = sizeof(transactionId);
        if (!CPGetKeyParam(hProv, hKey, KP_CMP_TRANS_ID, (BYTE *)transactionId, &len, 0)) {
            logMessage(@"CPGetKeyParam KP_CMP_TRANS_ID Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        transactionId[len] = 0;
        logMessage(@"Request transaction identifier: %s\n", (char *)transactionId);
        return 0;
    }
    @finally {
        if (hKey != 0) {
            CPDestroyKey(hProv, hKey);
        }
        if (hExpKey != 0) {
            CPDestroyKey(hProv, hExpKey);
        }
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }
}

- (int) sendRequest {
    GTNetwork *network = nil;
    long responseSize = 0;
    unsigned char *response = NULL;
    @try {
        long size = 8196;
        unsigned char *request = (unsigned char *) calloc(size + 1, sizeof(unsigned char));
        NSString *requestPath = INITIALIZATION_REQUEST_PATH;
        NSString *responsePath = INITIALIZATION_RESPONSE_PATH;
        int headerSize = HEADER_SIZE_7;
        NSString *host = @"91.195.226.33";//CMP_TCP_HOST;
        int port = 62260;//CMP_TCP_PORT;
        
        logMessage(@"Request path: %@\n", requestPath);
        logMessage(@"Response path: %@\n", responsePath);
        logMessage(@"Header size: %d\n", headerSize);
        logMessage(@"Host: %@\n", host);
        logMessage(@"Port: %d\n", port);
        
        // Проверка наличия запроса
        if (![[NSFileManager defaultManager] fileExistsAtPath:requestPath]) {
            logMessage(@"Request \"%@\" not found. Please, put request by this path\n", requestPath);
            return -1;
        }
        
        // Загрузка запроса
        if (getFileLen((char *)[requestPath UTF8String], &size)) {
            logMessage(@"Get file length error\n");
            return -1;
        }
        if (readFile((char *)[requestPath UTF8String], request, size)) {
            logMessage(@"Read file error\n");
            return -1;
        }
        network = [[GTNetwork alloc] init];
        [network processRequest:request withRequestSize:size withHeaderSize:headerSize onHost:host withPort:port withResponse:&response withResponseSize:&responseSize];
        
        // Сохранение ответа
        if (writeFile((char *) [responsePath UTF8String], response, (long)responseSize)) {
            logMessage(@"Response not saved to \"%@\"\n", responsePath);
            return -1;
        }
        return 0;
    }
    @finally {
        SAFERELEASE(network);
    }
}

- (int) verifyResponseWithUrl:(NSString *)url {
    HCRYPTPROV hProv = 0;
    HCRYPTKEY hKey = 0;
    HCRYPTKEY hImpKey = 0;
    @try {
        unsigned char response[8196];
        unsigned char cert[8196];
        long sz = 0;
        DWORD len = 0;
        DWORD dw = 0;
        char transactionId[128];
        
        // Проверка наличия ответа сервера
        if (![[NSFileManager defaultManager] fileExistsAtPath:INITIALIZATION_RESPONSE_PATH]) {
            logMessage(@"File \"%@\" not found. Please, put response file by this path\n", INITIALIZATION_RESPONSE_PATH);
            return -1;
        }
        // Загрузка ответа сервера
        if (getFileLen((char *)[INITIALIZATION_RESPONSE_PATH UTF8String], &sz)) {
            logMessage(@"Get file length error\n");
            return -1;
        }
        if (readFile((char *)[INITIALIZATION_RESPONSE_PATH UTF8String], response, sz)) {
            logMessage(@"Read file error\n");
            return -1;
        }
        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, (char *)[url UTF8String], 0, NULL)) {
            logMessage(@"CPAcquireContext Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        // Проверка ответа сервера
        if (!CPImportKey(hProv, response, (DWORD)sz, 0, 0, &hKey)) {
            logMessage(@"CPImportKey response Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Получение типа ответа
        len = sizeof(dw);
        if (!CPGetKeyParam(hProv, hKey, KP_CMP_TYPE, (BYTE *)&dw, &len, 0)) {
            logMessage(@"CPGetKeyParam KP_CMP_TYPE Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Получен ответ с ошибкой обработки
        if (dw == PKI_CMP_ERROR) {
            logMessage(@"PKI_CMP_ERROR\n");
            return -1;
        }
        // Получен неправильный ответ
        if (dw != PKI_CMP_IP) {
            logMessage(@"Unknown CMP TYPE: %u\n", dw);
            return -1;
        }
        // Получение идентификатора транзакции ответа
        len = sizeof(transactionId);
        if (!CPGetKeyParam(hProv, hKey, KP_CMP_TRANS_ID, (BYTE *)transactionId, &len, 0)) {
            logMessage(@"CPGetKeyParam KP_CMP_TRANS_ID Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        transactionId[len] = 0;
        logMessage(@"Response transaction identifier: %s\n", transactionId);
        // Создание ключа для проверки ответа
        if (!CPGenKey(hProv, CALG_CMP_KEY, CRYPT_EXPORTABLE, &hImpKey)) {
            logMessage(@"CPGenKey CALG_CMP_KEY Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Установка секрета
        if (!CPSetKeyParam(hProv, hImpKey, KP_CMP_SECRET, (BYTE *)[self.textFieldSecret.text UTF8String], 0)) {
            logMessage(@"CPSetKeyParam KP_CMP_SECRET Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Проверка подлинности ответа сервера на общем секрете
        if (!CPVerifySignature(hProv, 0, response, (DWORD)sz, hImpKey, NULL, CRYPT_OBJECT_CMP)) {
            logMessage(@"CPVerifySignature response Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Получение статуса ответа
        len = sizeof(dw);
        if (!CPGetKeyParam(hProv, hKey, KP_CMP_STATUS, (BYTE *)&dw, &len, 0)) {
            logMessage(@"CPGetKeyParam KP_CMP_STATUS Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        logMessage(@"KP_CMP_STATUS: %d\n", dw);
        if (dw == WAITING) {
            // Запрос ожидает обработки
            
            logMessage(@"Request pending\n");
        } else if (dw == ACCEPTED || dw == GRANTED_WITH_MODS) {
            // Запрос обработан
            
            logMessage(@"Request processed\n");
            //
            CPDestroyKey(hProv, hKey);
            hKey = 0;
            // Получение ключа на подпись
            if (!CPGetUserKey(hProv, AT_SIGNATURE, &hKey)) {
                logMessage(@"CPGetUserKey AT_SIGNATURE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            // Установка сертификата
            if (!CPSetKeyParam(hProv, hKey, KP_CERTIFICATE, response, 0)) {
                logMessage(@"CPSetKeyParam KP_CERTIFICATE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            // Установка сертификата УЦ
            if (!CPSetKeyParam(hProv, hKey, KP_CERTIFICATE_CA, response, 0)) {
                logMessage(@"CPSetKeyParam KP_CERTIFICATE_CA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            // Получение сертификата пользователя
            len = sizeof(cert);
            if (!CPGetKeyParam(hProv, hKey, KP_CERTIFICATE, cert, &len, 0)) {
                logMessage(@"CPGetKeyParam KP_CERTIFICATE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            // Сохранение сертификата пользователя
            if (writeFile((char *) [USER_CERTIFICATE_PATH UTF8String], cert, (long)len)) {
                logMessage(@"User certificate not saved to \"%@\"\n", USER_CERTIFICATE_PATH);
                return -1;
            }
            // Получение сертификата Центра Сертификации
            len = sizeof(cert);
            if (!CPGetKeyParam(hProv, hKey, KP_CERTIFICATE_CA, cert, &len, 0)) {
                logMessage(@"CPGetKeyParam KP_CERTIFICATE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            // Сохранение сертификата Центра Сертификации
            if (writeFile((char *) [CA_CERTIFICATE_PATH UTF8String], cert, (long)len)) {
                logMessage(@"CA certificate not saved to \"%@\"\n", USER_CERTIFICATE_PATH);
                return -1;
            }
        }
        return 0;
    }
    @finally {
        if (hKey != 0) {
            CPDestroyKey(hProv, hKey);
        }
        if (hImpKey != 0) {
            CPDestroyKey(hProv, hImpKey);
        }
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }

}

@end
