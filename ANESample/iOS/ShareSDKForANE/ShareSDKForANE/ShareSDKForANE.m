//
//  ShareSDKForANE.h
//  ShareSDKForANE
//
//  Created by 陈 剑东 on 15-8-11.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/SSDKFriendsPaging.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKConfigFile/ShareSDK+XML.h>
#import <MOBFoundation/MOBFRegex.h>
#import <MOBFoundation/MOBFJson.h>
#import <MOBFoundation/MOBFDevice.h>
#import "ShareSDKWindow.h"


//#define __SHARESDK_SINA_WEIBO__
#define __SHARESDK_WECHAT__
#define __SHARESDK_QQ__
#define __SHARESDK_APSOCIAL__
#define __SHARESDK_RENREN__
#define __SHARESDK_YIXIN__
#define __SHARESDK_FACEBOOK_MSG__
//#define __SHARESDK_DINGTALK__
//#define __SHARESDK_MEIPAI__

//#define __SHARESDK_KAKAO__             //目前发现Kakao SDK 不能顺利在ANE环境下编译

#ifdef __SHARESDK_WECHAT__
#import "WXApi.h"
#endif

#ifdef __SHARESDK_QQ__
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#endif

#ifdef __SHARESDK_SINA_WEIBO__
#import "WeiboSDK.h"
#endif

#ifdef __SHARESDK_RENREN__
#import <RennSDK/RennSDK.h>
#endif

#ifdef __SHARESDK_KAKAO__
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#endif

#ifdef __SHARESDK_YIXIN__
#import "YXApi.h"
#endif

#ifdef __SHARESDK_APSOCIAL__
#import "APOpenAPI.h"
#endif

#ifdef __SHARESDK_FACEBOOK_MSG__
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#endif

#ifdef __SHARESDK_DINGTALK__
#import <DTShareKit/DTOpenAPI.h>
#endif

#ifdef __SHARESDK_MEIPAI__
#import <MPShareSDK/MPShareSDK.h>
#endif

static UIView *_refView = nil;

NSString *objectToString(FREObject obj)
{
    FREObjectType type;
    FREGetObjectType(obj, &type);
    
    if (type == FRE_TYPE_STRING)
    {
        const uint8_t *appKeyCStr = NULL;
        uint32_t len = 0;
        FREGetObjectAsUTF8(obj, &len, &appKeyCStr);
        
        return [NSString stringWithCString:(const char *)appKeyCStr encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

NSInteger objectToInteger(FREObject obj)
{
    FREObjectType type;
    FREGetObjectType(obj, &type);
    
    if (type == FRE_TYPE_NUMBER)
    {
        int value;
        FREGetObjectAsInt32(obj, &value);
        
        return value;
    }
    
    return 0;
}

BOOL objectToBoolean(FREObject obj)
{
    FREObjectType type;
    FREGetObjectType(obj, &type);
    
    if (type == FRE_TYPE_BOOLEAN)
    {
        uint32_t value;
        FREGetObjectAsBool(obj, &value);
        
        return value != 0 ? YES : NO;
    }
    
    return NO;
}

NSArray *objectToArray(FREObject obj)
{
    FREObjectType type;
    FREGetObjectType(obj, &type);
    
    if (type == FRE_TYPE_ARRAY)
    {
        NSMutableArray *data = [NSMutableArray array];
        
        uint32_t len = 0;
        FREGetArrayLength(obj, &len);
        
        for (int i = 0; i < len; i++)
        {
            FREObject elm;
            FREGetArrayElementAt(obj, i, &elm);
            
            NSInteger type = objectToInteger(elm);
            [data addObject:[NSNumber numberWithInteger:type]];
        }
        
        return data;
    }
    
    return nil;
}

SSDKContentType convertContentTypeWith(NSNumber *number)
{
    switch ([number integerValue])
    {
        case 0:
            return SSDKContentTypeAuto;
        case 1:
            return SSDKContentTypeText;
        case 2:
            return SSDKContentTypeImage;
        case 4:
            return SSDKContentTypeWebPage;
        case 5:
            return SSDKContentTypeAudio;
        case 6:
            return SSDKContentTypeVideo;
        case 7:
            return SSDKContentTypeApp;
        case 8:
            return SSDKContentTypeFile;
        case 9:
            return SSDKContentTypeImage;
        default:
            return SSDKContentTypeText;
    }
}

/**
 *  定制微信分享内容
 *
 *  @param wechatDic 定制的内容
 *  @param params    源分享内容
 *  @param subType   目标子类型
 */
void setWechatShareParmas(NSDictionary *wechatDic,NSMutableDictionary *params,SSDKPlatformType subType)
{
    NSString *text = nil;
    NSString *title = nil;
    NSString *url = nil;
    NSString *thumbImage = nil;
    NSString *image = nil;
    NSString *musicFileUrl = nil;
    NSString *extInfo = nil;
    NSData *fileData = nil;
    NSData *emotionData = nil;
    NSString *sourceFileExtension = nil;
    NSString *sourceFileData = nil;
    SSDKContentType type = SSDKContentTypeText;
    
    if ([[wechatDic objectForKey:@"text"] isKindOfClass:[NSString class]])
    {
        text = [wechatDic objectForKey:@"text"];
    }
    if ([[wechatDic objectForKey:@"title"] isKindOfClass:[NSString class]])
    {
        title = [wechatDic objectForKey:@"title"];
    }
    if ([[wechatDic objectForKey:@"url"] isKindOfClass:[NSString class]])
    {
        url = [wechatDic objectForKey:@"url"];
    }
    if ([[wechatDic objectForKey:@"thumbImageUrl"] isKindOfClass:[NSString class]])
    {
        thumbImage = [wechatDic objectForKey:@"thumbImageUrl"];
    }
    if ([[wechatDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
    {
        image = [wechatDic objectForKey:@"imageUrl"];
    }
    if ([[wechatDic objectForKey:@"musicUrl"] isKindOfClass:[NSString class]])
    {
        musicFileUrl = [wechatDic objectForKey:@"musicUrl"];
    }
    if ([[wechatDic objectForKey:@"extInfoPath"] isKindOfClass:[NSString class]])
    {
        extInfo = [wechatDic objectForKey:@"extInfoPath"];
    }
    if ([[wechatDic objectForKey:@"filePath"] isKindOfClass:[NSString class]])
    {
        NSString *fileDataPath = [wechatDic objectForKey:@"filePath"];
        fileData = [NSData dataWithContentsOfFile:fileDataPath];
    }
    if ([[wechatDic objectForKey:@"emotionDataPath"] isKindOfClass:[NSString class]])
    {
        NSString *emotionDataPath = [wechatDic objectForKey:@"emotionDataPath"];
        emotionData = [NSData dataWithContentsOfFile:emotionDataPath];
    }
    if ([[wechatDic objectForKey:@"sourceFileExtension"] isKindOfClass:[NSString class]])
    {
        sourceFileExtension = [wechatDic objectForKey:@"sourceFileExtension"];
    }
    if ([[wechatDic objectForKey:@"sourceFilePath"] isKindOfClass:[NSString class]])
    {
        sourceFileData = [wechatDic objectForKey:@"sourceFilePath"];
    }
    if ([[wechatDic objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
    {
        type = convertContentTypeWith([wechatDic objectForKey:@"shareType"]);
    }
    
    [params SSDKSetupWeChatParamsByText:text
                                  title:title
                                    url:[NSURL URLWithString:url]
                             thumbImage:thumbImage
                                  image:image
                           musicFileURL:[NSURL URLWithString:musicFileUrl]
                                extInfo:extInfo
                               fileData:fileData
                           emoticonData:emotionData
                    sourceFileExtension:sourceFileExtension
                         sourceFileData:sourceFileData
                                   type:type
                     forPlatformSubType:subType];
}

/**
 *  定制QQ/QZONE分享内容
 *
 *  @param qqDic     定制的内容
 *  @param params    源分享内容
 *  @param subType   目标子类型
 */
void setQQShareParmas(NSDictionary *qqDic,NSMutableDictionary *params,SSDKPlatformType subType)
{
    NSString *text = nil;
    NSString *title = nil;
    NSString *url = nil;
    NSString *thumbImage = nil;
    NSString *image = nil;
    SSDKContentType type = SSDKContentTypeText;
    if ([[qqDic objectForKey:@"text"] isKindOfClass:[NSString class]])
    {
        text = [qqDic objectForKey:@"text"];
    }
    if ([[qqDic objectForKey:@"title"] isKindOfClass:[NSString class]])
    {
        title = [qqDic objectForKey:@"title"];
    }
    if ([[qqDic objectForKey:@"url"] isKindOfClass:[NSString class]])
    {
        url = [qqDic objectForKey:@"url"];
    }
    if ([[qqDic objectForKey:@"thumbImageUrl"] isKindOfClass:[NSString class]])
    {
        thumbImage = [qqDic objectForKey:@"thumbImageUrl"];
    }
    if ([[qqDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
    {
        image = [qqDic objectForKey:@"imageUrl"];
    }
    if ([[qqDic objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
    {
        type = convertContentTypeWith([qqDic objectForKey:@"shareType"]);
    }
    
    [params SSDKSetupQQParamsByText:text
                              title:title
                                url:[NSURL URLWithString:url]
                         thumbImage:thumbImage
                              image:image
                               type:type
                 forPlatformSubType:subType];
}


/**
 *  定制易信分享内容
 *
 *  @param yiXinDic  定制的内容
 *  @param params    源分享内容
 *  @param subType   目标子类型
 */
void setYiXinShareParmas(NSDictionary *yiXinDic,NSMutableDictionary *params,SSDKPlatformType subType)
{
    NSString *text = nil;
    NSString *title = nil;
    NSString *url = nil;
    NSString *thumbImage = nil;
    NSString *image = nil;
    NSString *musicFileURL = nil;
    NSString *extInfo = nil;
    NSString *fileDataPath = nil;
    NSString *comment = nil;
    NSString *toUserId = nil;
    SSDKContentType type = SSDKContentTypeText;
    
    if ([[yiXinDic objectForKey:@"text"] isKindOfClass:[NSString class]])
    {
        text = [yiXinDic objectForKey:@"text"];
    }
    if ([[yiXinDic objectForKey:@"title"] isKindOfClass:[NSString class]])
    {
        title = [yiXinDic objectForKey:@"title"];
    }
    if ([[yiXinDic objectForKey:@"url"] isKindOfClass:[NSString class]])
    {
        url = [yiXinDic objectForKey:@"url"];
    }
    if ([[yiXinDic objectForKey:@"thumbImageUrl"] isKindOfClass:[NSString class]])
    {
        thumbImage = [yiXinDic objectForKey:@"thumbImageUrl"];
    }
    if ([[yiXinDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
    {
        image = [yiXinDic objectForKey:@"imageUrl"];
    }
    if ([[yiXinDic objectForKey:@"musicUrl"] isKindOfClass:[NSString class]])
    {
        musicFileURL = [yiXinDic objectForKey:@"musicUrl"];
    }
    if ([[yiXinDic objectForKey:@"extInfoPath"] isKindOfClass:[NSString class]])
    {
        extInfo = [yiXinDic objectForKey:@"extInfoPath"];
    }
    if ([[yiXinDic objectForKey:@"filePath"] isKindOfClass:[NSString class]])
    {
        fileDataPath = [yiXinDic objectForKey:@"filePath"];
    }
    if ([[yiXinDic objectForKey:@"comment"] isKindOfClass:[NSString class]])
    {
        comment = [yiXinDic objectForKey:@"comment"];
    }
    if ([[yiXinDic objectForKey:@"toUserID"] isKindOfClass:[NSString class]])
    {
        toUserId = [yiXinDic objectForKey:@"toUserID"];
    }
    if ([[yiXinDic objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
    {
        type = convertContentTypeWith([yiXinDic objectForKey:@"shareType"]);
    }
    
    [params SSDKSetupYiXinParamsByText:text
                                 title:title
                                   url:[NSURL URLWithString:url]
                            thumbImage:thumbImage
                                 image:image
                          musicFileURL:[NSURL URLWithString:musicFileURL]
                               extInfo:extInfo
                              fileData:fileDataPath
                               comment:comment
                              toUserId:toUserId
                                  type:type
                    forPlatformSubType:subType];
}

/**
 *  定制Kakao分享内容
 *
 *  @param yiXinDic  定制的内容
 *  @param params    源分享内容
 *  @param subType   目标子类型
 */
void setKakaoShareParmas(NSDictionary *kakaoDic,NSMutableDictionary *params,SSDKPlatformType subType)
{
    NSString *text = nil;
    NSMutableArray *images = [NSMutableArray array];
    NSString *title = nil;
    NSString *url = nil;
    NSString *permission = nil;
    BOOL enableShare;
    double imageWidth = 0.0;
    double imageHeight;
    CGSize defaultSize = CGSizeMake(138, 80);
    
    NSString *appButtonTitle = nil;
    NSString *androidMarkParam = nil;
    NSString *iphoneMarkParam = nil;
    NSString *ipadMarkParam = nil;
    
    NSDictionary *androidExecParam = nil;
    NSDictionary *iphoneExecParams = nil;
    NSDictionary *ipadExecParams = nil;
    
    SSDKContentType type = SSDKContentTypeText;
    
    if ([[kakaoDic objectForKey:@"text"] isKindOfClass:[NSString class]])
    {
        text = [kakaoDic objectForKey:@"text"];
    }
    if ([[kakaoDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
    {
        NSString *imagePath = [kakaoDic objectForKey:@"imageUrl"];
        SSDKImage *image = nil;
        if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                options:MOBFRegexOptionsNoOptions
                                inRange:NSMakeRange(0, imagePath.length)
                             withString:imagePath])
        {
            image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        }
        else
        {
            UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
            image = [[SSDKImage alloc]initWithImage:localImage
                                             format:SSDKImageFormatJpeg
                                           settings:nil];
            
        }
        if (image)
        {
            [images addObject:imagePath];
        }
        else
        {
            NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
        }
    }
    else if([[kakaoDic objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
    {
        NSArray *imagePaths = [kakaoDic objectForKey:@"imageUrl"];
        for (NSString *imagePath in imagePaths)
        {
            SSDKImage *image = nil;
            if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                    options:MOBFRegexOptionsNoOptions
                                    inRange:NSMakeRange(0, imagePath.length)
                                 withString:imagePath])
            {
                image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
            }
            else
            {
                UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                image = [[SSDKImage alloc]initWithImage:localImage
                                                 format:SSDKImageFormatJpeg
                                               settings:nil];
            }
            
            if (image)
            {
                [images addObject:imagePath];
            }
            else
            {
                NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
            }
        }
    }
    if ([[kakaoDic objectForKey:@"title"] isKindOfClass:[NSString class]])
    {
        title = [kakaoDic objectForKey:@"title"];
    }
    if ([[kakaoDic objectForKey:@"url"] isKindOfClass:[NSString class]])
    {
        url = [kakaoDic objectForKey:@"url"];
    }
    if ([[kakaoDic objectForKey:@"permission"] isKindOfClass:[NSString class]])
    {
        permission = [kakaoDic objectForKey:@"permission"];
    }
    if ([[kakaoDic objectForKey:@"enableShare"] isKindOfClass:[NSNumber class]])
    {
        enableShare = [[kakaoDic objectForKey:@"enableShare"] boolValue];
    }
    if ([[kakaoDic objectForKey:@"imageWidth"] isKindOfClass:[NSNumber class]])
    {
        imageWidth = [[kakaoDic objectForKey:@"imageWidth"] floatValue];
    }
    if ([[kakaoDic objectForKey:@"imageHeight"] isKindOfClass:[NSNumber class]])
    {
        imageHeight = [[kakaoDic objectForKey:@"imageHeight"] floatValue];
    }
    if (imageHeight >= 0 && imageWidth >= 0)
    {
        defaultSize = CGSizeMake(imageWidth, imageHeight);
    }
    if ([[kakaoDic objectForKey:@"appButtonTitle"] isKindOfClass:[NSString class]])
    {
        appButtonTitle = [kakaoDic objectForKey:@"appButtonTitle"];
    }
    if ([[kakaoDic objectForKey:@"androidMarkParam"] isKindOfClass:[NSString class]])
    {
        androidMarkParam = [kakaoDic objectForKey:@"androidMarkParam"];
    }
    if ([[kakaoDic objectForKey:@"iphoneMarkParam"] isKindOfClass:[NSString class]])
    {
        iphoneMarkParam = [kakaoDic objectForKey:@"iphoneMarkParam"];
    }
    if ([[kakaoDic objectForKey:@"ipadMarkParam"] isKindOfClass:[NSString class]])
    {
        ipadMarkParam = [kakaoDic objectForKey:@"ipadMarkParam"];
    }
    if ([[kakaoDic objectForKey:@"androidExecParam"] isKindOfClass:[NSString class]])
    {
        NSString* execStr = [kakaoDic objectForKey:@"androidExecParam"];
        androidExecParam = @{@"androidExecParam" : execStr};
    }
    if ([[kakaoDic objectForKey:@"ipadExecParams"] isKindOfClass:[NSString class]])
    {
        
        NSString* execStr = [kakaoDic objectForKey:@"ipadExecParams"];
        ipadExecParams = @{@"ipadExecParams" : execStr};
        
    }
    if ([[kakaoDic objectForKey:@"iphoneExecParams"] isKindOfClass:[NSString class]])
    {
        NSString* execStr = [kakaoDic objectForKey:@"iphoneExecParams"];
        iphoneExecParams = @{@"iphoneExecParams" : execStr};
    }
    if ([[kakaoDic objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
    {
        type = convertContentTypeWith([kakaoDic objectForKey:@"shareType"]);
    }
    
    [params SSDKSetupKaKaoParamsByText:text
                                images:images
                                 title:title
                                   url:[NSURL URLWithString:url]
                            permission:permission
                           enableShare:enableShare
                             imageSize:defaultSize
                        appButtonTitle:appButtonTitle
                      androidExecParam:androidExecParam
                      androidMarkParam:androidMarkParam
                      iphoneExecParams:iphoneExecParams
                       iphoneMarkParam:iphoneMarkParam
                        ipadExecParams:ipadExecParams
                         ipadMarkParam:ipadMarkParam
                                  type:type
                    forPlatformSubType:subType];
}

NSMutableDictionary *converPublicContent (NSDictionary *contentDict)
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *url = nil;
    NSString *text = nil;
    NSString *title = nil;
    NSMutableArray* imageArray = [NSMutableArray array];
    SSDKContentType type = SSDKContentTypeText;
    
    if (contentDict)
    {
        if ([[contentDict objectForKey:@"text"] isKindOfClass:[NSString class]])
        {
            text = [contentDict objectForKey:@"text"];
        }
        
        if ([[contentDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
        {
            NSString *imagePath = [contentDict objectForKey:@"imageUrl"];
            SSDKImage *image = nil;
            if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                    options:MOBFRegexOptionsNoOptions
                                    inRange:NSMakeRange(0, imagePath.length)
                                 withString:imagePath])
            {
                image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                
            }
            else
            {
                UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                image = [[SSDKImage alloc]initWithImage:localImage
                                                 format:SSDKImageFormatJpeg
                                               settings:nil];
                
            }
            
            if (image)
            {
                
                [imageArray addObject:imagePath];
            }
            else
            {
                NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
            }
        }
        else if([[contentDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
        {
            
            NSArray* paths = [contentDict objectForKey:@"imageUrl"];
            for (NSString* path in paths)
            {
                
                SSDKImage* image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, path.length)
                                     withString:path])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:path]];
                }
                else
                {
                    UIImage* localImg = [UIImage imageWithContentsOfFile:path];
                    image = [[SSDKImage alloc] initWithImage:localImg
                                                      format:SSDKImageFormatJpeg
                                                    settings:nil];
                }
                
                if (image)
                {
                    [imageArray addObject:path];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }
            }
        }
        if ([[contentDict objectForKey:@"url"] isKindOfClass:[NSString class]])
        {
            url = [contentDict objectForKey:@"url"];
        }
        if ([[contentDict objectForKey:@"title"] isKindOfClass:[NSString class]])
        {
            title = [contentDict objectForKey:@"title"];
        }
        if ([[contentDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
        {
            type = convertContentTypeWith([contentDict objectForKey:@"shareType"]);
        }
        
    }
    
    [params SSDKSetupShareParamsByText:text
                                images:imageArray
                                   url:[NSURL URLWithString:url]
                                 title:title
                                  type:type];
    
    
    
    
    NSDictionary *customizeShareParams = [contentDict objectForKey:@"customizeShareParams"];
    
    if (customizeShareParams)
    {
        //新浪
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSinaWeibo]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSinaWeibo]];
            NSString *text = nil;
            NSString *title = nil;
            NSString *image = nil;
            NSString *url = nil;
            double latitude;
            double longitude;
            NSString *objId = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"latitude"] isKindOfClass:[NSString class]])
            {
                latitude = [[customDict objectForKey:@"latitude"] doubleValue];
            }
            if ([[customDict objectForKey:@"longitude"] isKindOfClass:[NSString class]])
            {
                longitude = [[customDict objectForKey:@"longitude"] doubleValue];
            }
            if ([[customDict objectForKey:@"objectID"] isKindOfClass:[NSString class]])
            {
                objId = [customDict objectForKey:@"objectID"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupSinaWeiboShareParamsByText:text
                                                  title:title
                                                  image:image
                                                    url:[NSURL URLWithString:url]
                                               latitude:latitude
                                              longitude:longitude
                                               objectID:objId
                                                   type:type];
        }
        
        //腾讯微博
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTencentWeibo]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTencentWeibo]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            double latitude;
            double longitude;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                SSDKImage *image = nil;
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                     format:SSDKImageFormatJpeg
                                                   settings:nil];
                }
                
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }
                
            }
            else if([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                                format:SSDKImageFormatJpeg
                                                              settings:nil];
                    }
                    
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }
       
                }
            }
            if ([[customDict objectForKey:@"latitude"] isKindOfClass:[NSString class]])
            {
                latitude = [[customDict objectForKey:@"latitude"] doubleValue];
            }
            if ([[customDict objectForKey:@"longitude"] isKindOfClass:[NSString class]])
            {
                longitude = [[customDict objectForKey:@"longitude"] doubleValue];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
               type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupTencentWeiboShareParamsByText:text
                                                    images:images
                                                  latitude:latitude
                                                 longitude:longitude
                                                      type:type];
        }
        
        //豆瓣
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDouBan]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDouBan]];
            NSString *text = nil;
            NSString *image = nil;
            NSString *title = nil;
            NSString *url = nil;
            NSString *urlDesc = nil;
            SSDKContentType type = SSDKContentTypeText;
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"urlDesc"] isKindOfClass:[NSString class]])
            {
                urlDesc = [customDict objectForKey:@"urlDesc"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            [params SSDKSetupDouBanParamsByText:text
                                          image:image
                                          title:title
                                            url:[NSURL URLWithString:url]
                                        urlDesc:urlDesc
                                           type:type];
        }

        //微信系列
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeWechat]])
        {
            NSDictionary *wechatDic = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeWechat]];
            setWechatShareParmas(wechatDic, params, SSDKPlatformSubTypeWechatSession);
        }
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatSession]])
        {
            NSDictionary *wechatDic = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatSession]];
            setWechatShareParmas(wechatDic, params, SSDKPlatformSubTypeWechatSession);
        }
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatTimeline]])
        {
            NSDictionary *wechatDic = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatTimeline]];
            setWechatShareParmas(wechatDic, params, SSDKPlatformSubTypeWechatTimeline);
        }
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatFav]])
        {
            NSDictionary *wechatDic = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatFav]];
            setWechatShareParmas(wechatDic, params, SSDKPlatformSubTypeWechatFav);
        }
        
        //QQ系列
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQQFriend]])
        {
            NSDictionary *qqDic = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQQFriend]];
            setQQShareParmas(qqDic, params, SSDKPlatformSubTypeQQFriend);
        }
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQZone]])
        {
            NSDictionary *qqDic = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQZone]];
            setQQShareParmas(qqDic, params, SSDKPlatformSubTypeQZone);
        }
        
        //人人
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeRenren]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeRenren]];
            NSString *text = nil;
            NSString *image = nil;
            NSString *url = nil;
            NSString *albumId = nil;
            SSDKContentType type = SSDKContentTypeText;
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"albumID"] isKindOfClass:[NSString class]])
            {
                albumId = [customDict objectForKey:@"albumID"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            [params SSDKSetupRenRenParamsByText:text
                                          image:image
                                            url:[NSURL URLWithString:url]
                                        albumId:albumId
                                           type:type];
        }
        
        //开心
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKaixin]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKaixin]];
            NSString *text = nil;
            NSString *image = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
               type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            [params SSDKSetupKaiXinParamsByText:text
                                          image:image
                                           type:type];
        }
        
        //Facebook
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFacebook]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFacebook]];
            NSString *text = nil;
            NSString *image = nil;
            NSString *title = nil;
            NSString *urlDesc = nil;
            NSString *url = nil;
            NSString *attachementUrl = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"urlDesc"] isKindOfClass:[NSString class]])
            {
                urlDesc = [customDict objectForKey:@"urlDesc"];
            }
            if ([[customDict objectForKey:@"attachmentPath"] isKindOfClass:[NSString class]])
            {
                attachementUrl = [customDict objectForKey:@"attachmentPath"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = [[customDict objectForKey:@"shareType"] integerValue];
            }
            [params SSDKSetupFacebookParamsByText:text
                                            image:image
                                              url:[NSURL URLWithString:url]
                                         urlTitle:title
                                          urlName:urlDesc
                                   attachementUrl:[NSURL URLWithString:attachementUrl]
                                             type:type];
        }
        
        //Twitter
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTwitter]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTwitter]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            double latitude;
            double longitude;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                            format:SSDKImageFormatJpeg
                                                          settings:nil];
                }
                
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }

            }
            else if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                                format:SSDKImageFormatJpeg
                                                              settings:nil];
                    }
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }
                }
            }
            
            if ([[customDict objectForKey:@"latitude"] isKindOfClass:[NSString class]])
            {
                latitude = [[customDict objectForKey:@"latitude"] doubleValue];
            }
            if ([[customDict objectForKey:@"longitude"] isKindOfClass:[NSString class]])
            {
                longitude = [[customDict objectForKey:@"longitude"] doubleValue];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
               type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupTwitterParamsByText:text
                                          images:images
                                        latitude:latitude
                                       longitude:longitude
                                            type:type];
        }

        //印象笔记
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYinXiang]])
        {
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *title = nil;
            NSString *notebook = nil;
            NSMutableArray *tags = [NSMutableArray array];
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYinXiang]];
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                     format:SSDKImageFormatJpeg
                                                   settings:nil];
                }
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }

            }
            else if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                    }
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }

                }
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"notebook"] isKindOfClass:[NSString class]])
            {
                notebook = [customDict objectForKey:@"notebook"];
            }
            if ([[customDict objectForKey:@"tags"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [customDict objectForKey:@"tags"];
                [tags addObject:ricipient];
            }
            else if([[customDict objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [customDict objectForKey:@"tags"];
                tags = [recipientsArr mutableCopy];
            }
            
            [params SSDKSetupEvernoteParamsByText:text
                                           images:images
                                            title:title
                                         notebook:notebook
                                             tags:tags
                                     platformType:SSDKPlatformTypeYinXiang];
        }
        
        //Google+
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeGooglePlus]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeGooglePlus]];
            NSString *text = nil;
            NSString *url = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupGooglePlusParamsByText:text
                                                url:[NSURL URLWithString:url]
                                               type:type];
            
        }
        
        //instagram
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeInstagram]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeInstagram]];
            SSDKImage *image = nil;
            CGFloat menuX;
            CGFloat menuY;
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                     format:SSDKImageFormatJpeg
                                                   settings:nil];
                }
            }
            if ([[customDict objectForKey:@"menuX"] isKindOfClass:[NSNumber class]])
            {
                menuX = [[customDict objectForKey:@"menuX"] floatValue];
            }
            if ([[customDict objectForKey:@"menuY"] isKindOfClass:[NSNumber class]])
            {
                menuY = [[customDict objectForKey:@"menuY"] floatValue];
            }
            
            [params SSDKSetupInstagramByImage:image
                             menuDisplayPoint:CGPointMake(menuX, menuY)];
        }
        
        //LinkedIn
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLinkedIn]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLinkedIn]];
            NSString *text = nil;
            NSString *image = nil;
            NSString *url = nil;
            NSString *title = nil;
            NSString *urlDesc = nil;
            NSString *visibility = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"urlDesc"] isKindOfClass:[NSString class]])
            {
                urlDesc = [customDict objectForKey:@"urlDesc"];
            }
            if ([[customDict objectForKey:@"visibility"] isKindOfClass:[NSString class]])
            {
                visibility = [customDict objectForKey:@"visibility"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            [params SSDKSetupLinkedInParamsByText:text
                                            image:image
                                              url:[NSURL URLWithString:url]
                                            title:title
                                          urlDesc:urlDesc
                                       visibility:visibility
                                             type:type];
        }
        
        //Tumblr
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTumblr]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTumblr]];
            NSString *text = nil;
            NSString *image = nil;
            NSString *url = nil;
            NSString *title = nil;
            NSString *blogName = nil;
            SSDKContentType type = SSDKContentTypeText;
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"blogName"] isKindOfClass:[NSString class]])
            {
                blogName = [customDict objectForKey:@"blogName"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            [params SSDKSetupTumblrParamsByText:text
                                          image:image
                                            url:[NSURL URLWithString:url]
                                          title:title
                                       blogName:blogName
                                           type:type];
        }
        
        //Mail
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMail]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMail]];
            NSString *text = nil;
            NSString *title = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSMutableArray *attachments = [NSMutableArray array];
            NSMutableArray *recipients = [NSMutableArray array];
            NSMutableArray *ccRecipients = [NSMutableArray array];
            NSMutableArray *bccRecipients = [NSMutableArray array];
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
              
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                }
                
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }
                
            }
            else if([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                             format:SSDKImageFormatJpeg
                                                           settings:nil];
                    }
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }

                }
            }
            if ([[customDict objectForKey:@"attachmentPath"] isKindOfClass:[NSString class]])
            {
                NSData *attachmentsData = [NSData dataWithContentsOfFile:[customDict objectForKey:@"attachmentPath"]];
                [attachments addObject:attachmentsData];
            }
            else if ([[customDict objectForKey:@"attachmentPath"] isKindOfClass:[NSArray class]])
            {
                NSArray *attachmentsPaths = [customDict objectForKey:@"attachmentPath"];
                for (NSString *path in attachmentsPaths)
                {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    [attachments addObject:data];
                }
            }
            if ([[customDict objectForKey:@"recipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [customDict objectForKey:@"recipients"];
                [recipients addObject:ricipient];
            }
            else if([[customDict objectForKey:@"recipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [customDict objectForKey:@"recipients"];
                recipients = [recipientsArr mutableCopy];
            }
            
            if ([[customDict objectForKey:@"ccRecipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [customDict objectForKey:@"ccRecipients"];
                [ccRecipients addObject:ricipient];
            }
            else if([[customDict objectForKey:@"ccRecipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [customDict objectForKey:@"ccRecipients"];
                ccRecipients = [recipientsArr mutableCopy];
            }
            
            if ([[customDict objectForKey:@"bccRecipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [customDict objectForKey:@"bccRecipients"];
                [bccRecipients addObject:ricipient];
            }
            else if([[customDict objectForKey:@"bccRecipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [customDict objectForKey:@"bccRecipients"];
                bccRecipients = [recipientsArr mutableCopy];
            }
            
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
               type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupMailParamsByText:text
                                        title:title
                                       images:images
                                  attachments:attachments
                                   recipients:recipients
                                 ccRecipients:ccRecipients
                                bccRecipients:bccRecipients
                                         type:type];
        }

        //sms
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSMS]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSMS]];
            NSString *text = nil;
            NSString *title = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSMutableArray *attachments = [NSMutableArray array];
            NSMutableArray *recipients = [NSMutableArray array];
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                        format:SSDKImageFormatJpeg
                                                      settings:nil];
                }
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }

            }
            else if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                            format:SSDKImageFormatJpeg
                                                          settings:nil];
                    }
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }
                }
            }
            if ([[customDict objectForKey:@"attachmentPath"] isKindOfClass:[NSString class]])
            {
                NSData *attachmentsData = [NSData dataWithContentsOfFile:[customDict objectForKey:@"attachmentPath"]];
                [attachments addObject:attachmentsData];
            }
            else if ([[customDict objectForKey:@"attachmentPath"] isKindOfClass:[NSArray class]])
            {
                NSArray *attachmentsPaths = [customDict objectForKey:@"attachmentPath"];
                for (NSString *path in attachmentsPaths)
                {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    [attachments addObject:data];
                }
            }
            
            if ([[customDict objectForKey:@"recipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [customDict objectForKey:@"recipients"];
                [recipients addObject:ricipient];
            }
            else if([[customDict objectForKey:@"recipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [customDict objectForKey:@"recipients"];
                recipients = [recipientsArr mutableCopy];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupSMSParamsByText:text
                                       title:title
                                      images:images
                                 attachments:attachments
                                  recipients:recipients
                                        type:type];
        }
        
        //Copy
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeCopy]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeCopy]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *url = nil;
            SSDKContentType type = SSDKContentTypeText;
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                }
                
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }
                
            }
            else if([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                             format:SSDKImageFormatJpeg
                                                           settings:nil];
                    }
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }
                }
            }

            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
               type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            [params SSDKSetupCopyParamsByText:text
                                       images:images
                                          url:[NSURL URLWithString:url]
                                         type:type];
        }
        
        //Instapaper
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeInstapaper]])
        {
            NSString *url = nil;
            NSString *title = nil;
            NSString *desc = nil;
            NSString *content = nil;
            NSInteger folderId;
            BOOL isPrivateFromSource;
            BOOL resolveFinalUrl;
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeCopy]];

            
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"desc"] isKindOfClass:[NSString class]])
            {
                desc = [customDict objectForKey:@"desc"];
            }
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                content = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"folderId"] isKindOfClass:[NSNumber class]])
            {
                folderId = [[customDict objectForKey:@"folderId"] integerValue];
            }
            if ([[customDict objectForKey:@"isPrivateFromSource"] isKindOfClass:[NSNumber class]])
            {
                isPrivateFromSource = [[customDict objectForKey:@"isPrivateFromSource"] boolValue];
            }
            if ([[customDict objectForKey:@"resolveFinalUrl"] isKindOfClass:[NSNumber class]])
            {
                resolveFinalUrl = [[customDict objectForKey:@"resolveFinalUrl"] boolValue];
            }
            
            [params SSDKSetupInstapaperParamsByUrl:[NSURL URLWithString:url]
                                             title:title
                                              desc:desc
                                           content:content
                               isPrivateFromSource:isPrivateFromSource
                                          folderId:folderId
                                   resolveFinalUrl:resolveFinalUrl];
            
        }
        
        //pocket
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePocket]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePocket]];
            NSString *url = nil;
            NSString *title = nil;
            NSMutableArray *tags = [NSMutableArray array];
            NSString *tweetId = nil;
            
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"tags"] isKindOfClass:[NSString class]])
            {
                if ([customDict objectForKey:@"tags"] != nil)
                {
                    [tags addObject:[customDict objectForKey:@"tags"]];
                }
            }
            else if ([[customDict objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                tags = [[customDict objectForKey:@"tags"] mutableCopy];
            }
            if ([[customDict objectForKey:@"tweetID"] isKindOfClass:[NSString class]])
            {
                tweetId = [customDict objectForKey:@"tweetID"];
            }
            [params SSDKSetupPocketParamsByUrl:[NSURL URLWithString:url]
                                         title:title
                                          tags:tags
                                       tweetId:tweetId];
        }
        
        //youdao
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYouDaoNote]])
        {
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYouDaoNote]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *title = nil;
            NSString *source = nil;
            NSString *author = nil;
            NSString *notebook = nil;
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                }
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }
            }
            else if([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                             format:SSDKImageFormatJpeg
                                                           settings:nil];
                    }
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }
                }
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"source"] isKindOfClass:[NSString class]])
            {
                source  = [customDict objectForKey:@"source"];
            }
            if ([[customDict objectForKey:@"author"] isKindOfClass:[NSString class]])
            {
                author = [customDict objectForKey:@"author"];
            }
            if ([[customDict objectForKey:@"notebook"] isKindOfClass:[NSString class]])
            {
                notebook = [customDict objectForKey:@"notebook"];
            }
            [params SSDKSetupYouDaoNoteParamsByText:text
                                             images:images
                                              title:title
                                             source:source
                                             author:author
                                           notebook:notebook];
        }
        
        //Pinterest
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePinterest]])
        {
            NSString *decs = nil;
            NSString *url = nil;
            NSString *board = nil;
            NSString *image = nil;
            
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePinterest]];
            
            if ([[customDict objectForKey:@"decs"] isKindOfClass:[NSString class]])
            {
                decs = [customDict objectForKey:@"decs"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"board"] isKindOfClass:[NSString class]])
            {
                board = [customDict objectForKey:@"board"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }

            [params SSDKSetupPinterestParamsByImage:image
                                               desc:decs
                                                url:[NSURL URLWithString:url]
                                          boardName:board];
        }
        
        //Flickr
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFlickr]])
        {
            NSString *text = nil;
            NSString *image = nil;
            NSString *title = nil;
            NSArray *tags = [NSArray array];
            BOOL isPublic;
            BOOL isFriend;
            BOOL isFamily;
            NSInteger safetyLevel;
            NSInteger hidden;
            NSInteger contentType;
            
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFlickr]];
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                tags = [[customDict objectForKey:@"tages"] copy];
            }
            if ([[customDict objectForKey:@"isPublic"] isKindOfClass:[NSNumber class]])
            {
                isPublic = [[customDict objectForKey:@"isPublic"] boolValue];
            }
            if ([[customDict objectForKey:@"isFriend"] isKindOfClass:[NSNumber class]])
            {
                isFriend = [[customDict objectForKey:@"isFriend"] boolValue];
            }
            if ([[customDict objectForKey:@"isFamily"] isKindOfClass:[NSNumber class]])
            {
                isFamily = [[customDict objectForKey:@"isFamily"] boolValue];
            }
            if ([[customDict objectForKey:@"safetyLevel"] isKindOfClass:[NSNumber class]])
            {
                safetyLevel = [[customDict objectForKey:@"safetyLevel"] integerValue];
            }
            if ([[customDict objectForKey:@"hidden"] isKindOfClass:[NSNumber class]])
            {
                hidden = [[customDict objectForKey:@"hidden"] integerValue];
            }
            if ([[customDict objectForKey:@"contentType"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[customDict objectForKey:@"contentType"] integerValue];
            }
            [params SSDKSetupFlickrParamsByText:text
                                          image:image
                                          title:title
                                           tags:tags
                                       isPublic:isPublic
                                       isFriend:isFriend
                                       isFamily:isFamily
                                    safetyLevel:safetyLevel
                                    contentType:contentType
                                         hidden:hidden];
        }
        
        //dropbox
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDropbox]])
        {
            NSString *attachmentPath = nil;
            NSDictionary *dropBoxDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDropbox]];
            
            if ([[dropBoxDict objectForKey:@"attachmentPath"] isKindOfClass:[NSString class]])
            {
                attachmentPath = [dropBoxDict objectForKey:@"attachmentPath"];
            }
            [params SSDKSetupDropboxParamsByAttachment:attachmentPath];
        }

        //VKontakte
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeVKontakte]])
        {
       
           NSString *text = nil;
           NSMutableArray *images = [NSMutableArray array];
           NSString *url = nil;
           NSString *groupId = nil;
           BOOL friendsOnly;
           double latitude;
           double longitude;
           SSDKContentType type = SSDKContentTypeText;
           NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeVKontakte]];
           
           
           if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
           {
               text = [customDict objectForKey:@"text"];
           }
           if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
           {
               url = [customDict objectForKey:@"url"];
           }
           
           if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
           {
               NSString *imagePath = [customDict objectForKey:@"imageUrl"];
               SSDKImage *image = nil;
               if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                       options:MOBFRegexOptionsNoOptions
                                       inRange:NSMakeRange(0, imagePath.length)
                                    withString:imagePath])
               {
                   image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        
               }
               else
               {
                   UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                   image = [[SSDKImage alloc]initWithImage:localImage
                                                    format:SSDKImageFormatJpeg
                                                  settings:nil];
               }
               if (image)
               {
                   [images addObject:imagePath];
               }
               else
               {
                   NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
               }

               
           }
           else if([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
           {
               NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
               
               for (NSString *imagePath in imagePaths)
               {
                   SSDKImage *image = nil;
                   if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                           options:MOBFRegexOptionsNoOptions
                                           inRange:NSMakeRange(0, imagePath.length)
                                        withString:imagePath])
                   {
                       image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
     
                   }
                   else
                   {
                       UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                       image = [[SSDKImage alloc]initWithImage:localImage
                                                        format:SSDKImageFormatJpeg
                                                      settings:nil];
                   }
                   if (image)
                   {
                       [images addObject:imagePath];
                   }
                   else
                   {
                       NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                   }

               }
           }
           if ([[customDict objectForKey:@"groupID"] isKindOfClass:[NSString class]])
           {
               groupId = [customDict objectForKey:@"groupID"];
           }
           if ([[customDict objectForKey:@"friendsOnly"] isKindOfClass:[NSNumber class]])
           {
               friendsOnly = [[customDict objectForKey:@"friendsOnly"] boolValue];
           }
           if ([[customDict objectForKey:@"latitude"] isKindOfClass:[NSString class]])
           {
               latitude = [[customDict objectForKey:@"latitude"] doubleValue];
           }
           if ([[customDict objectForKey:@"longitude"] isKindOfClass:[NSString class]])
           {
               longitude = [[customDict objectForKey:@"longitude"] doubleValue];
           }
           if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
           {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
           }

           
           [params SSDKSetupVKontakteParamsByText:text
                                           images:images
                                              url:[NSURL URLWithString:url]
                                          groupId:groupId
                                      friendsOnly:friendsOnly
                                         latitude:latitude
                                        longitude:longitude
                                             type:type];
        }
        
        //易信系列
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYiXin]])
        {
            NSDictionary *yiXinDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYiXin]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformTypeYiXin);
        }
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinSession]])
        {
            NSDictionary *yiXinDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinSession]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformSubTypeYiXinSession);
        }
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinTimeline]])
        {
            NSDictionary *yiXinDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinTimeline]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformSubTypeYiXinTimeline);
        }
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinFav]])
        {
            NSDictionary *yiXinDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinFav]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformSubTypeYiXinFav);
        }
 
        //Mingdao
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMingDao]])
        {
            NSString *text = nil;
            NSString *image = nil;
            NSString *url = nil;
            NSString *title = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMingDao]];
            
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupMingDaoParamsByText:text
                                           image:image
                                             url:[NSURL URLWithString:url]
                                           title:title
                                            type:type];
            
        }
        
        //Line
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLine]])
        {
            NSString *text = nil;
            NSString *image = nil;
            SSDKContentType type = SSDKContentTypeText;
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLine]];
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupLineParamsByText:text
                                        image:image
                                         type:type];
            
        }
        
        //whatapp
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeWhatsApp]])
        {
            
            NSString *text = nil;
            NSString *image = nil;
            NSString *audioPath = nil;
            NSString *videoPath = nil;
            CGFloat menuX;
            CGFloat menuY;
            SSDKContentType type = SSDKContentTypeText;
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeWhatsApp]];

            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"audioPath"] isKindOfClass:[NSString class]])
            {
                audioPath = [customDict objectForKey:@"audioPath"];
            }

            if ([[customDict objectForKey:@"videoPath"] isKindOfClass:[NSString class]])
            {
                videoPath = [customDict objectForKey:@"videoPath"];
            }

            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"menuX"] isKindOfClass:[NSNumber class]])
            {
                menuX = [[customDict objectForKey:@"menuX"] floatValue];
            }
            if ([[customDict objectForKey:@"menuY"] isKindOfClass:[NSNumber class]])
            {
                menuY = [[customDict objectForKey:@"menuY"] floatValue];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupWhatsAppParamsByText:text
                                            image:image
                                            audio:audioPath
                                            video:videoPath
                                 menuDisplayPoint:CGPointMake(menuX, menuY)
                                             type:type];
        }
        
        //FacebookMessenger
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFacebookMessenger]])
        {
            NSString *imagePath = nil;
            NSString *gifPath = nil;
            NSString *audioPath = nil;
            NSString *videoPath = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFacebookMessenger]];

            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                imagePath = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"gifPath"] isKindOfClass:[NSString class]])
            {
                gifPath = [customDict objectForKey:@"gifPath"];
            }
            if ([[customDict objectForKey:@"audioPath"] isKindOfClass:[NSString class]])
            {
                audioPath = [customDict objectForKey:@"audioPath"];
            }
            if ([[customDict objectForKey:@"videoPath"] isKindOfClass:[NSString class]])
            {
                videoPath = [customDict objectForKey:@"videoPath"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }

            [params SSDKSetupFacebookMessengerParamsByImage:imagePath
                                                        gif:gifPath
                                                      audio:audioPath
                                                      video:videoPath
                                                       type:type];
        }

        //支付宝好友
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocial]])
        {
            NSString *text = nil;
            NSString *image = nil;
            NSString *title = nil;
            NSString *url = nil;
            SSDKContentType type = SSDKContentTypeText;
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocial]];

            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupAliPaySocialParamsByText:text
                                                image:image
                                                title:title
                                                  url:[NSURL URLWithString:url]
                                                 type:type platformType:SSDKPlatformTypeAliPaySocial];
        }
        
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocialTimeline]])
        {
            NSString *text = nil;
            NSString *image = nil;
            NSString *title = nil;
            NSString *url = nil;
            SSDKContentType type = SSDKContentTypeText;
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocialTimeline]];
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupAliPaySocialParamsByText:text
                                                image:image
                                                title:title
                                                  url:[NSURL URLWithString:url]
                                                 type:type platformType:SSDKPlatformTypeAliPaySocialTimeline];

        }

        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeKakaoTalk]])
        {
            NSDictionary *kakaoDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeKakaoTalk]];
            setKakaoShareParmas(kakaoDict, params, SSDKPlatformSubTypeKakaoTalk);
            
        }
        
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeKakaoStory]])
        {
            NSDictionary *kakaoDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeKakaoStory]];
            setKakaoShareParmas(kakaoDict, params, SSDKPlatformSubTypeKakaoStory);
        }
        
        //kakao系列
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKakao]])
        {
            
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *title = nil;
            NSString *url = nil;
            NSString *permission = nil;
            BOOL enableShare;
            double imageWidth = 0.0;
            double imageHeight;
            CGSize defaultSize = CGSizeMake(138, 80);
            
            NSString *appButtonTitle = nil;
            NSString *androidMarkParam = nil;
            NSString *iphoneMarkParam = nil;
            NSString *ipadMarkParam = nil;
            
            NSDictionary *androidExecParam = nil;
            NSDictionary *iphoneExecParams = nil;
            NSDictionary *ipadExecParams = nil;
            
            SSDKContentType type = SSDKContentTypeText;
            SSDKPlatformType subType = SSDKPlatformSubTypeKakaoTalk;
            
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKakao]];
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                     format:SSDKImageFormatJpeg
                                                   settings:nil];
    
                }
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }
                
            }
            else if([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                    }
                    
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }
                }
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"permission"] isKindOfClass:[NSString class]])
            {
                permission = [customDict objectForKey:@"permission"];
            }
            if ([[customDict objectForKey:@"enableShare"] isKindOfClass:[NSNumber class]])
            {
                enableShare = [[customDict objectForKey:@"enableShare"] boolValue];
            }
            if ([[customDict objectForKey:@"imageWidth"] isKindOfClass:[NSNumber class]])
            {
                imageWidth = [[customDict objectForKey:@"imageWidth"] floatValue];
            }
            if ([[customDict objectForKey:@"imageHeight"] isKindOfClass:[NSNumber class]])
            {
                imageHeight = [[customDict objectForKey:@"imageHeight"] floatValue];
            }
            if (imageHeight >= 0 && imageWidth >= 0)
            {
                defaultSize = CGSizeMake(imageWidth, imageHeight);
            }
            if ([[customDict objectForKey:@"appButtonTitle"] isKindOfClass:[NSString class]])
            {
                appButtonTitle = [customDict objectForKey:@"appButtonTitle"];
            }
            if ([[customDict objectForKey:@"androidMarkParam"] isKindOfClass:[NSString class]])
            {
                androidMarkParam = [customDict objectForKey:@"androidMarkParam"];
            }
            if ([[customDict objectForKey:@"iphoneMarkParam"] isKindOfClass:[NSString class]])
            {
                iphoneMarkParam = [customDict objectForKey:@"iphoneMarkParam"];
            }
            if ([[customDict objectForKey:@"ipadMarkParam"] isKindOfClass:[NSString class]])
            {
                ipadMarkParam = [customDict objectForKey:@"ipadMarkParam"];
            }
            if ([[customDict objectForKey:@"androidExecParam"] isKindOfClass:[NSString class]])
            {
                NSString* execStr = [customDict objectForKey:@"androidExecParam"];
                androidExecParam = @{@"androidExecParam" : execStr};
            }
            if ([[customDict objectForKey:@"ipadExecParams"] isKindOfClass:[NSString class]])
            {
                
                NSString* execStr = [customDict objectForKey:@"ipadExecParams"];
                ipadExecParams = @{@"ipadExecParams" : execStr};
                
            }
            if ([[customDict objectForKey:@"iphoneExecParams"] isKindOfClass:[NSString class]])
            {
                NSString* execStr = [customDict objectForKey:@"iphoneExecParams"];
                iphoneExecParams = @{@"iphoneExecParams" : execStr};
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            if ([[customDict objectForKey:@"subType"] isKindOfClass:[NSNumber class]])
            {
                subType = [[customDict objectForKey:@"subType"] integerValue];
            }
            
            [params SSDKSetupKaKaoParamsByText:text
                                        images:images
                                         title:title
                                           url:[NSURL URLWithString:url]
                                    permission:permission
                                   enableShare:enableShare
                                     imageSize:defaultSize
                                appButtonTitle:appButtonTitle
                              androidExecParam:androidExecParam
                              androidMarkParam:androidMarkParam
                              iphoneExecParams:iphoneExecParams
                               iphoneMarkParam:iphoneMarkParam
                                ipadExecParams:ipadExecParams
                                 ipadMarkParam:ipadMarkParam
                                          type:type
                            forPlatformSubType:subType];
            
        }

        //钉钉
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDingTalk]])
        {
            NSString *text = nil;
            NSString *image = nil;
            NSString *title = nil;
            NSString *url = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDingTalk]];
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                image = [customDict objectForKey:@"imageUrl"];
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [customDict objectForKey:@"url"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupDingTalkParamsByText:text
                                            image:image
                                            title:title
                                              url:[NSURL URLWithString:url]
                                             type:type];

        }
        
        //美拍
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMeiPai]])
        {
            NSString *videoPath = nil;
            SSDKContentType type = SSDKContentTypeVideo;
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMeiPai]];
            
            if ([[customDict objectForKey:@"videoPath"] isKindOfClass:[NSString class]])
            {
                videoPath = [customDict objectForKey:@"videoPath"];
            }
            if ([[customDict objectForKey:@"shareType"] isKindOfClass:[NSNumber class]])
            {
                type = convertContentTypeWith([customDict objectForKey:@"shareType"]);
            }
            
            [params SSDKSetupMeiPaiParamsByUrl:[NSURL URLWithString:videoPath]
                                          type:type];
        }
        
        //evernote
        if ([customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeEvernote]])
        {
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *title = nil;
            NSString *notebook = nil;
            NSMutableArray *tags = [NSMutableArray array];
            NSDictionary *customDict = [customizeShareParams objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeEvernote]];
            
            if ([[customDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [customDict objectForKey:@"text"];
            }
            if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [customDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, imagePath.length)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                     format:SSDKImageFormatJpeg
                                                   settings:nil];
                }
                if (image)
                {
                    [images addObject:imagePath];
                }
                else
                {
                    NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                }
            }
            else if ([[customDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [customDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, imagePath.length)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                    }
                    if (image)
                    {
                        [images addObject:imagePath];
                    }
                    else
                    {
                        NSLog(@"#waring : 检测不到有效图片路径,请检查传入图片的路径的有效性");
                    }
                }
            }
            if ([[customDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [customDict objectForKey:@"title"];
            }
            if ([[customDict objectForKey:@"notebook"] isKindOfClass:[NSString class]])
            {
                notebook = [customDict objectForKey:@"notebook"];
            }
            if ([[customDict objectForKey:@"tags"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [customDict objectForKey:@"tags"];
                [tags addObject:ricipient];
            }
            else if([[customDict objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [customDict objectForKey:@"tags"];
                tags = [recipientsArr mutableCopy];
            }
            
            [params SSDKSetupEvernoteParamsByText:text
                                           images:images
                                            title:title
                                         notebook:notebook
                                             tags:tags
                                     platformType:SSDKPlatformTypeEvernote];
        }
        
        
    }
    
    return params;
}

void ShareSDKRegisterAppAndSetPlatformConfig (NSDictionary *params)
{
    NSString *appKey = nil;
    NSMutableArray *platforms = nil;
    NSDictionary *platformConfig = [NSDictionary dictionary];
    if ([params objectForKey:@"appkey"])
    {
        appKey = [params objectForKey:@"appkey"];
    }
    if ([[params objectForKey:@"config"] isKindOfClass:[NSDictionary class]])
    {
        platformConfig = [params objectForKey:@"config"];
        platforms = [NSMutableArray arrayWithArray:[platformConfig allKeys]];
    }

    [ShareSDK registerActivePlatforms:platforms
                 onImport:^(SSDKPlatformType platformType) {
                     switch (platformType)
                     {
                        case SSDKPlatformTypeSinaWeibo:
                             
#ifdef __SHARESDK_SINA_WEIBO__
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
#endif
                             break;
                             
                         case SSDKPlatformTypeWechat:
#ifdef __SHARESDK_WECHAT__
                             [ShareSDKConnector connectWeChat:[WXApi class]];
#endif
                            
                             break;
                             
                         case SSDKPlatformTypeQQ:
                   
#ifdef __SHARESDK_QQ__
                             [ShareSDKConnector connectQQ:[QQApiInterface class]
                                        tencentOAuthClass:[TencentOAuth class]];
#endif
                             break;
                         case SSDKPlatformTypeRenren:
#ifdef __SHARESDK_RENREN__
                             [ShareSDKConnector connectRenren:[RennClient class]];
#endif
                             break;
                         case SSDKPlatformTypeKakao:
#ifdef __SHARESDK_KAKAO__
                             [ShareSDKConnector connectKaKao:[KOSession class]];
#endif
                             break;
                         case SSDKPlatformTypeYiXin:
                             
#ifdef __SHARESDK_YIXIN__
                             [ShareSDKConnector connectYiXin:[YXApi class]];
#endif
                             break;
                             
                         case SSDKPlatformTypeAliPaySocial:
                             
#ifdef __SHARESDK_APSOCIAL__
                             [ShareSDKConnector connectAliPaySocial:[APOpenAPI class]];
#endif
                             break;
                        case  SSDKPlatformTypeFacebookMessenger:
#ifdef __SHARESDK_FACEBOOK_MSG__
                             [ShareSDKConnector connectFacebookMessenger:[FBSDKMessengerSharer class]];
#endif
                             break;
                             
                         case SSDKPlatformTypeDingTalk:
#ifdef __SHARESDK_DINGTALK__
                             [ShareSDKConnector connectDingTalk:[DTOpenAPI class]];
#endif
                             break;
                         case SSDKPlatformTypeMeiPai:
#ifdef __SHARESDK_MEIPAI__
                             [ShareSDKConnector connectMeiPai:[MPShareSDK class]];
#endif
                             break;
                         default:
                             break;
                     }
                     
                     
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
    
        
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
            {
                
                NSArray *weChatTypes = @[@(SSDKPlatformTypeWechat),
                                         @(SSDKPlatformSubTypeWechatSession),
                                         @(SSDKPlatformSubTypeWechatTimeline),
                                         @(SSDKPlatformSubTypeWechatFav)];

                [weChatTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    NSDictionary *wechatDict = [platformConfig objectForKey:[NSString stringWithFormat:@"%@",obj]];
                    
                    if (wechatDict && [[wechatDict allKeys] count] > 0)
                    {
                        [appInfo SSDKSetupWeChatByAppId:[wechatDict objectForKey:@"app_id"]
                                              appSecret:[wechatDict objectForKey:@"app_secret"]];
                        *stop = YES;
                    }

                }];
                break;
            }
            case SSDKPlatformTypeQQ:
            {
                NSArray *QQTypes = @[@(SSDKPlatformTypeQQ),
                                     @(SSDKPlatformSubTypeQQFriend),
                                     @(SSDKPlatformSubTypeQZone)];
                [QQTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                   
                    NSDictionary *QQDict = [platformConfig objectForKey:[NSString stringWithFormat:@"%@",obj]];
                    
                    if (QQDict && [[QQDict allKeys] count] > 0)
                    {
                        [appInfo SSDKSetupQQByAppId:[QQDict objectForKey:@"app_id"]
                                             appKey:[QQDict objectForKey:@"app_key"]
                                           authType:[QQDict objectForKey:@"auth_type"]];
                        *stop = YES;
                    }
                }];
                break;
            }
            case SSDKPlatformTypeKakao:
            {
                NSArray *KakaoTypes = @[@(SSDKPlatformTypeKakao),
                                     @(SSDKPlatformSubTypeKakaoTalk),
                                     @(SSDKPlatformSubTypeKakaoStory)];

                [KakaoTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                   
                    NSDictionary *customDict = [platformConfig objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)obj]];
                    
                    if (customDict && [[customDict allKeys] count] > 0)
                    {
                        [appInfo SSDKSetupKaKaoByAppKey:[customDict objectForKey:@"app_key"]
                                             restApiKey:[customDict objectForKey:@"rest_api_key"]
                                            redirectUri:[customDict objectForKey:@"redirect_uri"]
                                               authType:[customDict objectForKey:@"auth_type"]];
                        
                        *stop = YES;
                    }
                }];
                
                break;
            }
            case SSDKPlatformTypeYiXin:
            {
                NSArray *yiXinTypes = @[@(SSDKPlatformTypeYiXin),
                                        @(SSDKPlatformSubTypeYiXinSession),
                                        @(SSDKPlatformSubTypeYiXinTimeline),
                                        @(SSDKPlatformSubTypeYiXinFav)];
                
                [yiXinTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    NSDictionary *yixinDict = [platformConfig objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)obj]];
                    
                    if (yixinDict && [[yixinDict allKeys] count] > 0)
                    {
                        [appInfo SSDKSetupYiXinByAppId:[yixinDict objectForKey:@"app_id"]
                                             appSecret:[yixinDict objectForKey:@"app_secret"]
                                           redirectUri:[yixinDict objectForKey:@"redirect_uri"]
                                              authType:[yixinDict objectForKey:@"auth_type"]];
                        
                        *stop = YES;
                    }
                }];
                break;
            }
            case SSDKPlatformTypeAliPaySocial:
            {
                NSDictionary *platformDict = nil;
                NSDictionary *dictFromAliPaySocial = [platformConfig objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocial]];
                NSDictionary *dictFromAliPaySocialTimeline = [platformConfig objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocialTimeline]];
                if (dictFromAliPaySocial)
                {
                    platformDict = dictFromAliPaySocial;
                }
                else
                {
                    platformDict = dictFromAliPaySocialTimeline;
                }
                [appInfo addEntriesFromDictionary:platformDict];
                break;
            }
            default:
            {
                NSDictionary *confDict = [platformConfig objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)platformType]];
                [appInfo addEntriesFromDictionary:confDict];
                break;
            }
        }
    }];
}


void ShareSDKAuthorize (FREContext ctx, NSDictionary *params)
{
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    NSUInteger reqId;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }
    [ShareSDK authorize:platType
               settings:nil
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         NSString *code = @"SSDK_PA";
         
         NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:1],
                                      @"action",
                                      [NSNumber numberWithInteger:state],
                                      @"status",
                                      [NSNumber numberWithInteger:platType],
                                      @"platform",
                                      [NSNumber numberWithUnsignedInteger:reqId],
                                      @"reqId",
                                      nil];

         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 if ([[user credential] rawData])
                 {
                     [data setObject:[[user credential] rawData] forKey:@"res"];
                 }
                 break;
             }
             case SSDKResponseStateFail:
             {
                 
                 NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]]
                                                                               forKey:@"error_code"];
                 if ([[error userInfo] objectForKey:@"error_message"])
                 {
                     [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                 }
                 [data setObject:err forKey:@"res"];
                 
                 break;
             }
             default:
                 break;
         }

         NSString *dataStr = [MOBFJson jsonStringFromObject:data];
         
         FREDispatchStatusEventAsync(ctx,
                                     (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                     (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);
    }];
    
}

FREObject ShareSDKHasAuthroized (NSDictionary *params)
{
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    BOOL retValue = [ShareSDK hasAuthorized:platType];
    FREObject retObj = NULL;
    if (FRENewObjectFromBool(retValue, &retObj) == FRE_OK)
    {
        return retObj;
    }
    
        return NULL;
   
}

void ShareSDKCancelAuthorize (NSDictionary *params)
{
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    
    [ShareSDK cancelAuthorize:platType];
}

void ShareSDKGetUserInfo (FREContext ctx, NSDictionary *params)
{
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    NSUInteger reqId;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }

    [ShareSDK getUserInfo:platType
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               
               NSString *code = @"SSDK_PA";
               NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInteger:8],
                                            @"action",
                                            [NSNumber numberWithInteger:state],
                                            @"status",
                                            [NSNumber numberWithInteger:platType],
                                            @"platform",
                                            [NSNumber numberWithUnsignedInteger:reqId],
                                            @"reqId",
                                            nil];
               
               switch (state)
               {
                   case SSDKResponseStateSuccess:
                   {
                       if ([user rawData])
                       {
                           [data setObject:[user rawData] forKey:@"res"];
                       }
                       break;
                   }
                   case SSDKResponseStateFail:
                   {
                       NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                       if ([[error userInfo] objectForKey:@"error_message"])
                       {
                           [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                       }
                       [data setObject:err forKey:@"res"];

                       break;
                   }
                   default:
                       break;
               }

               
               NSString *dataStr = [MOBFJson jsonStringFromObject:data];
               
               FREDispatchStatusEventAsync(ctx,
                                           (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                           (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);

               
               
           }];
    
}

void ShareSDKShare (FREContext ctx, NSDictionary *params)
{
    NSUInteger reqId;
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        shareParams = converPublicContent([params objectForKey:@"shareParams"]);
    }
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }
    [ShareSDK share:platType
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         
         NSString *code = @"SSDK_PA";
         
         NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
         
         NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:9],
                                      @"action",
                                      [NSNumber numberWithInteger:state] ,
                                      @"status",
                                      [NSNumber numberWithInteger:platType],
                                      @"platform",
                                      [NSNumber numberWithUnsignedInteger:reqId],
                                      @"reqId",
                                      resDict,
                                      @"res",
                                      nil];
         
         
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 if ([contentEntity rawData])
                 {
                     [resDict setObject:[NSNumber numberWithBool:YES] forKey:@"end"];
                     [resDict setObject:[contentEntity rawData] forKey:@"data"];
                     
                 }
                 break;
             }
             case SSDKResponseStateFail:
             {
                 NSMutableDictionary *errDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                 
                 if ([[error userInfo] objectForKey:@"error_message"])
                 {
                     [errDict setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                 }
                 [resDict setObject:errDict forKey:@"error"];
                 [resDict setObject:[NSNumber numberWithBool:YES] forKey:@"end"];

                 break;
             }
             default:
                 break;
         }

         NSString *dataStr = [MOBFJson jsonStringFromObject:data];
         
         FREDispatchStatusEventAsync(ctx,
                                     (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                     (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);
         
     }];
    
}

void ShareSDKOneKeyShare (FREContext ctx, NSDictionary *params)
{
    NSUInteger reqId;
    NSMutableArray *platTypes = [NSMutableArray array];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }
    if ([[params objectForKey:@"platforms"] isKindOfClass:[NSArray class]])
    {
        NSArray *customItems = [params objectForKey:@"platforms"];
        
        [customItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [platTypes addObject:[NSNumber numberWithInteger:[obj integerValue]]];
            
        }];
        
    }
    else
    {
        SSDKPlatformType platType = SSDKPlatformTypeAny;
        platType = (SSDKPlatformType)[[params objectForKey:@"platforms"] integerValue];
        [platTypes addObject:@(platType)];
        
    }
    
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        shareParams = converPublicContent([params objectForKey:@"shareParams"]);
    }
    
    [SSEShareHelper oneKeyShare:platTypes
                     parameters:shareParams
                 onStateChanged:^(SSDKPlatformType platformType, SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                     NSString *code = @"SSDK_PA";
                     
                     NSMutableDictionary *resDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:end]
                                                                                       forKey:@"end"];
                     NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:9],
                                                  @"action",
                                                  [NSNumber numberWithInteger:state],
                                                  @"status",
                                                  [NSNumber numberWithInteger:platformType],
                                                  @"platform",
                                                  [NSNumber numberWithUnsignedInteger:reqId],
                                                  @"reqId",
                                                  resDict,
                                                  @"res",
                                                  nil];
                     
                     switch (state)
                     {
                         case SSDKResponseStateSuccess:
                         {
                             if ([contentEntity rawData])
                             {
                                 [resDict setObject:[contentEntity rawData] forKey:@"data"];
                             }
                             
                             break;
                         }
                         case SSDKResponseStateFail:
                         {
                             NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                             if ([[error userInfo] objectForKey:@"error_message"])
                             {
                                 [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                             }
                             [resDict setObject:err forKey:@"error"];
                             
                             break;
                         }
                         default:
                             break;
                     }

                     NSString *dataStr = [MOBFJson jsonStringFromObject:data];
                     
                     //派发事件
                     FREDispatchStatusEventAsync(ctx,
                                                 (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                                 (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);

                 }];
    
}

void ShareSDKShareWithContentName (FREContext ctx, NSDictionary *params)
{
    NSUInteger reqId;
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    NSString *contentName = @"";
    NSDictionary *customFields = nil;
    
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }
    if ([params objectForKey:@"contentName"])
    {
        contentName = [params objectForKey:@"contentName"];
    }
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"customFields"] isKindOfClass:[NSDictionary class]])
    {
        customFields = [params objectForKey:@"customFields"];
    }
    
    [ShareSDK shareWithContentName:contentName
                          platform:platType
                      customFields:customFields
                    onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                       
                        NSString *code = @"SSDK_PA";
                        
                        NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
                        
                        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNumber numberWithInteger:9],
                                                     @"action",
                                                     [NSNumber numberWithInteger:state] ,
                                                     @"status",
                                                     [NSNumber numberWithInteger:platType],
                                                     @"platform",
                                                     [NSNumber numberWithUnsignedInteger:reqId],
                                                     @"reqId",
                                                     resDict,
                                                     @"res",
                                                     nil];
                        
                        
                        switch (state)
                        {
                            case SSDKResponseStateSuccess:
                            {
                                if ([contentEntity rawData])
                                {
                                    [resDict setObject:[NSNumber numberWithBool:YES] forKey:@"end"];
                                    [resDict setObject:[contentEntity rawData] forKey:@"data"];
                                    
                                }
                                break;
                            }
                            case SSDKResponseStateFail:
                            {
                                NSMutableDictionary *errDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                                
                                if ([[error userInfo] objectForKey:@"error_msg"])
                                {
                                    [errDict setObject:[[error userInfo] objectForKey:@"error_msg"] forKey:@"error_msg"];
                                }
                                [resDict setObject:errDict forKey:@"error"];
                                [resDict setObject:[NSNumber numberWithBool:YES] forKey:@"end"];
                                
                                break;
                            }
                            default:
                                break;
                        }
                        
                        NSString *dataStr = [MOBFJson jsonStringFromObject:data];
                        
                        FREDispatchStatusEventAsync(ctx,
                                                    (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                                    (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);

                    }];
    
}

void ShareSDKShowShareMenu (FREContext ctx, NSDictionary *params)
{

    @try {
        NSInteger x = 0;
        NSInteger y = 0;
        NSUInteger reqId;
        NSMutableArray *platTypes = [NSMutableArray array];
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
        {
            reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
        }
        if ([[params objectForKey:@"platforms"] isKindOfClass:[NSArray class]])
        {
            NSArray *customItems = [params objectForKey:@"platforms"];
            
           [customItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
              
               [platTypes addObject:[NSNumber numberWithInteger:[obj integerValue]]];
 
           }];
            
        }
        else
        {
            [[ShareSDK activePlatforms] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
              
                [platTypes addObject:[NSNumber numberWithInteger:[obj integerValue]]];
            }];
        }
    
        if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
        {
            shareParams = converPublicContent([params objectForKey:@"shareParams"]);
            
        }
        if ([[params objectForKey:@"x"] isKindOfClass:[NSNumber class]])
        {
            x = [[params objectForKey:@"x"] integerValue];
        }
        if ([[params objectForKey:@"y"] isKindOfClass:[NSNumber class]])
        {
            y = [[params objectForKey:@"y"] integerValue];
        }
        if ([MOBFDevice isPad])
        {
            if (!_refView)
            {
                _refView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 10, 10)];
            }
            
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_refView];
            
        }
        
        [ShareSDK showShareActionSheet:_refView
                                 items:platTypes
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       NSString *code = @"SSDK_PA";
                       
                       NSMutableDictionary *resDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:end]
                                                                                         forKey:@"end"];
                       
                       NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:9],
                                                    @"action",
                                                    [NSNumber numberWithInteger:state],
                                                    @"status",
                                                    [NSNumber numberWithInteger:platformType],
                                                    @"platform",
                                                    [NSNumber numberWithUnsignedInteger:reqId],
                                                    @"reqId",
                                                    resDict,
                                                    @"res",
                                                    nil];
                       
                       switch (state)
                       {
                           case SSDKResponseStateSuccess:
                           {
                               if ([contentEntity rawData])
                               {
                                   [resDict setObject:[contentEntity rawData] forKey:@"data"];
                               }
                               
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                               if ([[error userInfo] objectForKey:@"error_message"])
                               {
                                   [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                               }
                               [resDict setObject:err forKey:@"error"];

                               break;
                           }
                           default:
                               break;
                       }
                       
                       NSString *dataStr = [MOBFJson jsonStringFromObject:data];
   
                       //派发事件
                       FREDispatchStatusEventAsync(ctx,
                                                   (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                                   (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);
                       
                       if (_refView)
                       {
                           //移除视图
                           [_refView removeFromSuperview];
                       }

                   }];
        
    }
    @catch (NSException *exception) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[exception reason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

void ShareSDKShowShareView (FREContext ctx, NSDictionary *params)
{
    NSUInteger reqId;
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        shareParams = converPublicContent([params objectForKey:@"shareParams"]);
    }
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }

    [ShareSDK showShareEditor:platType
           otherPlatformTypes:nil
                  shareParams:shareParams
          onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
              NSString *code = @"SSDK_PA";
              
              NSMutableDictionary *resDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:end]
                                                                                forKey:@"end"];
              
              NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:9],
                                           @"action",
                                           [NSNumber numberWithInteger:state],
                                           @"status",
                                           [NSNumber numberWithInteger:platformType],
                                           @"platform",
                                           [NSNumber numberWithUnsignedInteger:reqId],
                                           @"reqId",
                                           resDict,
                                           @"res",
                                           nil];
              
              switch (state)
              {
                  case SSDKResponseStateSuccess:
                  {
                      if ([contentEntity rawData])
                      {
                          [resDict setObject:[contentEntity rawData] forKey:@"data"];
                      }

                      break;
                  }
                  case SSDKResponseStateFail:
                  {
                      NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                      if ([[error userInfo] objectForKey:@"error_message"])
                      {
                          [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                      }
                      [resDict setObject:err forKey:@"error"];
                      break;
                  }
                  default:
                      break;
              }
              
              NSString *dataStr = [MOBFJson jsonStringFromObject:data];
              
              //派发事件
              FREDispatchStatusEventAsync(ctx,
                                          (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                          (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);
              

          }];
    
}

void ShareSDKShowShareMenuByContentName (FREContext ctx, NSDictionary *params)
{

    @try {
        NSInteger x = 0;
        NSInteger y = 0;
        NSUInteger reqId;
        NSString *contentName;
        NSDictionary *customFields = nil;
        NSMutableArray *platTypes = [NSMutableArray array];
        
        if ([[params objectForKey:@"platforms"] isKindOfClass:[NSArray class]])
        {
            NSArray *customItems = [params objectForKey:@"platforms"];
            
            [customItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [platTypes addObject:[NSNumber numberWithInteger:[obj integerValue]]];
                
            }];
            
        }
        else
        {
            [[ShareSDK activePlatforms] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [platTypes addObject:[NSNumber numberWithInteger:[obj integerValue]]];
            }];
        }
        if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
        {
            reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
        }
        if ([[params objectForKey:@"x"] isKindOfClass:[NSNumber class]])
        {
            x = [[params objectForKey:@"x"] integerValue];
        }
        if ([[params objectForKey:@"y"] isKindOfClass:[NSNumber class]])
        {
            y = [[params objectForKey:@"y"] integerValue];
        }
        if ([params objectForKey:@"contentName"])
        {
            contentName = [params objectForKey:@"contentName"];
        }
        if ([[params objectForKey:@"customFields"] isKindOfClass:[NSDictionary class]])
        {
            customFields = [params objectForKey:@"customFields"];
        }
        if ([MOBFDevice isPad])
        {
            if (!_refView)
            {
                _refView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 10, 10)];
            }
            
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_refView];
        }
        
        [ShareSDK showShareActionSheet:_refView
                                 items:platTypes
                           contentName:contentName
                          customFields:customFields
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       NSString *code = @"SSDK_PA";
                       
                       NSMutableDictionary *resDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:end]
                                                                                         forKey:@"end"];
                       
                       NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:9],
                                                    @"action",
                                                    [NSNumber numberWithInteger:state],
                                                    @"status",
                                                    [NSNumber numberWithInteger:platformType],
                                                    @"platform",
                                                    [NSNumber numberWithUnsignedInteger:reqId],
                                                    @"reqId",
                                                    resDict,
                                                    @"res",
                                                    nil];
                       
                       switch (state)
                       {
                           case SSDKResponseStateSuccess:
                           {
                               if ([contentEntity rawData])
                               {
                                   [resDict setObject:[contentEntity rawData] forKey:@"data"];
                               }
                               
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                               if ([[error userInfo] objectForKey:@"error_message"])
                               {
                                   [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                               }
                               [resDict setObject:err forKey:@"error"];
                               
                               break;
                           }
                           default:
                               break;
                       }
                       
                       NSString *dataStr = [MOBFJson jsonStringFromObject:data];
                       
                       //派发事件
                       FREDispatchStatusEventAsync(ctx,
                                                   (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                                   (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);
                       
                       if (_refView)
                       {
                           //移除视图
                           [_refView removeFromSuperview];
                       }

                   }];
        
    } @catch (NSException *exception) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[exception reason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

void ShareSDKShowShareViewByContentName (FREContext ctx, NSDictionary *params)
{
    NSUInteger reqId;
    NSString *contentName;
    NSDictionary *customFields = nil;
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }
    if ([params objectForKey:@"contentName"])
    {
        contentName = [params objectForKey:@"contentName"];
    }
    if ([[params objectForKey:@"customFields"] isKindOfClass:[NSDictionary class]])
    {
        customFields = [params objectForKey:@"customFields"];
    }
    
    [ShareSDK showShareEditor:platType
           otherPlatformTypes:nil
                  contentName:contentName
                 customFields:customFields
          onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
             
              
              NSString *code = @"SSDK_PA";
              
              NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
              
              NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:9],
                                           @"action",
                                           [NSNumber numberWithInteger:state] ,
                                           @"status",
                                           [NSNumber numberWithInteger:platType],
                                           @"platform",
                                           [NSNumber numberWithUnsignedInteger:reqId],
                                           @"reqId",
                                           resDict,
                                           @"res",
                                           nil];
              
              
              switch (state)
              {
                  case SSDKResponseStateSuccess:
                  {
                      if ([contentEntity rawData])
                      {
                          [resDict setObject:[NSNumber numberWithBool:YES] forKey:@"end"];
                          [resDict setObject:[contentEntity rawData] forKey:@"data"];
                          
                      }
                      break;
                  }
                  case SSDKResponseStateFail:
                  {
                      NSMutableDictionary *errDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]] forKey:@"error_code"];
                      
                      if ([[error userInfo] objectForKey:@"error_msg"])
                      {
                          [errDict setObject:[[error userInfo] objectForKey:@"error_msg"] forKey:@"error_msg"];
                      }
                      [resDict setObject:errDict forKey:@"error"];
                      [resDict setObject:[NSNumber numberWithBool:YES] forKey:@"end"];
                      
                      break;
                  }
                  default:
                      break;
              }
              
              NSString *dataStr = [MOBFJson jsonStringFromObject:data];
              
              FREDispatchStatusEventAsync(ctx,
                                          (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                          (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);

          }];
    
}

void ShareSDKToast (NSDictionary *params)
{
    NSString *message = nil;
    if ([[params objectForKey:@"message"] isKindOfClass:[NSString class]])
    {
        message = [params objectForKey:@"message"];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tips"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

void ShareSDKHandleOpenURL (NSDictionary *params)
{

   
}

FREObject ShareSDKCheckClient (NSDictionary *params)
{
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    BOOL value = [ShareSDK isClientInstalled:platType];
    
    FREObject retObj = NULL;
    if (FRENewObjectFromBool(value, &retObj) == FRE_OK)
    {
        return retObj;
    }
    else
    {
        return NULL;
    }
}

FREObject ShareSDKGetCredential (NSDictionary *params)
{
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    
    SSDKUser* userInfo = [ShareSDK currentUser:platType];
    SSDKCredential *credential = userInfo.credential;
    
    if (!credential)
    {
        NSString *nullStr = @"Invalid Authorization";
        const char *cStr = [nullStr UTF8String];
        
        FREObject retStr;
        FRENewObjectFromUTF8((uint32_t)(strlen(cStr)+1), (const uint8_t*)cStr, &retStr);
        
        return retStr;
    }
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    [resultDict setObject:[NSNumber numberWithInteger:platType] forKey:@"type"];
    
    if ([credential available])
    {
        if ([credential uid])
        {
            [resultDict setObject:[credential uid] forKey:@"uid"];
        }
        if ([credential token])
        {
            [resultDict setObject:[credential token] forKey:@"token"];
        }
        if ([credential secret])
        {
            [resultDict setObject:[credential secret] forKey:@"secret"];
        }
        if ([credential expired])
        {
            [resultDict setObject:@([[credential expired] timeIntervalSince1970]) forKey:@"expired"];
        }
        
        [resultDict setObject:[NSNumber numberWithBool:[credential available]] forKey:@"available"];
        
    }
    else
    {
        [resultDict setObject:[NSNumber numberWithBool:NO] forKey:@"available"];
        [resultDict setObject:@"Invalid Authorization" forKey:@"error"];
    }
    
    NSString *resultStr = [MOBFJson jsonStringFromObject:resultDict];
    const char *cStr = [resultStr UTF8String];
    
    FREObject retStr;
    FRENewObjectFromUTF8((uint32_t)(strlen(cStr)+1), (const uint8_t*)cStr, &retStr);

    return retStr;
}


void ShareSDKAddFriend (FREContext ctx, NSDictionary *params)
{
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    NSString *account = nil;
    NSUInteger reqId;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"account"] isKindOfClass:[NSString class]])
    {
        account = [params objectForKey:@"account"];
    }
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }
    
    SSDKUser *user = [[SSDKUser alloc] init];
    user.uid = account;
    if (platType == SSDKPlatformTypeTencentWeibo)
    {
        user.uid = nil;
        user.nickname = account;
    }
    
    [ShareSDK addFriend:platType
                   user:user
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
             
             NSString *code = @"SSDK_PA";
             
             NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:6],
                                          @"action",
                                          [NSNumber numberWithInteger:state],
                                          @"status",
                                          [NSNumber numberWithInteger:platType],
                                          @"platform",
                                          [NSNumber numberWithUnsignedInteger:reqId],
                                          @"reqId",
                                          nil];

             switch (state)
             {
                 case SSDKResponseStateSuccess:
                 {
                     if ([user rawData])
                     {
                         [data setObject:[user rawData] forKey:@"res"];
                     }
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     
                     NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]]
                                                                                   forKey:@"error_code"];
                     if ([[error userInfo] objectForKey:@"error_message"])
                     {
                         [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                     }
                     else
                     {
                         [err setObject:[error userInfo] forKey:@"error_userInfo"];

                     }
                     [data setObject:err forKey:@"res"];
                     
                     break;
                 }
                 default:
                     break;
             }
             
             NSString *dataStr = [MOBFJson jsonStringFromObject:data];
             FREDispatchStatusEventAsync(ctx,
                                         (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                         (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);
             
         }];
    
}

void ShareSDKGetFriendsList (FREContext ctx, NSDictionary *params)
{
    
    SSDKPlatformType platType = SSDKPlatformTypeAny;
    NSUInteger count;
    NSUInteger page;
    NSUInteger reqId;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        platType = (SSDKPlatformType)[[params objectForKey:@"platform"] integerValue];
    }
    if ([[params objectForKey:@"count"] isKindOfClass:[NSNumber class]])
    {
        count = [[params objectForKey:@"count"] unsignedIntegerValue];
    }
    if ([[params objectForKey:@"page"] isKindOfClass:[NSNumber class]])
    {
        page = [[params objectForKey:@"page"] unsignedIntegerValue];
    }
    if ([[params objectForKey:@"reqId"] isKindOfClass:[NSNumber class]])
    {
        reqId = [[params objectForKey:@"reqId"] unsignedIntegerValue];
    }
    [ShareSDK getFriends:platType
                  cursor:page
                    size:count
          onStateChanged:^(SSDKResponseState state, SSDKFriendsPaging *paging, NSError *error) {
             
              NSString *code = @"SSDK_PA";
              
              NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:2],
                                           @"action",
                                           [NSNumber numberWithInteger:state],
                                           @"status",
                                           [NSNumber numberWithInteger:platType],
                                           @"platform",
                                           [NSNumber numberWithUnsignedInteger:reqId],
                                           @"reqId",
                                           nil];

              
              switch (state)
              {
                  case SSDKResponseStateSuccess:
                  {
                      
                      NSMutableDictionary* resDict = [NSMutableDictionary dictionary];
                      [resDict setObject:paging.users forKey:@"users"];
                      [resDict setObject:[NSNumber numberWithInteger:paging.prevCursor] forKey:@"prev_cursor"];
                      [resDict setObject:[NSNumber numberWithInteger:paging.nextCursor] forKey:@"next_cursor"];
                      [resDict setObject:[NSNumber numberWithUnsignedInteger:paging.total] forKey:@"total"];
                      [resDict setObject:[NSNumber numberWithBool:paging.hasNext] forKey:@"has_next"];
                      [data setObject:resDict forKey:@"res"];
                      
                      break;
                  }
                      
                  case SSDKResponseStateFail:
                  {
                      NSMutableDictionary *err = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:[error code]]
                                                                                    forKey:@"error_code"];
                      if ([[error userInfo] objectForKey:@"error_message"])
                      {
                          [err setObject:[[error userInfo] objectForKey:@"error_message"] forKey:@"error_msg"];
                      }
                      [data setObject:err forKey:@"res"];

                      break;
                  }
                  default:
                      break;
              }
              
              NSString *dataStr = [MOBFJson jsonStringFromObject:data];
              
              FREDispatchStatusEventAsync(ctx,
                                          (uint8_t *)[code cStringUsingEncoding:NSUTF8StringEncoding],
                                          (uint8_t *)[dataStr cStringUsingEncoding:NSUTF8StringEncoding]);
              
          }];
    
}


FREObject ShareSDKUnsupportMethod (FREContext ctx, void* functionData, uint32_t argc, FREObject  argv[])
{
    return NULL;
}

FREObject ShareSDKCallMethod (FREContext ctx, void* functionData, uint32_t argc, FREObject  argv[])
{
    if (argc >= 1)
    {
        NSString *str = objectToString(argv[0]);
        NSDictionary *paramDict = [MOBFJson objectFromJSONString:str];
        NSString *action = nil;
        if ([paramDict objectForKey:@"action"])
        {
            action = [paramDict objectForKey:@"action"];
            
            if([action isEqualToString:@"setPlatformConfig"])
            {
                ShareSDKRegisterAppAndSetPlatformConfig([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"authorize"])
            {
                ShareSDKAuthorize (ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"isAuthorized"])
            {
                return ShareSDKHasAuthroized([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"cancelAuthorize"])
            {
                ShareSDKCancelAuthorize([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"getUserInfo"])
            {
                ShareSDKGetUserInfo(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"shareContent"])
            {
                ShareSDKShare(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"multishare"])
            {
                ShareSDKOneKeyShare(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"ShowPlatformList"])
            {
                ShareSDKShowShareMenu (ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"ShowShareContentEditor"])
            {
                ShareSDKShowShareView (ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"ShowPlatformListByContentName"])
            {
                ShareSDKShowShareMenuByContentName(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"ShowShareContentEditorByContentName"])
            {
                ShareSDKShowShareViewByContentName(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"toast"])
            {
                ShareSDKToast ([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"handleOpenURL"])
            {
                ShareSDKHandleOpenURL ([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"isClientValid"])
            {
                return ShareSDKCheckClient([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"getAuthInfo"])
            {
                return ShareSDKGetCredential([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"addFriend"])
            {
                 ShareSDKAddFriend(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"getFriendList"])
            {
                 ShareSDKGetFriendsList(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"ShareWithContentName"])
            {
                ShareSDKShareWithContentName(ctx, [paramDict objectForKey:@"params"]);
            }
        }
    }
    
    return NULL;
}

void ShareSDKContextInitializer (void*  extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet)
{
    *numFunctionsToSet = 1;
    
    FRENamedFunction *func = (FRENamedFunction *)malloc(sizeof(FRENamedFunction) * *numFunctionsToSet);
    
    func[0].name = (const uint8_t*)"ShareSDKUtils";
	func[0].functionData = NULL;
	func[0].function = &ShareSDKCallMethod;
    
    *functionsToSet = func;
}

void ShareSDKContextFinalizer (FREContext ctx)
{
}

/**
 *	@brief	初始化ShareSDK方法
 *
 *	@param 	extDataToSet 	扩展数据设置
 *	@param 	ctxInitializerToSet 	初始化函数
 *	@param 	ctxFinalizerToSet 	析构函数
 */
void ShareSDKInitializer (void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ShareSDKContextInitializer;
    *ctxFinalizerToSet = &ShareSDKContextFinalizer;
}

/**
 *	@brief  终止化ShareSDK方法
 *
 *	@param 	extData 	扩展数据
 */
void ShareSDKFinalizer (void* extData)
{
    
}
