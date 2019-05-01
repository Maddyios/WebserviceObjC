
#import "Webservice.h"
#import "Reachability.h"

@implementation Webservice

+(void)callWebserviceWithParams:(NSDictionary *)aParams withURL:(NSString *)aStrURL withTarget:(UIViewController *)aVCObj withCompletionBlock:(void(^)(NSMutableDictionary *aMutDict))completionBlock withFailureBlock:(void(^)(NSError *error))failure
{
    if ([Webservice isConnected]) {
        
        NSString *aStrParams = [Webservice getFormDataStringWithDictParams:aParams];
        
        NSData *aData = [aStrParams dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *aRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:aStrURL]];
        [aRequest setHTTPMethod:@"POST"];
        [aRequest setHTTPBody:aData];
        NSString *aPostDataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[aData length]];

        
        
        [aRequest setHTTPMethod:@"POST"];
        [aRequest setValue:WS_API_KEY forHTTPHeaderField:@"BC-API-KEY"];
        [aRequest setValue:aPostDataLength forHTTPHeaderField:@"Content-Length"];
        [aRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [aRequest setHTTPBody:aData];
        [aRequest setTimeoutInterval:90];

        
        
     
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
        [aRequest setHTTPBody:aData];
        
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:aRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //
            if (error ==nil) {
              
                NSMutableDictionary *aMutDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([aMutDict[@"success"]integerValue]==2)
                    {
                        
                       
                    }
                    else
                    {
                        completionBlock(aMutDict);
                    }
                });
            }                       
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
        
        [postDataTask resume];
    }
    else
    {
        [[LeagleyesSingleton sharedSingleton]showSimpleAlertWithMessage:@"Please check the internet connectivity" withTarget:aVCObj];
    }
}

+(void)callWebserviceWithParamsToPostImage:(NSMutableDictionary *)aParams withURL:(NSString *)aStrURL withTarget:(UIViewController *)aVCObj withCompletionBlock:(void(^)(NSMutableDictionary *dictionary))completionBlock withFailureBlock:(void(^)(NSError *error))failure
{
    if ([Webservice isConnected]) {
        
        UIImage *aImage = aParams[@"image"];
        NSString *aStrParamName = aParams[@"param_name"];
        
        [aParams removeObjectForKey:@"image"];
        [aParams removeObjectForKey:@"param_name"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aStrURL]];
        [request setHTTPMethod:@"POST"];
         NSString *uuidStr = [[NSUUID UUID] UUIDString];
        [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", uuidStr] forHTTPHeaderField:@"Content-Type"];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSData *imagedata = UIImageJPEGRepresentation(aImage, (CGFloat)0.6);
        NSData *fileData = UIImagePNGRepresentation([UIImage imageWithData:imagedata]);
        NSData *data = [self createBodyWithBoundary:uuidStr withDictData:aParams data:fileData filename:aStrParamName];
        
        NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSAssert(!error, @"%s: uploadTaskWithRequest error: %@", __FUNCTION__, error);
            
            // parse and interpret the response `NSData` however is appropriate for your app
        
           

            NSMutableDictionary *aMutDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([aMutDict[@"success"]integerValue]==2)
                {
                   
                }
                else
                {
                    completionBlock(aMutDict);
                }

            });
        }];
        [task resume];
        
    }
    else
    {
        [[LeagleyesSingleton sharedSingleton]showSimpleAlertWithMessage:@"Please check the internet connectivity" withTarget:aVCObj];
    }
}



+ (NSData *) createBodyWithBoundary:(NSString *)boundary withDictData:(NSDictionary *)aDict data:(NSData*)data filename:(NSString *)paramName
{
    NSMutableData *body = [NSMutableData data];
    
    if (data) {
        //only send these methods when transferring data as well as username and password
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", paramName,@"image.png"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"image/png"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    for (NSString *aKey in aDict.allKeys) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", aKey,aDict[aKey]] dataUsingEncoding:NSUTF8StringEncoding]];

    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}



+(void)callWebserviceWithParamsInBackground:(NSDictionary *)aParams withURL:(NSString *)aStrURL withTarget:(UIViewController *)aVCObj withCompletionBlock:(void(^)(NSMutableDictionary *aMutDict))completionBlock withFailureBlock:(void(^)(NSError *error))failure
{
    if ([Webservice isConnected]) {
        
        NSString *aStrParams = [Webservice getFormDataStringWithDictParams:aParams];
        
        NSData *aData = [aStrParams dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *aRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:aStrURL]];
        [aRequest setHTTPMethod:@"POST"];
        [aRequest setHTTPBody:aData];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
        [aRequest setHTTPBody:aData];
        
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:aRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //
            if (error ==nil) {
                NSMutableDictionary *aMutDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                     if ([aMutDict[@"success"]integerValue]==2)
                    {
                        
                        
                    }
                    else
                    {
                        completionBlock(aMutDict);
                    }
                    
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
        
        [postDataTask resume];
    }
}

+(NSString *)getFormDataStringWithDictParams:(NSDictionary *)aDict
{
    NSMutableString *aMutStr = [[NSMutableString alloc]initWithString:@""];
    for (NSString *aKey in aDict.allKeys) {
        [aMutStr appendFormat:@"%@=%@&",aKey,aDict[aKey]];
    }
    NSString *aStrParam;
    if (aMutStr.length>2) {
        aStrParam = [aMutStr substringWithRange:NSMakeRange(0, aMutStr.length-1)];

    }
    else
        aStrParam = @"";

    return aStrParam;
}


+(BOOL)isConnected
{
    
    Reachability *aReachability = [Reachability reachabilityWithHostName:KWebserviceURL];
     NetworkStatus netStatus = [aReachability currentReachabilityStatus];
    
    if(netStatus==0)
    {
        return NO;
    }
    else if(netStatus==1)
    {
        return YES;
        
    } else if(netStatus==2)
    {
        return YES;
    }
    else
    {
        return YES;
    }
}

+ (void)postURL:(NSString *)aURLStr parameters:(NSMutableDictionary *)aParams withTarget:(UIViewController *)aVCObj completionHandler:(void(^)(NSMutableDictionary *aMutDictResponse, NSError *error))completionHandler
{
    
    if ([Webservice isConnected]) {
        @try
        {
            [aParams setObject:@"form-multi-part" forKey:@"data"];
            NSString *aStrPost = [Webservice getFormDataStringWithDictParams:aParams];
            NSData *aPostData = [aStrPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSString *aPostDataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[aPostData length]];
            
            NSMutableURLRequest *aUrlRequest = [[NSMutableURLRequest alloc] init];
            [aUrlRequest setURL:[NSURL URLWithString:aURLStr]];
            [aUrlRequest setHTTPMethod:@"POST"];
            [aUrlRequest setValue:WS_API_KEY forHTTPHeaderField:@"BC-API-KEY"];
            [aUrlRequest setValue:aPostDataLength forHTTPHeaderField:@"Content-Length"];
            [aUrlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [aUrlRequest setHTTPBody:aPostData];
            [aUrlRequest setTimeoutInterval:90];
            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
            sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingMutableContainers];
            
            NSURLSessionDataTask *sessionDataTask = [sessionManager dataTaskWithRequest:aUrlRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                                     
            {
                                                         if (error)
                                                             completionHandler(nil,error);
                                                         else
                                                         {
                                                             if ([responseObject isKindOfClass:[NSDictionary class]])
                                                                 completionHandler([responseObject dictionaryByReplacingNullsWithBlanks], nil);
                                                         }
                                                     }];
            
            [sessionDataTask resume];
            
        }
        @catch (NSException *exception)
        {
            NSLog(@"Exception %@ in %s on line %d",exception.description,__PRETTY_FUNCTION__,__LINE__);
        }
        @finally
        {
            
        }
        
    }
    else
    {
        [[AppDelegate getDelegate]hideHud];
        UIImage *imgAlert = [UIImage imageNamed:@"dialog-warning"];
        
        [[LeagleyesSingleton sharedSingleton]showSimpleAlertWithTitle:@"ALERT!" withMessage:@"Please check internet connectivity" imgAlert:imgAlert withTarget:aVCObj withCompletionBlock:nil];    }
    
}

/*  Comment for save local video*/
+ (void)postWithVideoURL:(NSString *)aURLStr aVideoName:(NSString *)aVideoName parameters:(NSMutableDictionary *)aParams withTarget:(UIViewController *)aVCObj completionHandler:(void(^)(NSMutableDictionary *aMutDictResponse, NSError *error))completionHandler
{
    if ([Webservice isConnected]) {
        @try
        {
            Userdata *aUserData = [[LeagleyesSingleton sharedSingleton] loadCustomObjectWithKey:kUserProfile];

           // Userdata *aUserData = [[LeagleyesSingleton sharedSingleton] loadCustomObjectWithKey:kUserProfile];
            [aParams setObject:@"form-multi-part" forKey:@"data"];
//            [aParams setObject:aUserData.securityToken forKey:@"security_token"];
//            [aParams setObject:[NSString stringWithFormat:@"%f",aUserData.userid] forKey:@"user_id"];
  
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            
            AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
            
            sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingMutableContainers];
           
            sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            
            [sessionManager.requestSerializer setValue:WS_API_KEY forHTTPHeaderField:@"BC-API-KEY"];
            [sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            NSString *strVideoPath = [NSString stringWithFormat:@"%@.mp4",aVideoName];
            
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:strVideoPath];
           NSURLSessionDataTask *sessionDataTask = [sessionManager POST:aURLStr parameters:aParams constructingBodyWithBlock:^(id<AFMultipartFormData>_Nonnull formData) {
                
             
            NSData *videoData = [NSData dataWithContentsOfFile:filePath];
                
                [formData appendPartWithFileData:videoData name:@"userfile" fileName:[NSString stringWithFormat:@"%@-%.0f.mp4",aVideoName,aUserData.userid] mimeType:@"video/mp4"];
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"UploadProgress:%@",uploadProgress);
                BOOL aFileExists = [[NSFileManager defaultManager]fileExistsAtPath:filePath];
                if (!aFileExists) {
                    [sessionDataTask suspend];
                }
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]])
                    completionHandler([responseObject dictionaryByReplacingNullsWithBlanks], nil);
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (error)
                    completionHandler(nil,error);
                
            }];
            
            [sessionDataTask resume];
        }
        @catch (NSException *exception)
        {
            NSLog(@"Exception %@ in %s on line %d",exception.description,__PRETTY_FUNCTION__,__LINE__);
        }
        @finally
        {
            
        }
    }
    else
    {
        [[AppDelegate getDelegate]hideHud];
        UIImage *imgAlert = [UIImage imageNamed:@"dialog-warning"];

        [[LeagleyesSingleton sharedSingleton]showSimpleAlertWithTitle:@"ALERT!" withMessage:@"Please check internet connectivity" imgAlert:imgAlert withTarget:aVCObj withCompletionBlock:nil];
    }
    
}

/*  Comment for save local video*/
+ (void)postWithVideoURLToGetUploadSpeed:(NSString *)aURLStr withTarget:(UIViewController *)aVCObj completionHandler:(void(^)(NSMutableDictionary *aMutDictResponse, NSError *error))completionHandler
{
    if ([Webservice isConnected]) {
        @try
        {
            Userdata *aUserData = [[LeagleyesSingleton sharedSingleton] loadCustomObjectWithKey:kUserProfile];
                   // Userdata *aUserData = [[LeagleyesSingleton sharedSingleton] loadCustomObjectWithKey:kUserProfile];
            //            [aParams setObject:aUserData.securityToken forKey:@"security_token"];
            //            [aParams setObject:[NSString stringWithFormat:@"%f",aUserData.userid] forKey:@"user_id"];
            
            
         /*   NSMutableDictionary *aMutDictParams = [NSMutableDictionary
                                                   dictionaryWithDictionary:@{
                                                                              @"user_id":[NSString stringWithFormat:@"%f",aUserData.userid],
                                                                              @"security_token":aUserData.securityToken,
                                                                              @"created_date":@"",
                                                                              @"uploadStatus":@"1"
                                                                              }];*/
            
            NSMutableDictionary *aMutDictParams = [NSMutableDictionary dictionary];
            
            [aMutDictParams setObject:@"form-multi-part" forKey:@"data"];

            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            
            AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
            
            sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingMutableContainers];
            
            sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            
            [sessionManager.requestSerializer setValue:WS_API_KEY forHTTPHeaderField:@"BC-API-KEY"];
          //  [sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            NSURLSessionDataTask *sessionDataTask = [sessionManager POST:aURLStr parameters:aMutDictParams constructingBodyWithBlock:^(id<AFMultipartFormData>_Nonnull formData) {
                
                NSString *aStrPath = [[NSBundle mainBundle]pathForResource:@"512k" ofType:@"txt"];
                NSData *aVideoData = [NSData dataWithContentsOfFile:aStrPath];
              
                
                [formData appendPartWithFileData:aVideoData name:@"userfile" fileName:[NSString stringWithFormat:@"%@-%.0f",@"",aUserData.userid] mimeType:@"video/mp4"];
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"UploadProgress:%@",uploadProgress);
                /*if ((uploadProgress.completedUnitCount/uploadProgress.totalUnitCount) >= 1.000) {
                    completionHandler([NSMutableDictionary dictionaryWithDictionary:@{@"success": @"1"}], nil);

                }*/
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]])
                    completionHandler([responseObject dictionaryByReplacingNullsWithBlanks], nil);
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (error)
                    completionHandler(nil,error);
                
            }];
            
            [sessionDataTask resume];
        }
        @catch (NSException *exception)
        {
            NSLog(@"Exception %@ in %s on line %d",exception.description,__PRETTY_FUNCTION__,__LINE__);
        }
        @finally
        {
            
        }
    }
    else
    {
        completionHandler(nil,nil);
    }
  
    
}



@end
