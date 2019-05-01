#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <MagicalRecord/MagicalRecord.h>
//#import "DoAlertView.h"
//#import "VideoArchive.h"

@interface LocationSingleton : NSObject<CLLocationManagerDelegate>

@property (nonatomic,assign)CLLocationCoordinate2D coordinateLatLog;
@property (strong, nonatomic)   DoAlertView  *vAlert;
@property (nonatomic, assign)   BOOL boolDoOpenVideo;
@property (nonatomic, strong)   NSString *strBroadcastURL;
@property (nonatomic, strong)   NSString *strResetToken;


+(LocationSingleton*)sharedSingleton;

-(void)showSimpleAlertWithMessage:(NSString *)aStrMessage withTarget:(UIViewController *)aTarget;
-(void)showAlertWithTitle:(NSString *)aStrTitle withMessage:(NSString *)aStrMessage withTarget:(UIViewController *)aTarget withCancelButton:(NSString *)aStrName withButtons:(NSArray *)aArrBtn withCompletionBlock:(void(^)(int aIndex))completionBlock;

// Custom Alert View

-(void)showSimpleAlertWithTitle:(NSString *)aStrTitle withMessage:(NSString *)aStrMessage imgAlert:(UIImage*)imgAlert withTarget:(UIViewController *)aTarget withCompletionBlock:(void(^)(void))completionBlock;
-(void)showAlertWithTitle:(NSString *)aStrTitle withMessage:(NSString *)aStrMessage withTarget:(UIViewController *)aTarget withCancelButton:(NSString *)aStrName withOKButton:(NSString *)aStrOKName withCompletionBlock:(void(^)(int aIndex))completionBlock;

//Save in UserDefaults

- (void)saveCustomObject:(id)object key:(NSString *)key;
- (id)loadCustomObjectWithKey:(NSString *)key;

/*  Comment for save local video*/
-(BOOL)saveDataInStoreWithData:(NSMutableDictionary *)aMutDict;
-(void)updateDataInStoreWithData:(NSString *)aVideoStatus aBroadcastStatus:(NSString*)aBroadcastStatus;
-(void)updateVideoIdInStore:(NSString *)aVideoId;
-(void)getDataWithVideoStatusPending;

-(NSString *)createKeyForPlayer;
-(void)getVideoNames;
//@property (strong, nonatomic) VideoArchive *selectedVideoArchiveObj;*/

@end
