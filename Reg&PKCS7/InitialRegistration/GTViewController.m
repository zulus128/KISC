//
//  GTViewController.m
//  PKCS7
//
//  Created by renat.karimov on 2/14/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#define OID_PKCS9_TIMESTAMPATTR "1.2.840.113549.1.9.16.2.14"

#import "GTViewController.h"

@interface GTViewController ()
- (int) createPkcs7WithUrl:(NSString *)url;
- (int) verifyPkcs7WithUrl:(NSString *)url;
- (int) addTimestampToPkcs7;
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
    
    self.buttonSend.layer.cornerRadius = 10.0f;
    self.buttonSend.layer.masksToBounds = YES;
    self.buttonSend.layer.borderColor = [[UIColor blackColor] CGColor];
    self.buttonSend.layer.borderWidth = 1.0f;
    
    self.textFieldDataForPKCS7.placeholder = [NSString stringWithFormat:@"Данные для ЭЦП, например: %@", DATA_FOR_PKCS7];
    
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
    SAFERELEASE(_segmentedControlSignatureType);
    SAFERELEASE(_textFieldDataForPKCS7);
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

- (IBAction)send:(id)sender {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"ЭЦП"];
    
    //read the file using NSData
    NSData * fileData = [NSData dataWithContentsOfFile:PKCS7_PATH];
    NSString *mimeType = @"unknown/unknown";
    
    //add attachement
    [picker addAttachmentData:fileData mimeType:mimeType fileName:@"pkcs7.p7b"];

    // Fill out the email body text
    NSString *emailBody = @"ЭЦП в аттачменте";
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentModalViewController:picker animated:YES];
    
    [picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    // Notifies users about errors associated with the interface
    switch (result) {
            
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

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
//        NSString *url = createUrl(@"keyContainer", DEVICE, KEY_CONTAINER_NAME, DEVICE_PASSWORD, param, KEY_CONTAINER_EXTENSION, CALG_EC256_512G_A_Xch, CALG_EC256_512G_A, NULL, 0);
        NSString *url = createUrl(@"keyContainer", DEVICE, KEY_CONTAINER_NAME, DEVICE_PASSWORD, param, KEY_CONTAINER_EXTENSION, CALG_EC256_512G_A_Xch, CALG_EC256_512G_A, NULL, 0);
        logMessage(@"URL: %@\n", url);
        
        if ([DEVICE isEqualToString:@"file"]) {
            // Проверка наличия ключевого контейнера
            NSString *keyPath = [NSString stringWithFormat:@"%@/%@.%@", [NSString stringWithFormat:@"%@/", DATA_DIRECTORY], KEY_CONTAINER_NAME, KEY_CONTAINER_EXTENSION];
            if (![[NSFileManager defaultManager] fileExistsAtPath:keyPath]) {
                logMessage(@"File \"%@\" not found. Please, put key file by this path\n", keyPath);
                return;
            }
            // Вывод всех URL для доступа к ключам
            if (printUrlsToKeys(url)) {
                return;
            }
        }
        
        // Проверка входных данных
        if (self.segmentedControlSignatureType.selectedSegmentIndex < 0 || self.textFieldDataForPKCS7.text == nil || self.textFieldDataForPKCS7.text.length == 0) {
            logMessage(@"Please, set signature type and data for PKCS#7\n");
            return;
        }
        // Формирование PKCS#7
        if ([self createPkcs7WithUrl:url]) {
            return;
        }
        // Проверка PKCS#7
        if ([self verifyPkcs7WithUrl:nil]) {
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

- (int) createPkcs7WithUrl:(NSString *)url {
    HCRYPTPROV hProv = 0;
    HCRYPTKEY hKey = 0;
    HCRYPTHASH hHash = 0;
    unsigned char *pkcs7 = NULL;
    @try {
        DWORD len = 0;
        DWORD pkcs7Length = 8196;
        unsigned char cert[8196];
        
        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, (char *)[url UTF8String], 0, NULL)) {
            logMessage(@"CPAcquireContext Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        
        // Получение ключа на подпись
        if (!CPGetUserKey(hProv, AT_SIGNATURE, &hKey)) {
            logMessage(@"CPGetUserKey AT_SIGNATURE Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Получение сертификата пользователя
        len = sizeof(cert);
        if (!CPGetKeyParam(hProv, hKey, KP_CERTIFICATE, cert, &len, 0)) {
            logMessage(@"CPGetKeyParam KP_CERTIFICATE Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Создание хеш-объекта
        if (!CPCreateHash(hProv, CALG_TGR3411, 0, 0, &hHash)) {
            logMessage(@"CPCreateHash CALG_TGR3411 Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Хеширование данных
        len = strlen([self.textFieldDataForPKCS7.text UTF8String]);
        if (!CPHashData(hProv, hHash, (BYTE *)[self.textFieldDataForPKCS7.text UTF8String], len, 0)) {
            logMessage(@"CPHashData data Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Добавление сертификата в PKCS#7
        if (!CPSetHashParam(hProv, hHash, HP_PKCS7_CERTIFICATE, cert, 0)) {
            logMessage(@"CPSetHashParam HP_PKCS7_CERTIFICATE Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        if (self.segmentedControlSignatureType.selectedSegmentIndex == 0) {
            // Формирование присоединенной подписи

            // Добавление подписываемых данных в PKCS#7
            if (!CPSetHashParam(hProv, hHash, HP_PKCS7_DATA_SIZE, (BYTE *)&len, 0)) {
                logMessage(@"CPSetHashParam HP_PKCS7_DATA_SIZE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            if (!CPSetHashParam(hProv, hHash, HP_PKCS7_DATA, (BYTE *)[self.textFieldDataForPKCS7.text UTF8String], 0)) {
                logMessage(@"CPSetHashParam HP_PKCS7_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            pkcs7Length += len;
        }
        
        // Добавление атрибута 1.2.840.113549.1.9.77 в signedAttrs, если необходимо
        NSString *oid = nil; // Необходимо установить @"1.2.840.113549.1.9.77"
        if (oid != nil) {
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9_CUR_OID, (BYTE *)[oid UTF8String], 0)) {
                logMessage(@"CPSetHashParam 1.2.840.113549.1.9.77 HP_PKCS9_CUR_OID Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            NSString *str = @"1234567890, latin characters, кириллица, әіңғүұқөһӘІҢҒҮҰҚӨҺ";
            len = strlen([str UTF8String]);
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9A_SIZE, (BYTE *)&len, 0)) {
                logMessage(@"CPSetHashParam 1.2.840.113549.1.9.77 HP_PKCS9A_SIZE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9A_DATA, (BYTE *)[str UTF8String], 0)) {
                logMessage(@"CPSetHashParam 1.2.840.113549.1.9.77 HP_PKCS9A_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            pkcs7Length += len;
        }
        
        // Добавление метки времени в unsignedAttrs, если необходимо
        NSData *timeStamp = nil; // Необходимо установить метку времени
        if (timeStamp != nil) {
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9_CUR_OID, (BYTE *)OID_PKCS9_TIMESTAMPATTR, 0)) {
                logMessage(@"CPSetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9_CUR_OID Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            len = timeStamp.length;
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9U_SIZE, (BYTE *)&len, 0)) {
                logMessage(@"CPSetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9U_SIZE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9U_DATA, (BYTE *)[timeStamp bytes], 0)) {
                logMessage(@"CPSetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9U_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            pkcs7Length += len;
        }
        
        // Добавление квитанции OCSP в unsignedAttrs, если необходимо
        NSData *ocsp = nil; // Необходимо установить квитанцию OCSP
        if (ocsp != nil) {
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9_CUR_OID, (BYTE *)"1.2.840.113549.1.9.16.2.24", 0)) {
                logMessage(@"CPSetHashParam 1.2.840.113549.1.9.16.2.24 HP_PKCS9_CUR_OID Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            len = ocsp.length;
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9U_SIZE, (BYTE *)&len, 0)) {
                logMessage(@"CPSetHashParam 1.2.840.113549.1.9.16.2.24 HP_PKCS9U_SIZE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9U_DATA, (BYTE *)[ocsp bytes], 0)) {
                logMessage(@"CPSetHashParam 1.2.840.113549.1.9.16.2.24 HP_PKCS9U_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            pkcs7Length += len;
        }
        
        pkcs7Length += 8196;
        pkcs7 = (unsigned char *) calloc(pkcs7Length + 1, sizeof(unsigned char));
        if (!CPSignHash(hProv, hHash, AT_SIGNATURE, NULL, CRYPT_SIGN_PKCS7, pkcs7, &pkcs7Length)) {
            logMessage(@"CPSignHash CRYPT_SIGN_PKCS7 Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Сохранение PKCS#7
        if (writeFile((char *) [PKCS7_PATH UTF8String], pkcs7, (long)pkcs7Length)) {
            logMessage(@"PKCS#7 not saved to \"%@\"\n", PKCS7_PATH);
            return -1;
        }
        return 0;
    }
    @finally {
        if (pkcs7 != NULL) {
            SAFEFREE(pkcs7);
        }
        if (hKey != 0) {
            CPDestroyKey(hProv, hKey);
        }
        if (hHash != 0) {
            CPDestroyHash(hProv, hHash);
        }
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }
}

- (int) addTimestampToPkcs7 {
    HCRYPTPROV hProv = 0;
    HCRYPTHASH hHash = 0;
    unsigned char *pkcs7 = NULL;
    unsigned char *signature = NULL;
    unsigned char *pkcs7WithTimestamp = NULL;
    @try {
        long sz = 0;
        DWORD len = 0;
        DWORD dw = 0;
        DWORD pkcs7WithTimestampLength = 8196;
        
        // Проверка наличия PKCS#7
        if (![[NSFileManager defaultManager] fileExistsAtPath:PKCS7_PATH]) {
            logMessage(@"File \"%@\" not found. Please, put PKCS#7 file by this path\n", PKCS7_PATH);
            return -1;
        }
        // Загрузка PKCS#7
        if (getFileLen((char *)[PKCS7_PATH UTF8String], &sz)) {
            logMessage(@"Get file length error\n");
            return -1;
        }
        pkcs7 = (unsigned char *) calloc(sz + 1, sizeof(unsigned char));
        if (readFile((char *)[PKCS7_PATH UTF8String], pkcs7, sz)) {
            logMessage(@"Read file error\n");
            return -1;
        }
        
        pkcs7WithTimestampLength += sz;
        
        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, NULL, CRYPT_VERIFYCONTEXT, NULL)) {
            logMessage(@"CPAcquireContext CRYPT_VERIFYCONTEXT Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        // Создание хеш-объекта
        if (!CPCreateHash(hProv, CALG_TGR3411, 0, 0, &hHash)) {
            logMessage(@"CPCreateHash CALG_TGR3411 Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Установка проверяемого PKCS#7
        if (!CPSetHashParam(hProv, hHash, HP_PKCS7_BODY, pkcs7, 0)) {
            logMessage(@"CPSetHashParam HP_PKCS7_BODY Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Получение размера подписи
        len = sizeof(dw);
        if (!CPGetHashParam(hProv, hHash, HP_P7SIG_SIZE, (BYTE *)&dw, &len, 0)) {
            logMessage(@"CPGetHashParam HP_P7SIG_SIZE Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Получение подписи
        signature = (BYTE *)calloc(dw, sizeof(BYTE));
        if (!CPGetHashParam(hProv, hHash, HP_P7SIG_VAL, (BYTE *)signature, &dw, 0)) {
            logMessage(@"CPGetHashParam HP_P7SIG_VAL Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Добавление метки времени в unsignedAttrs, если необходимо
        NSData *timeStamp = nil; // Необходимо установить метку времени
        if (timeStamp != nil) {
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9_CUR_OID, (BYTE *)OID_PKCS9_TIMESTAMPATTR, 0)) {
                logMessage(@"CPSetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9_CUR_OID Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            len = timeStamp.length;
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9U_SIZE, (BYTE *)&len, 0)) {
                logMessage(@"CPSetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9U_SIZE Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            if (!CPSetHashParam(hProv, hHash, HP_PKCS9U_DATA, (BYTE *)[timeStamp bytes], 0)) {
                logMessage(@"CPSetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9U_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            pkcs7WithTimestampLength += len;
        }
        
        // Получение PKCS#7
        pkcs7WithTimestamp = (unsigned char *) calloc(pkcs7WithTimestampLength + 1, sizeof(unsigned char));
        if (!CPGetHashParam(hProv, hHash, HP_PKCS7_BODY, (BYTE *)pkcs7WithTimestamp, &pkcs7WithTimestampLength, 0)) {
            logMessage(@"CPGetHashParam HP_PKCS7_BODY Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        
        // Сохранение PKCS#7
        if (writeFile((char *) [PKCS7_WITH_TIMESTAMP_PATH UTF8String], pkcs7WithTimestamp, (long)pkcs7WithTimestampLength)) {
            logMessage(@"PKCS#7 with Timestamp not saved to \"%@\"\n", PKCS7_WITH_TIMESTAMP_PATH);
            return -1;
        }
        return 0;
    }
    @finally {
        if (pkcs7 != NULL) {
            SAFEFREE(pkcs7);
        }
        if (signature != NULL) {
            SAFEFREE(signature);
        }
        if (pkcs7WithTimestamp != NULL) {
            SAFEFREE(pkcs7WithTimestamp);
        }
        if (hHash != 0) {
            CPDestroyHash(hProv, hHash);
        }
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }
}

- (int) verifyPkcs7WithUrl:(NSString *)url {
    HCRYPTPROV hProv = 0;
    HCRYPTKEY hKey = 0;
    HCRYPTHASH hHash = 0;
    unsigned char *pkcs7 = NULL;
    unsigned char *data = NULL;
    unsigned char *value = NULL;
    @try {
        unsigned char cert[8196];
        BYTE serialNumber1[256];
        BYTE serialNumber2[256];
        char serialNumberString[256];
        long sz = 0;
        DWORD len = 0;
        DWORD len1 = 0;
        DWORD len2 = 0;
        DWORD dw = 0;
        ObjectInfoStr_t p7i;
        DWORD l = 0;
        
        // Проверка наличия PKCS#7
        if (![[NSFileManager defaultManager] fileExistsAtPath:PKCS7_PATH]) {
            logMessage(@"File \"%@\" not found. Please, put PKCS#7 file by this path\n", PKCS7_PATH);
            return -1;
        }
        // Загрузка PKCS#7
        if (getFileLen((char *)[PKCS7_PATH UTF8String], &sz)) {
            logMessage(@"Get file length error\n");
            return -1;
        }
        pkcs7 = (unsigned char *) calloc(sz + 1, sizeof(unsigned char));
        if (readFile((char *)[PKCS7_PATH UTF8String], pkcs7, sz)) {
            logMessage(@"Read file error\n");
            return -1;
        }
        // Создание контекста CSP
        if (!CPAcquireContext(&hProv, NULL, CRYPT_VERIFYCONTEXT, NULL)) {
            logMessage(@"CPAcquireContext CRYPT_VERIFYCONTEXT Error: %0X\n", GetLastErrorCSP(0));
            return -1;
        }
        // Получение content oid
        len = sizeof(p7i);
        p7i.object.pbData = pkcs7;
        p7i.object.cbData = (DWORD)sz;
        if (!CPGetProvParam(hProv, PP_PKCS7_CONTENT_OID, (BYTE *)&p7i, &len, 0)) {
            logMessage(@"CPGetProvParam PP_PKCS7_CONTENT_OID Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        logMessage(@"Content oid: %s\n", p7i.data);
        // Создание хеш-объекта
        if (!CPCreateHash(hProv, CALG_TGR3411, 0, 0, &hHash)) {
            logMessage(@"CPCreateHash CALG_TGR3411 Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Установка проверяемого PKCS#7
        if (!CPSetHashParam(hProv, hHash, HP_PKCS7_BODY, pkcs7, 0)) {
            logMessage(@"CPSetHashParam HP_PKCS7_BODY Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Получение данных, которые подписывались (Только для ATTACHED подписи)
        len = sizeof(dw);
        if (!CPGetHashParam(hProv, hHash, HP_PKCS7_DATA_SIZE, (BYTE *)&dw, &len, 0)) {
            logMessage(@"CPGetHashParam HP_PKCS7_DATA_SIZE Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        if (dw > 0) {
            // ATTACHED подпись
            
            data = (BYTE *)calloc(dw, sizeof(BYTE));
            if (!CPGetHashParam(hProv, hHash, HP_PKCS7_DATA, (BYTE *)data, &dw, 0)) {
                logMessage(@"CPGetHashParam HP_PKCS7_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
        } else {
            // DETACHED подпись
            
            dw = strlen([self.textFieldDataForPKCS7.text UTF8String]);
            data = (BYTE *)calloc(dw + 1, sizeof(char));
            memcpy(data, [self.textFieldDataForPKCS7.text UTF8String], dw);
            data[dw] = 0;
        }
        
        // Попытка чтения атрибута 1.2.840.113549.1.9.77 из signedAttrs
        NSString *oid = @"1.2.840.113549.1.9.77";
        if (!CPSetHashParam(hProv, hHash, HP_PKCS9_CUR_OID, (BYTE *)[oid UTF8String], 0)) {
            logMessage(@"CPSetHashParam 1.2.840.113549.1.9.77 HP_PKCS9_CUR_OID Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        len = sizeof(l);
        if (CPGetHashParam(hProv, hHash, HP_PKCS9A_SIZE, (BYTE *)&l, &len, 0)) {
            value = (unsigned char *) calloc(l + 1, sizeof(unsigned char));
            len = l;
            if (!CPGetHashParam(hProv, hHash, HP_PKCS9A_DATA, value, &len,0)) {
                logMessage(@"CPGetHashParam 1.2.840.113549.1.9.77 HP_PKCS9A_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            value[len] = 0;
            NSString *val = [NSString stringWithUTF8String:(const char *)value];
            logMessage(@"Value: %@\n", val);
        }
        
        // Попытка чтения метки времени из unsignedAttrs
        if (!CPSetHashParam(hProv, hHash, HP_PKCS9_CUR_OID, (BYTE *)OID_PKCS9_TIMESTAMPATTR, 0)) {
            logMessage(@"CPSetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9_CUR_OID Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        len = sizeof(l);
        if (CPGetHashParam(hProv, hHash, HP_PKCS9U_SIZE, (BYTE *)&l, &len, 0)) {
            value = (unsigned char *) calloc(l, sizeof(unsigned char));
            len = l;
            if (!CPGetHashParam(hProv, hHash, HP_PKCS9U_DATA, value, &len,0)) {
                logMessage(@"CPGetHashParam OID_PKCS9_TIMESTAMPATTR HP_PKCS9U_DATA Error: %0X\n", GetLastErrorCSP(hProv));
                return -1;
            }
            NSData *timeStamp = [NSData dataWithBytes:value length:len];
            logMessage(@"Time stamp: %@\n", timeStamp);
        }
        
        // Хеширование данных
        if (!CPHashData(hProv, hHash, (BYTE *)data, dw, 0)) {
            logMessage(@"CPHashData data Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        // Получение серийного номера сертификата подписанта
        len1 = sizeof(serialNumber1);
        if (!CPGetHashParam(hProv, hHash, HP_PKCS7_SI_SN, serialNumber1, &len1, 0)) {
            logMessage(@"CPGetHashParam HP_PKCS7_SI_SN Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        for (int i = 0; i < len1; i++) {
            sprintf(&serialNumberString[i * 2], "%02X", serialNumber1[i]);
        }
        serialNumberString[len1 * 2] = 0;
        logMessage(@"Serial number 1: %s\n", serialNumberString);
        // Получение количества вложенных сертификатов
        len = sizeof(dw);
        if (!CPGetHashParam(hProv, hHash, HP_PKCS7_CRT_COUNT, (BYTE *)&dw, &len, 0)) {
            logMessage(@"CPGetHashParam HP_PKCS7_CRT_COUNT Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        logMessage(@"Certificates count in PKCS#7: %d\n", dw);
        if (dw) {
            // Получение сертификата, которым были подписаны данные
            len = sizeof(cert);
            if (CPGetHashParam(hProv, hHash, HP_PKCS7_ENUM_CERT, cert, &len, CRYPT_FIRST)) {
                do {
                    if (CPImportKey(hProv, cert, len, 0, 0, &hKey)) {
                        len2 = sizeof(serialNumber2);
                        if (CPGetKeyParam(hProv, hKey, KP_KEY_SN, serialNumber2, &len2, 0)) {
                            for (int i = 0; i < len2; i++) {
                                sprintf(&serialNumberString[i * 2], "%02X", serialNumber2[i]);
                            }
                            serialNumberString[len1 * 2] = 0;
                            logMessage(@"Serial number 2: %s\n", serialNumberString);
                            if (len1 == len2 && !memcmp(serialNumber1, serialNumber2, len1)) {
                                break;
                            }
                        }
                        CPDestroyKey(hProv, hKey);
                        hKey = 0;
                    }
                    len = sizeof(cert);
                } while(CPGetHashParam(hProv, hHash, HP_PKCS7_ENUM_CERT, cert, &len, 0));
            }
        }
        if (!hKey) {
            logMessage(@"Certificate of signer not found in PKCS#7\n", GetLastErrorCSP(hProv));
        }
        // Проверка подписи
        if (!CPVerifySignature(hProv, hHash, pkcs7, (DWORD)sz, hKey, 0, 0)) {
            logMessage(@"CPVerifySignature pkcs7 Error: %0X\n", GetLastErrorCSP(hProv));
            return -1;
        }
        return 0;
    }
    @finally {
        if (pkcs7 != NULL) {
            SAFEFREE(pkcs7);
        }
        if (data != NULL) {
            SAFEFREE(data);
        }
        if (value != NULL) {
            SAFEFREE(value);
        }
        if (hKey != 0) {
            CPDestroyKey(hProv, hKey);
        }
        if (hHash != 0) {
            CPDestroyHash(hProv, hHash);
        }
        if (hProv != 0) {
            // Закрытие контекста CSP
            CPReleaseContext(hProv, 0);
        }
    }
}

@end
