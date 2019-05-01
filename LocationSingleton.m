
#import "LocationSingleton.h"
//#import "VideoArchivesVC.h"
//#import <CommonCrypto/CommonCrypto.h>
//#import "DoAlertView.h"


@implementation LocationSingleton
static LocationSingleton* _sharedLocationSingleton = nil;

+(LocationSingleton*)sharedSingleton
{
    @synchronized ([LocationSingleton class])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedLocationSingleton = [[LocationSingleton alloc] init];
        });
        
        return _sharedLocationSingleton;
    }
    
    return nil;
}

#pragma mark - AlertView Methods

-(void)showSimpleAlertWithMessage:(NSString *)aStrMessage withTarget:(UIViewController *)aTarget
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:aStrMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [aTarget presentViewController:alertController animated:YES completion:nil];
}

-(void)showAlertWithTitle:(NSString *)aStrTitle withMessage:(NSString *)aStrMessage withTarget:(UIViewController *)aTarget withCancelButton:(NSString *)aStrName withButtons:(NSArray *)aArrBtn withCompletionBlock:(void(^)(int aIndex))completionBlock
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:aStrTitle
                                          message:aStrMessage preferredStyle:UIAlertControllerStyleAlert];
    int counter = 0;
    for (NSString *aStr in aArrBtn) {
        [alertController addAction:[UIAlertAction actionWithTitle:aStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completionBlock) {
                completionBlock(counter);
            }
        }]];
        counter++;
    }
    [alertController addAction:[UIAlertAction actionWithTitle:aStrName style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completionBlock) {
            completionBlock(counter);
        }
    }]];
    [aTarget presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - AlertView Methods  Custom

-(void)showSimpleAlertWithTitle:(NSString *)aStrTitle withMessage:(NSString *)aStrMessage imgAlert:(UIImage*)imgAlert withTarget:(UIViewController *)aTarget withCompletionBlock:(void(^)(void))completionBlock
{
    if (aTarget!=nil) {
        
       
        
        _vAlert = [[DoAlertView alloc] init];
        _vAlert.nAnimationType = 3;
        _vAlert.dRound = 5.0;
        _vAlert.strYesText = @"OK";
        _vAlert.parentVC = aTarget;
        
        [_vAlert doYes:aStrTitle body:aStrMessage imgAlert:imgAlert yes:^(DoAlertView *alertView){
            if (completionBlock) {
                completionBlock();
            }
        }];
        
    }
}

-(void)showAlertWithTitle:(NSString *)aStrTitle withMessage:(NSString *)aStrMessage withTarget:(UIViewController *)aTarget withCancelButton:(NSString *)aStrName withOKButton:(NSString *)aStrOKName withCompletionBlock:(void(^)(int aIndex))completionBlock;
{
    if (aTarget!=nil) {
        
        _vAlert = [[DoAlertView alloc] init];
        _vAlert.nAnimationType = 3;
        _vAlert.dRound = 8.0;
        _vAlert.strYesText = aStrOKName;
        _vAlert.strCancelText = aStrName;
        _vAlert.parentVC = aTarget;
        
        
        [_vAlert doYesNo:aStrTitle body:aStrMessage yes:^(DoAlertView *alertView) {
            if (completionBlock) {
                completionBlock(0);
            }
            
        } no:^(DoAlertView *alertView) {
            if (completionBlock) {
                completionBlock(1);
            }
            
        }];
    }
}


#pragma mark - Custom Object NSUserDefaults Methods

- (void)saveCustomObject:(id)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    [kUserdefaults setObject:encodedObject forKey:key];
    [kUserdefaults synchronize];
    
}

- (id)loadCustomObjectWithKey:(NSString *)key {
    NSData *encodedObject = [kUserdefaults objectForKey:key];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}


#pragma mark - Custom Object Save Methods

/*  Comment for save local video*/
-(BOOL)saveDataInStoreWithData:(NSMutableDictionary *)aMutDict
{
    NSDateFormatter *aFormatter = [AppDelegate shareDateFormatter];
    [aFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    Userdata *aUserData = [[LocationSingleton sharedSingleton] loadCustomObjectWithKey:kUserProfile];

    VideoArchive *aVideoArchive = [VideoArchive MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]];
    aVideoArchive.video_id = [NSNumber numberWithInt:[[aMutDict valueForKey:@"video_id"]intValue]];
    aVideoArchive.location_long = [NSNumber numberWithFloat:[[aMutDict valueForKey:@"location_long"]floatValue]];
    aVideoArchive.location_lat = [NSNumber numberWithFloat:[[aMutDict valueForKey:@"location_lat"]floatValue]];
    aVideoArchive.broadcast_status = [aMutDict valueForKey:@"broadcast_status"];
    aVideoArchive.date_created = [aFormatter dateFromString:[aMutDict valueForKey:@"date_created"]];
    aVideoArchive.video_link = [aMutDict valueForKey:@"video_link"];
    aVideoArchive.video_name = [aMutDict valueForKey:@"video_name"];
    aVideoArchive.video_path = @"path";
    aVideoArchive.video_status = [aMutDict valueForKey:@"video_status"];
    aVideoArchive.userid = [NSNumber numberWithDouble:aUserData.userid];
    [[NSManagedObjectContext MR_rootSavingContext] MR_saveToPersistentStoreAndWait];
      NSLog(@"DataFromDatabase:%@",[VideoArchive MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]]);
    
    return YES;
}

-(void)updateVideoIdInStore:(NSString *)aVideoId
{
    VideoArchive *aVideoArchive = [[VideoArchive MR_findAllSortedBy:@"date_created" ascending:NO]firstObject];
    aVideoArchive.video_id = [NSNumber numberWithInt:[aVideoId intValue]];
    [[NSManagedObjectContext MR_rootSavingContext]MR_saveToPersistentStoreAndWait];
}

-(void)updateDataInStoreWithData:(NSString *)aVideoStatus aBroadcastStatus:(NSString*)aBroadcastStatus
{
    //   VideoArchive *aVideoArchive =[VideoArchive MR_findFirstOrderedByAttribute:@"date_created" ascending:NO];
    
    VideoArchive *aVideoArchiveObj = [[VideoArchive MR_findAllSortedBy:@"date_created" ascending:NO inContext:[NSManagedObjectContext MR_rootSavingContext]]firstObject];
    aVideoArchiveObj.video_status = aVideoStatus;
    aVideoArchiveObj.broadcast_status = aBroadcastStatus;
    
    NSLog(@"Name %@ date %@",aVideoArchiveObj.video_name,aVideoArchiveObj.date_created);
    
    [[NSManagedObjectContext MR_rootSavingContext]MR_saveToPersistentStoreAndWait];
}

-(void)getDataWithVideoStatusPending
{
   

    Userdata *aUserData = [[LocationSingleton sharedSingleton] loadCustomObjectWithKey:kUserProfile];
    NSNumber *aUserID = [NSNumber numberWithDouble:aUserData.userid];
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"video_status=='0' AND userid =%@",aUserID];
    NSArray *aArrData = [VideoArchive MR_findAllSortedBy:@"date_created" ascending:YES withPredicate:aPredicate inContext:[NSManagedObjectContext MR_rootSavingContext]];
    
    if (aArrData.count !=0)
    {
        
        if ([Webservice isConnected])
        {
            [[AppDelegate getDelegate]setBoolISVideoUploading:YES];

            VideoArchive *aVideoArchive =[aArrData firstObject];
            aVideoArchive.video_status = @"1";
            aVideoArchive.broadcast_status = @"Uploading";
            [self uploadVideo:aVideoArchive];
            NSArray *aArrTemp = [VideoArchive MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]];
            
            for (VideoArchive *aObj in aArrTemp) {
                
                if (![aObj.video_name isEqualToString:aVideoArchive.video_name]) {
                    aObj.video_status = @"0";
                }
                NSLog(@"VideStatus:%@",aObj.video_status);
            }
        }
        
    }
    else
    {
        [[AppDelegate getDelegate]setBoolISVideoUploading:NO];
    }
}

-(void)uploadVideo:(VideoArchive*)aVideoArchiveObj
{
       
    NSString *aStrVideoName = [aVideoArchiveObj.video_name componentsSeparatedByString:@"-"][0];
    NSString *strVideoPath = [NSString stringWithFormat:@"%@.mp4",aStrVideoName];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
   /* NSString *filePath = [documentsDirectory stringByAppendingPathComponent:strVideoPath];
    NSLog(@"%@", filePath);*/
    
    Userdata *aUserData = [[LocationSingleton sharedSingleton] loadCustomObjectWithKey:kUserProfile];
    NSDateFormatter *aFormatter = [AppDelegate shareDateFormatter];
    [aFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableDictionary *aMutDictParams = [NSMutableDictionary
                                           dictionaryWithDictionary:@{
                                                                      @"user_id":[NSString stringWithFormat:@"%f",aUserData.userid],
                                                                      @"security_token":aUserData.securityToken,
                                                                      @"created_date":@"",
                                                                      @"uploadStatus":@"1",
                                                                      @"latitude":aVideoArchiveObj.location_lat,
                                                                      @"longitude":aVideoArchiveObj.location_long,
                                                                      @"video_name":aVideoArchiveObj.video_name,
                                                                      @"dt_created":[aFormatter stringFromDate:aVideoArchiveObj.date_created],
                                                                      }];
    
    aMutDictParams[@"video_link"] =[NSString stringWithFormat:@"%@/videoarchive-offline-%@",KVideoLink,aVideoArchiveObj.video_name];

    
    NSString *aStrURL = [NSString stringWithFormat:@"%@",KVideoUploadLink];
    
    [Webservice postWithVideoURL:aStrURL aVideoName:aStrVideoName parameters:aMutDictParams withTarget:nil completionHandler:^(NSMutableDictionary *aMutDictResponse, NSError *error) {
        
        if (error==nil)
        {
            if ([aMutDictResponse[@"success"]integerValue]==1)
            {
                
                [aVideoArchiveObj MR_deleteEntityInContext:[NSManagedObjectContext MR_rootSavingContext]];
                [[NSManagedObjectContext MR_rootSavingContext]MR_saveToPersistentStoreAndWait];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *filePath = [documentsPath stringByAppendingPathComponent:strVideoPath];
                NSError *error;
                BOOL success = [fileManager removeItemAtPath:filePath error:&error];
                
                [self updateInArchivesScreen];
                
                if (success) {
                    NSLog(@"Successfully removed");
                    [self getDataWithVideoStatusPending];
                }
                else
                {
                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                }
                
            }
            else
            {
                aVideoArchiveObj.video_status = @"0";
                aVideoArchiveObj.broadcast_status = @"pending";
                [[NSManagedObjectContext MR_rootSavingContext]MR_saveToPersistentStoreAndWait];
            }
        }
        else
        {
            aVideoArchiveObj.video_status = @"0";
            aVideoArchiveObj.broadcast_status = @"pending";
            [[NSManagedObjectContext MR_rootSavingContext]MR_saveToPersistentStoreAndWait];
        }
    }];
}

-(void)updateInArchivesScreen
{
    UINavigationController *aNavController = (UINavigationController *)[AppDelegate getDelegate].window.rootViewController;
    if ([aNavController.topViewController isKindOfClass:[VideoArchivesVC class]]) {
        VideoArchivesVC *aObj = (VideoArchivesVC *)aNavController.topViewController;
        [aObj callWebserviceToGetAllVideoWithHud:YES];
    }
    else
    {
        NSArray *aArrVC = aNavController.viewControllers;
        for (UIViewController *aVCObj in aArrVC) {
            if ([aVCObj isKindOfClass:[VideoArchivesVC class]]) {
                [((VideoArchivesVC *)aVCObj) callWebserviceToGetAllVideoWithHud:YES];
            }
        }
    }
    
}


-(NSString *)createKeyForPlayer
{
    NSString *aStrWowzaLink = kAWSWowzaLink;
    NSString *aStrWowzaToken = @"leaglewowzatokeneye";
  //  NSTimeInterval aStart = 0;
  //  NSInteger validity = 18000000; // validity in seconds
    
   // NSTimeInterval aEnd = [[NSDate date]timeIntervalSinceNow]+validity;
    NSString *aStrSecret = @"cc3499718f5d1682";
    NSString *aStrVOD = @"Secure_Leagleyes_VOD";
    
    NSString *aStrHash = [NSString stringWithFormat:@"%@?%@",aStrVOD,aStrSecret];
    
    NSString *aStrSha256 = [self sha256:aStrHash];
    NSString *aStrBase64 = [[self toBase64String:aStrSha256]stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    /*
     
     String iurl = wowza_serverip + ":1935/Secure_Leagleyes_VOD/LS1473858741630-68.mp4?"+
     wowzatoken + "endtime="+ String.valueOf(wowzaend) + "&" +
     wowzatoken + "starttime=" + String.valueOf(wowzastart) + "&" +
     wowzatoken + "hash=" + usableHash;*/
    
    NSString *aStrURL = [NSString stringWithFormat:@"rtmp://%@/%@/%@?%@hash=%@",aStrWowzaLink,aStrVOD,@"LS1473858741630-68.mp4",aStrWowzaToken,aStrBase64];
    
    return aStrURL;
    
}



-(NSString*) sha256:(NSString *)clear{
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (int)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

- (NSString *)toBase64String:(NSString *)string {
    NSData *data = [string dataUsingEncoding: NSUnicodeStringEncoding];
    
    NSString *ret = [data base64EncodedStringWithOptions:0];
    
    return ret;
}

-(void)getVideoNames
{
    NSString *aStrWebserviceURL = [NSString stringWithFormat:@"%@/names",KWebserviceURL];
    [Webservice callWebserviceWithParams:[NSDictionary dictionary] withURL:aStrWebserviceURL withTarget:[[AppDelegate getDelegate]window].rootViewController withCompletionBlock:^(NSMutableDictionary *aMutDict) {
        NSLog(@"Data:%@",aMutDict);
        [kUserdefaults setObject:aMutDict[@"live"] forKey:kWowzaApplicationName];
        [kUserdefaults setObject:aMutDict[@"vod"] forKey:kWowzaApplicationVOD];
        
        [kUserdefaults synchronize];

        
    } withFailureBlock:^(NSError *error) {
        
    }];
}

@end
