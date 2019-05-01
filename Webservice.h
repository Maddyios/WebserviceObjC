

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+NullReplacement.h"
#import "NSArray+NullReplacement.h"
@interface Webservice : NSObject

+(void)callWebserviceWithParams:(NSDictionary *)aParams withURL:(NSString *)aStrURL withTarget:(UIViewController *)aVCObj withCompletionBlock:(void(^)(NSMutableDictionary *aMutDict))completionBlock withFailureBlock:(void(^)(NSError *error))failure;
+(void)callWebserviceWithParamsToPostImage:(NSMutableDictionary *)aParams withURL:(NSString *)aStrURL withTarget:(UIViewController *)aVCObj withCompletionBlock:(void(^)(NSMutableDictionary *aMutDict))completionBlock withFailureBlock:(void(^)(NSError *error))failure;

+(void)callWebserviceWithParamsInBackground:(NSDictionary *)aParams withURL:(NSString *)aStrURL withTarget:(UIViewController *)aVCObj withCompletionBlock:(void(^)(NSMutableDictionary *aMutDict))completionBlock withFailureBlock:(void(^)(NSError *error))failure;
+(BOOL)isConnected;

+ (void)postURL:(NSString *)aURLStr parameters:(NSMutableDictionary *)aParams withTarget:(UIViewController *)aVCObj completionHandler:(void(^)(NSMutableDictionary *aMutDictResponse, NSError *error))completionHandler;

+(NSString *)getFormDataStringWithDictParams:(NSDictionary *)aDict;

/*  Comment for save local video */
+ (void)postWithVideoURL:(NSString *)aURLStr aVideoName:(NSString *)aVideoName parameters:(NSMutableDictionary *)aParams withTarget:(UIViewController *)aVCObj completionHandler:(void(^)(NSMutableDictionary *aMutDictResponse, NSError *error))completionHandler;

+ (void)postWithVideoURLToGetUploadSpeed:(NSString *)aURLStr withTarget:(UIViewController *)aVCObj completionHandler:(void(^)(NSMutableDictionary *aMutDictResponse, NSError *error))completionHandler;

+ (void)requestPostUrl:(NSString *)strURL parameters:(NSDictionary *)dictParams success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;

@end
