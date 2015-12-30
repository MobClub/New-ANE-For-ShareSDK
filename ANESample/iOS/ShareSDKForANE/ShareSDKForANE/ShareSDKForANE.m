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
#import <ShareSDK/SSDKFriendsPaging.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <MOBFoundation/MOBFRegex.h>
#import <MOBFoundation/MOBFJson.h>
#import <MOBFoundation/MOBFDevice.h>
#import "ShareSDKWindow.h"

#define __SHARESDK_SINA_WEIBO__
#define __SHARESDK_WECHAT__
#define __SHARESDK_QQ__
#define __SHARESDK_APSOCIAL__
//#define __SHARESDK_RENREN__
//#define __SHARESDK_YIXIN__

//#define __SHARESDK_GOOGLE_PLUS__       //目前发现Google+ SDK 不能顺利在ANE环境下编译
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

#ifdef __SHARESDK_GOOGLE_PLUS__
#import <GooglePlus/GooglePlus.h>
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
    SSDKImage *thumbImage = nil;
    SSDKImage *image = nil;
    NSString *musicFileUrl = nil;
    NSString *extInfo = nil;
    NSData *fileData = nil;
    NSData *emotionData = nil;
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
    if ([[wechatDic objectForKey:@"thumbImage"] isKindOfClass:[NSString class]])
    {
        NSString *imagePath = [wechatDic objectForKey:@"thumbImage"];
        if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                options:MOBFRegexOptionsNoOptions
                                inRange:NSMakeRange(0, 10)
                             withString:imagePath])
        {
            thumbImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        }
        else
        {
            UIImage *localImage = [[UIImage alloc]initWithContentsOfFile:imagePath];
            thumbImage = [[SSDKImage alloc]initWithImage:localImage
                                                        format:SSDKImageFormatJpeg
                                                      settings:nil];
        }
    }
    if ([[wechatDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
    {
        NSString *imagePath = [wechatDic objectForKey:@"imageUrl"];
        if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                options:MOBFRegexOptionsNoOptions
                                inRange:NSMakeRange(0, 10)
                             withString:imagePath])
        {
            image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        }
        else
        {
            UIImage *localImage = [[UIImage alloc]initWithContentsOfFile:imagePath];
            image = [[SSDKImage alloc]initWithImage:localImage
                                                   format:SSDKImageFormatJpeg
                                                 settings:nil];
        }
        
    }
    if ([[wechatDic objectForKey:@"musicFileUrl"] isKindOfClass:[NSString class]])
    {
        musicFileUrl = [wechatDic objectForKey:@"musicFileUrl"];
    }
    if ([[wechatDic objectForKey:@"extInfo"] isKindOfClass:[NSString class]])
    {
        extInfo = [wechatDic objectForKey:@"extInfo"];
        
    }
    if ([[wechatDic objectForKey:@"fileDataPath"] isKindOfClass:[NSString class]])
    {
        NSString *fileDataPath = [wechatDic objectForKey:@"fileDataPath"];
        fileData = [NSData dataWithContentsOfFile:fileDataPath];
    }
    if ([[wechatDic objectForKey:@"emotionDataPath"] isKindOfClass:[NSString class]])
    {
        NSString *emotionDataPath = [wechatDic objectForKey:@"emotionDataPath"];
        emotionData = [NSData dataWithContentsOfFile:emotionDataPath];
    }
    if ([[wechatDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
    {
        type = [[wechatDic objectForKey:@"type"] integerValue];
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
    SSDKImage *thumbImage = nil;
    SSDKImage *image = nil;
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
    if ([[qqDic objectForKey:@"thumbImage"] isKindOfClass:[NSString class]])
    {
        NSString *imagePath = [qqDic objectForKey:@"thumbImage"];
        if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                options:MOBFRegexOptionsNoOptions
                                inRange:NSMakeRange(0, 10)
                             withString:imagePath])
        {
            thumbImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        }
        else
        {
            UIImage *localImage = [[UIImage alloc]initWithContentsOfFile:imagePath];
            thumbImage = [[SSDKImage alloc]initWithImage:localImage
                                                    format:SSDKImageFormatJpeg
                                                  settings:nil];
        }
    }
    if ([[qqDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
    {
        NSString *imagePath = [qqDic objectForKey:@"imageUrl"];
        if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                options:MOBFRegexOptionsNoOptions
                                inRange:NSMakeRange(0, 10)
                             withString:imagePath])
        {
            image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        }
        else
        {
            UIImage *localImage = [[UIImage alloc]initWithContentsOfFile:imagePath];
            image = [[SSDKImage alloc]initWithImage:localImage
                                               format:SSDKImageFormatJpeg
                                             settings:nil];
        }
        
    }
    if ([[qqDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
    {
        type = [[qqDic objectForKey:@"type"] integerValue];
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
    SSDKImage *thumbImage = nil;
    SSDKImage *image = nil;
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
    if ([[yiXinDic objectForKey:@"thumbImage"] isKindOfClass:[NSString class]])
    {
        NSString *imagePath = [yiXinDic objectForKey:@"thumbImage"];
        if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                options:MOBFRegexOptionsNoOptions
                                inRange:NSMakeRange(0, 10)
                             withString:imagePath])
        {
            thumbImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        }
        else
        {
            UIImage *localImage = [[UIImage alloc]initWithContentsOfFile:imagePath];
            thumbImage = [[SSDKImage alloc]initWithImage:localImage
                                                  format:SSDKImageFormatJpeg
                                                settings:nil];
        }
    }
    if ([[yiXinDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
    {
        NSString *imagePath = [yiXinDic objectForKey:@"imageUrl"];
        if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                options:MOBFRegexOptionsNoOptions
                                inRange:NSMakeRange(0, 10)
                             withString:imagePath])
        {
            image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
        }
        else
        {
            UIImage *localImage = [[UIImage alloc]initWithContentsOfFile:imagePath];
            image = [[SSDKImage alloc]initWithImage:localImage
                                             format:SSDKImageFormatJpeg
                                           settings:nil];
        }
        
    }
    if ([[yiXinDic objectForKey:@"musicFileURL"] isKindOfClass:[NSString class]])
    {
        musicFileURL = [yiXinDic objectForKey:@"musicFileURL"];
    }
    if ([[yiXinDic objectForKey:@"extInfo"] isKindOfClass:[NSString class]])
    {
        extInfo = [yiXinDic objectForKey:@"extInfo"];
    }
    if ([[yiXinDic objectForKey:@"fileDataPath"] isKindOfClass:[NSString class]])
    {
        fileDataPath = [yiXinDic objectForKey:@"fileDataPath"];
    }
    if ([[yiXinDic objectForKey:@"comment"] isKindOfClass:[NSString class]])
    {
        comment = [yiXinDic objectForKey:@"comment"];
    }
    if ([[yiXinDic objectForKey:@"toUserId"] isKindOfClass:[NSString class]])
    {
        toUserId = [yiXinDic objectForKey:@"toUserId"];
    }
    if ([[yiXinDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
    {
        type = [[yiXinDic objectForKey:@"type"] integerValue];
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



NSMutableDictionary *converPublicContent (NSDictionary *contentDict)
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *text = nil;
    SSDKImage *image = nil;
    NSString *url = nil;
    NSString *title = nil;
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
            
            if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                    options:MOBFRegexOptionsNoOptions
                                    inRange:NSMakeRange(0, 10)
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
        
        if ([[contentDict objectForKey:@"url"] isKindOfClass:[NSString class]])
        {
            url = [contentDict objectForKey:@"url"];
        }
        if ([[contentDict objectForKey:@"title"] isKindOfClass:[NSString class]])
        {
            title = [contentDict objectForKey:@"title"];
        }
        if ([[contentDict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
        {
            type = (SSDKContentType)[[contentDict objectForKey:@"type"] integerValue];
        }
        
    }
    
    [params SSDKSetupShareParamsByText:text
                                images:image
                                   url:[NSURL URLWithString:url]
                                 title:title
                                  type:type];
    
    
    if (contentDict)
    {
        //新浪
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSinaWeibo]])
        {
            NSDictionary *sinaDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSinaWeibo]];
            NSString *text = nil;
            NSString *title = nil;
            SSDKImage *image = nil;
            NSString *url = nil;
            double latitude;
            double longitude;
            NSString *objId = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[sinaDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [sinaDic objectForKey:@"text"];
            }
            if ([[sinaDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [sinaDic objectForKey:@"title"];
            }
            if ([[sinaDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                
                NSString *imagePath = [sinaDic objectForKey:@"imageUrl"];
                
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[sinaDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [sinaDic objectForKey:@"url"];
            }
            if ([[sinaDic objectForKey:@"latitude"] isKindOfClass:[NSString class]])
            {
                latitude = [[sinaDic objectForKey:@"latitude"] doubleValue];
            }
            if ([[sinaDic objectForKey:@"longitude"] isKindOfClass:[NSString class]])
            {
                longitude = [[sinaDic objectForKey:@"longitude"] doubleValue];
            }
            if ([[sinaDic objectForKey:@"objectID"] isKindOfClass:[NSString class]])
            {
                objId = [sinaDic objectForKey:@"objectID"];
            }
            if ([[sinaDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                type = [[sinaDic objectForKey:@"type"] integerValue];
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
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTencentWeibo]])
        {
            NSDictionary *tencentDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTencentWeibo]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            double latitude;
            double longitude;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[tencentDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [tencentDic objectForKey:@"text"];
            }
            if ([[tencentDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                SSDKImage *tencentImage = nil;
                NSString *imagePath = [tencentDic objectForKey:@"imageUrl"];
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    tencentImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                     format:SSDKImageFormatJpeg
                                                   settings:nil];
                }
                [images addObject:tencentImage];
                
            }
            else if([[tencentDic objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [tencentDic objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    
                    SSDKImage *tencentImage = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
                                         withString:imagePath])
                    {
                        tencentImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        tencentImage = [[SSDKImage alloc]initWithImage:localImage
                                                                format:SSDKImageFormatJpeg
                                                              settings:nil];
                    }

                    [images addObject:tencentImage];
       
                }
            }
            if ([[tencentDic objectForKey:@"latitude"] isKindOfClass:[NSString class]])
            {
                latitude = [[tencentDic objectForKey:@"latitude"] doubleValue];
            }
            if ([[tencentDic objectForKey:@"longitude"] isKindOfClass:[NSString class]])
            {
                longitude = [[tencentDic objectForKey:@"longitude"] doubleValue];
            }
            if ([[tencentDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                type = [[tencentDic objectForKey:@"type"] integerValue];
            }
            
            [params SSDKSetupTencentWeiboShareParamsByText:text
                                                    images:images
                                                  latitude:latitude
                                                 longitude:longitude
                                                      type:type];
        }
        
        //豆瓣
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDouBan]])
        {
            NSDictionary *doubanDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDouBan]];
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *title = nil;
            NSString *url = nil;
            NSString *urlDesc = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            if ([[doubanDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [doubanDic objectForKey:@"text"];
            }
            if ([[doubanDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [doubanDic objectForKey:@"imageUrl"];
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[doubanDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                text = [doubanDic objectForKey:@"title"];
            }
            if ([[doubanDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [doubanDic objectForKey:@"url"];
            }
            if ([[doubanDic objectForKey:@"urlDesc"] isKindOfClass:[NSString class]])
            {
                urlDesc = [doubanDic objectForKey:@"urlDesc"];
            }
            if ([[doubanDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[doubanDic objectForKey:@"type"] integerValue];
            }
            [params SSDKSetupDouBanParamsByText:text
                                          image:image
                                          title:title
                                            url:[NSURL URLWithString:url]
                                        urlDesc:urlDesc
                                           type:contentType];
        }

        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatSession]])
        {
            NSDictionary *wechatDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatSession]];
            setWechatShareParmas(wechatDic, params, SSDKPlatformSubTypeWechatSession);
            
        }
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatTimeline]])
        {
            NSDictionary *wechatDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatTimeline]];
            setWechatShareParmas(wechatDic, params, SSDKPlatformSubTypeWechatTimeline);
        }
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatFav]])
        {
            NSDictionary *wechatDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeWechatFav]];
            setWechatShareParmas(wechatDic, params, SSDKPlatformSubTypeWechatFav);
        }
        
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQQFriend]])
        {
            NSDictionary *qqDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQQFriend]];
            setQQShareParmas(qqDic, params, SSDKPlatformSubTypeQQFriend);
        }
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQZone]])
        {
            NSDictionary *qqDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeQZone]];
            setQQShareParmas(qqDic, params, SSDKPlatformSubTypeQZone);
        }
        
        //人人
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeRenren]])
        {
            NSDictionary *renrenDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeRenren]];
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *url = nil;
            NSString *albumId = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            if ([[renrenDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [renrenDic objectForKey:@"text"];
            }
            if ([[renrenDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [renrenDic objectForKey:@"imageUrl"];
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[renrenDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [renrenDic objectForKey:@"url"];
            }
            if ([[renrenDic objectForKey:@"albumId"] isKindOfClass:[NSString class]])
            {
                albumId = [renrenDic objectForKey:@"albumId"];
            }
            if ([[renrenDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[renrenDic objectForKey:@"type"] integerValue];
            }
            [params SSDKSetupRenRenParamsByText:text
                                          image:image
                                            url:[NSURL URLWithString:url]
                                        albumId:albumId
                                           type:type];
        }
        
        //开心
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKaixin]])
        {
            NSDictionary *kaixinDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKaixin]];
            NSString *text = nil;
            SSDKImage *image = nil;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[kaixinDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [kaixinDic objectForKey:@"text"];
            }
            if ([[kaixinDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [kaixinDic objectForKey:@"imageUrl"];
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[kaixinDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                type = [[kaixinDic objectForKey:@"type"] integerValue];
            }
            [params SSDKSetupKaiXinParamsByText:text
                                          image:image
                                           type:type];
        }
        
        //Facebook
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFacebook]])
        {
            NSDictionary *facebookDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFacebook]];
            NSString *facebookText = nil;
            SSDKImage *facebookImage = nil;
            SSDKContentType facebookContentType = SSDKContentTypeText;
            
            if ([[facebookDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                facebookText = [facebookDic objectForKey:@"text"];
            }
            if ([[facebookDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [facebookDic objectForKey:@"imageUrl"];
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    facebookImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    facebookImage = [[SSDKImage alloc]initWithImage:localImage
                                                             format:SSDKImageFormatJpeg
                                                           settings:nil];
                }
            }
            if ([[facebookDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                facebookContentType = [[facebookDic objectForKey:@"type"] integerValue];
            }
            [params SSDKSetupFacebookParamsByText:facebookText
                                            image:facebookImage
                                             type:facebookContentType];
        }
        
        //Twitter
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTwitter]])
        {
            NSDictionary *twitterDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTwitter]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            double latitude;
            double longitude;
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[twitterDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [twitterDic objectForKey:@"text"];
            }
            if ([[twitterDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [twitterDic objectForKey:@"imageUrl"];
                SSDKImage *twitterImage = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    twitterImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    twitterImage = [[SSDKImage alloc]initWithImage:localImage
                                                            format:SSDKImageFormatJpeg
                                                          settings:nil];
                }
                [images addObject:twitterImage];
            }
            else if ([[twitterDic objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [twitterDic objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *twitterImage = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
                                         withString:imagePath])
                    {
                        twitterImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        twitterImage = [[SSDKImage alloc]initWithImage:localImage
                                                                format:SSDKImageFormatJpeg
                                                              settings:nil];
                    }
                    [images addObject:twitterImage];
                }
            }
            
            if ([[twitterDic objectForKey:@"latitude"] isKindOfClass:[NSString class]])
            {
                latitude = [[twitterDic objectForKey:@"latitude"] doubleValue];
            }
            if ([[twitterDic objectForKey:@"longitude"] isKindOfClass:[NSString class]])
            {
                longitude = [[twitterDic objectForKey:@"longitude"] doubleValue];
            }
            if ([[twitterDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                type = [[twitterDic objectForKey:@"type"] integerValue];
            }
            
            [params SSDKSetupTwitterParamsByText:text
                                          images:images
                                        latitude:latitude
                                       longitude:longitude
                                            type:type];
        }

        //印象笔记
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYinXiang]])
        {
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *title = nil;
            NSString *notebook = nil;
            NSMutableArray *tags = [NSMutableArray array];
            NSDictionary *yinXiangDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYinXiang]];
            
            if ([[yinXiangDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [yinXiangDict objectForKey:@"text"];
            }
            if ([[yinXiangDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [yinXiangDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
                [images addObject:image];
            }
            else if ([[yinXiangDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [yinXiangDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
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
                    [images addObject:image];
                }
            }
            if ([[yinXiangDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [yinXiangDict objectForKey:@"title"];
            }
            if ([[yinXiangDict objectForKey:@"notebook"] isKindOfClass:[NSString class]])
            {
                notebook = [yinXiangDict objectForKey:@"notebook"];
            }
            if ([[yinXiangDict objectForKey:@"tags"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [yinXiangDict objectForKey:@"tags"];
                [tags addObject:ricipient];
            }
            else if([[yinXiangDict objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [yinXiangDict objectForKey:@"tags"];
                tags = [recipientsArr mutableCopy];
            }
            
            [params SSDKSetupEvernoteParamsByText:text
                                           images:images
                                            title:title
                                         notebook:notebook
                                             tags:tags
                                     platformType:SSDKPlatformTypeYinXiang];
        }
        
        //evernote
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeEvernote]])
        {
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *title = nil;
            NSString *notebook = nil;
            NSMutableArray *tags = [NSMutableArray array];
            NSDictionary *yinXiangDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeEvernote]];
            
            if ([[yinXiangDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [yinXiangDict objectForKey:@"text"];
            }
            if ([[yinXiangDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [yinXiangDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
                [images addObject:image];
            }
            else if ([[yinXiangDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [yinXiangDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
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
                    [images addObject:image];
                }
            }
            if ([[yinXiangDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [yinXiangDict objectForKey:@"title"];
            }
            if ([[yinXiangDict objectForKey:@"notebook"] isKindOfClass:[NSString class]])
            {
                notebook = [yinXiangDict objectForKey:@"notebook"];
            }
            if ([[yinXiangDict objectForKey:@"tags"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [yinXiangDict objectForKey:@"tags"];
                [tags addObject:ricipient];
            }
            else if([[yinXiangDict objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [yinXiangDict objectForKey:@"tags"];
                tags = [recipientsArr mutableCopy];
            }
            
            [params SSDKSetupEvernoteParamsByText:text
                                           images:images
                                            title:title
                                         notebook:notebook
                                             tags:tags
                                     platformType:SSDKPlatformTypeEvernote];
        }
        
        
        //Google+
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeGooglePlus]])
        {
            NSDictionary *googlePlusDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeGooglePlus]];
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *url = nil;
            NSString *urlDesc = nil;
            NSString *deepLindId = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            
            if ([[googlePlusDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [googlePlusDic objectForKey:@"text"];
            }
            if ([[googlePlusDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [googlePlusDic objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[googlePlusDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [googlePlusDic objectForKey:@"url"];
            }
            if ([[googlePlusDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [googlePlusDic objectForKey:@"title"];
            }
            if ([[googlePlusDic objectForKey:@"urlDesc"] isKindOfClass:[NSString class]])
            {
                urlDesc = [googlePlusDic objectForKey:@"urlDesc"];
            }
            if ([[googlePlusDic objectForKey:@"deepLinkId"] isKindOfClass:[NSString class]])
            {
                deepLindId = [googlePlusDic objectForKey:@"deepLinkId"];
            }
            if ([[googlePlusDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[googlePlusDic objectForKey:@"type"] integerValue];
                
            }
            [params SSDKSetupGooglePlusParamsByText:text
                                              image:image
                                                url:[NSURL URLWithString:url]
                                              title:title
                                            urlDesc:urlDesc
                                         deepLinkId:deepLindId
                                               type:contentType];

        }
        
        //instagram
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeInstagram]])
        {
            NSDictionary *instagramDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeInstagram]];
            SSDKImage *image = nil;
            CGFloat menuX;
            CGFloat menuY;
            if ([[instagramDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [instagramDic objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[instagramDic objectForKey:@"menuX"] isKindOfClass:[NSNumber class]])
            {
                menuX = [[instagramDic objectForKey:@"menuX"] floatValue];
            }
            if ([[instagramDic objectForKey:@"menuY"] isKindOfClass:[NSNumber class]])
            {
                menuY = [[instagramDic objectForKey:@"menuY"] floatValue];
            }
            
            [params SSDKSetupInstagramByImage:image menuDisplayPoint:CGPointMake(menuX, menuY)];
        }
        
        //LinkedIn
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLinkedIn]])
        {
            NSDictionary *linkInDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLinkedIn]];
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *url = nil;
            NSString *title = nil;
            NSString *urlDesc = nil;
            NSString *visibility = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            
            if ([[linkInDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [linkInDic objectForKey:@"text"];
            }
            if ([[linkInDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [linkInDic objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[linkInDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [linkInDic objectForKey:@"url"];
            }
            if ([[linkInDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [linkInDic objectForKey:@"title"];
            }
            if ([[linkInDic objectForKey:@"urlDesc"] isKindOfClass:[NSString class]])
            {
                urlDesc = [linkInDic objectForKey:@"urlDesc"];
            }
            if ([[linkInDic objectForKey:@"visibility"] isKindOfClass:[NSString class]])
            {
                visibility = [linkInDic objectForKey:@"visibility"];
            }
            if ([[linkInDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[linkInDic objectForKey:@"type"] integerValue];
                
            }
            [params SSDKSetupLinkedInParamsByText:text
                                            image:image
                                              url:[NSURL URLWithString:url]
                                            title:title
                                          urlDesc:urlDesc
                                       visibility:visibility
                                             type:contentType];
        }
        
        //Tumblr
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTumblr]])
        {
            NSDictionary *tumblrDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeTumblr]];
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *url = nil;
            NSString *title = nil;
            NSString *blogName = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            if ([[tumblrDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                tumblrDic = [contentDict objectForKey:@"text"];
            }
            if ([[tumblrDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [tumblrDic objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[tumblrDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [tumblrDic objectForKey:@"url"];
            }
            if ([[tumblrDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [tumblrDic objectForKey:@"title"];
            }
            if ([[tumblrDic objectForKey:@"urlDesc"] isKindOfClass:[NSString class]])
            {
                blogName = [tumblrDic objectForKey:@"urlDesc"];
            }
            [params SSDKSetupTumblrParamsByText:text
                                          image:image
                                            url:[NSURL URLWithString:url]
                                          title:title
                                       blogName:blogName
                                           type:contentType];
        }
        
        //Mail
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMail]])
        {
            NSDictionary *mailDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMail]];
            NSString *text = nil;
            NSString *title = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSMutableArray *attachments = [NSMutableArray array];
            NSMutableArray *recipients = [NSMutableArray array];
            NSMutableArray *ccRecipients = [NSMutableArray array];
            NSMutableArray *bccRecipients = [NSMutableArray array];
            SSDKContentType type = SSDKContentTypeText;
            
            if ([[mailDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [mailDic objectForKey:@"text"];
            }
            if ([[mailDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [mailDic objectForKey:@"title"];
            }
            if ([[mailDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [mailDic objectForKey:@"imageUrl"];
                SSDKImage *mailImage = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    mailImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    [images addObject:mailImage];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    mailImage = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                    [images addObject:mailImage];
                }
                
            }
            else if([[mailDic objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [mailDic objectForKey:@"imageUrl"];
                
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *mailImage = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
                                         withString:imagePath])
                    {
                        mailImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                        [images addObject:mailImage];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        mailImage = [[SSDKImage alloc]initWithImage:localImage
                                                             format:SSDKImageFormatJpeg
                                                           settings:nil];
                        [images addObject:mailImage];
                    }
                }
            }
            if ([[mailDic objectForKey:@"attachmentsPaths"] isKindOfClass:[NSString class]])
            {
                NSData *attachmentsData = [NSData dataWithContentsOfFile:[mailDic objectForKey:@"attachmentsPaths"]];
                [attachments addObject:attachmentsData];
            }
            else if ([[mailDic objectForKey:@"attachmentsPaths"] isKindOfClass:[NSArray class]])
            {
                NSArray *attachmentsPaths = [mailDic objectForKey:@"attachmentsPaths"];
                for (NSString *path in attachmentsPaths)
                {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    [attachments addObject:data];
                }
            }
            if ([[mailDic objectForKey:@"recipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [mailDic objectForKey:@"recipients"];
                [recipients addObject:ricipient];
            }
            else if([[mailDic objectForKey:@"recipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [mailDic objectForKey:@"recipients"];
                recipients = [recipientsArr mutableCopy];
            }
            
            if ([[mailDic objectForKey:@"ccRecipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [mailDic objectForKey:@"ccRecipients"];
                [ccRecipients addObject:ricipient];
            }
            else if([[mailDic objectForKey:@"ccRecipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [mailDic objectForKey:@"ccRecipients"];
                ccRecipients = [recipientsArr mutableCopy];
            }
            
            if ([[mailDic objectForKey:@"bccRecipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [mailDic objectForKey:@"bccRecipients"];
                [bccRecipients addObject:ricipient];
            }
            else if([[mailDic objectForKey:@"bccRecipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [mailDic objectForKey:@"bccRecipients"];
                bccRecipients = [recipientsArr mutableCopy];
            }
            
            if ([[mailDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                type = [[mailDic objectForKey:@"type"] integerValue];
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
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSMS]])
        {
            NSDictionary *SMSDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeSMS]];
            NSString *text = nil;
            NSString *title = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSMutableArray *attachments = [NSMutableArray array];
            NSMutableArray *recipients = [NSMutableArray array];
            SSDKContentType contentType = SSDKContentTypeText;
            
            if ([[SMSDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [SMSDic objectForKey:@"text"];
            }
            if ([[SMSDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [SMSDic objectForKey:@"title"];
            }
            if ([[SMSDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [SMSDic objectForKey:@"imageUrl"];
                SSDKImage *SMSImage = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    SMSImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    SMSImage = [[SSDKImage alloc]initWithImage:localImage
                                                        format:SSDKImageFormatJpeg
                                                      settings:nil];
                }
                [images addObject:SMSImage];
            }
            else if ([[SMSDic objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [SMSDic objectForKey:@"imageUrl"];
                
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *SMSImage = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
                                         withString:imagePath])
                    {
                        SMSImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        SMSImage = [[SSDKImage alloc]initWithImage:localImage
                                                            format:SSDKImageFormatJpeg
                                                          settings:nil];
                    }
                    [images addObject:SMSImage];
                }
            }
            if ([[SMSDic objectForKey:@"attachmentsPaths"] isKindOfClass:[NSString class]])
            {
                NSData *attachmentsData = [NSData dataWithContentsOfFile:[SMSDic objectForKey:@"attachmentsPaths"]];
                [attachments addObject:attachmentsData];
            }
            else if ([[SMSDic objectForKey:@"attachmentsPaths"] isKindOfClass:[NSArray class]])
            {
                NSArray *attachmentsPaths = [SMSDic objectForKey:@"attachmentsPaths"];
                for (NSString *path in attachmentsPaths)
                {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    [attachments addObject:data];
                }
            }
            
            if ([[SMSDic objectForKey:@"recipients"] isKindOfClass:[NSString class]])
            {
                NSString *ricipient = [SMSDic objectForKey:@"recipients"];
                [recipients addObject:ricipient];
            }
            else if([[SMSDic objectForKey:@"recipients"] isKindOfClass:[NSArray class]])
            {
                NSArray *recipientsArr = [SMSDic objectForKey:@"recipients"];
                recipients = [recipientsArr mutableCopy];
            }
            if ([[SMSDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[SMSDic objectForKey:@"type"] integerValue];
            }
            
            [params SSDKSetupSMSParamsByText:text
                                       title:title
                                      images:images
                                 attachments:attachments
                                  recipients:recipients
                                        type:contentType];
        }
        
        
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeCopy]])
        {
            NSDictionary *copyDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeCopy]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *url = nil;
            SSDKContentType type = SSDKContentTypeText;
            if ([[copyDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [copyDic objectForKey:@"text"];
            }
            if ([[copyDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [copyDic objectForKey:@"imageUrl"];
                SSDKImage *copyImage = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    copyImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    [images addObject:copyImage];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    copyImage = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                    [images addObject:copyImage];
                }
            }
            else if([[copyDic objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [copyDic objectForKey:@"imageUrl"];
                
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *copyImage = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
                                         withString:imagePath])
                    {
                        copyImage = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                        [images addObject:copyImage];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        copyImage = [[SSDKImage alloc]initWithImage:localImage
                                                             format:SSDKImageFormatJpeg
                                                           settings:nil];
                        [images addObject:copyImage];
                    }
                }
            }

            if ([[copyDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [copyDic objectForKey:@"url"];
            }
            if ([[copyDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                type = [[copyDic objectForKey:@"type"] integerValue];
            }
            [params SSDKSetupCopyParamsByText:text
                                       images:images
                                          url:[NSURL URLWithString:url]
                                         type:type];
        }
        
        //Instapaper
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeInstapaper]])
        {
            NSString *url = nil;
            NSString *title = nil;
            NSString *desc = nil;
            NSString *content = nil;
            NSInteger folderId;
            BOOL isPrivateFromSource;
            BOOL resolveFinalUrl;
            NSDictionary *instapaperDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeCopy]];

            
            if ([[instapaperDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [instapaperDict objectForKey:@"url"];
            }
            if ([[instapaperDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [instapaperDict objectForKey:@"title"];
            }
            if ([[instapaperDict objectForKey:@"desc"] isKindOfClass:[NSString class]])
            {
                desc = [instapaperDict objectForKey:@"desc"];
            }
            if ([[instapaperDict objectForKey:@"content"] isKindOfClass:[NSString class]])
            {
                content = [instapaperDict objectForKey:@"content"];
            }
            if ([[instapaperDict objectForKey:@"folderId"] isKindOfClass:[NSNumber class]])
            {
                folderId = [[instapaperDict objectForKey:@"folderId"] integerValue];
            }
            if ([[instapaperDict objectForKey:@"isPrivateFromSource"] isKindOfClass:[NSNumber class]])
            {
                isPrivateFromSource = [[instapaperDict objectForKey:@"isPrivateFromSource"] boolValue];
            }
            if ([[instapaperDict objectForKey:@"resolveFinalUrl"] isKindOfClass:[NSNumber class]])
            {
                resolveFinalUrl = [[instapaperDict objectForKey:@"resolveFinalUrl"] boolValue];
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
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePocket]])
        {
            NSDictionary *pocketDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePocket]];
            NSString *url = nil;
            NSString *title = nil;
            NSMutableArray *tags = [NSMutableArray array];
            NSString *tweetId = nil;
            
            if ([[pocketDic objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [pocketDic objectForKey:@"url"];
            }
            if ([[pocketDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [pocketDic objectForKey:@"title"];
            }
            if ([[pocketDic objectForKey:@"tags"] isKindOfClass:[NSString class]])
            {
                if ([pocketDic objectForKey:@"tags"] != nil)
                {
                    [tags addObject:[pocketDic objectForKey:@"tags"]];
                }
            }
            else if ([[pocketDic objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                tags = [[pocketDic objectForKey:@"tags"] mutableCopy];
            }
            if ([[pocketDic objectForKey:@"tweetId"] isKindOfClass:[NSString class]])
            {
                tweetId = [pocketDic objectForKey:@"tweetId"];
            }
            [params SSDKSetupPocketParamsByUrl:[NSURL URLWithString:url]
                                         title:title
                                          tags:tags
                                       tweetId:tweetId];
        }
        
        //youdao
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYouDaoNote]])
        {
            NSDictionary *youDaoDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYouDaoNote]];
            NSString *text = nil;
            NSMutableArray *images = [NSMutableArray array];
            NSString *title = nil;
            NSString *source = nil;
            NSString *author = nil;
            NSString *notebook = nil;
            if ([[youDaoDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [youDaoDic objectForKey:@"text"];
            }
            if ([[youDaoDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [youDaoDic objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    [images addObject:image];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                    [images addObject:image];
                }
                
            }
            else if([[youDaoDic objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [youDaoDic objectForKey:@"imageUrl"];
                
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                        [images addObject:image];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                             format:SSDKImageFormatJpeg
                                                           settings:nil];
                        [images addObject:image];
                    }
                }
            }
            if ([[youDaoDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [youDaoDic objectForKey:@"title"];
            }
            if ([[youDaoDic objectForKey:@"source"] isKindOfClass:[NSString class]])
            {
                source  = [youDaoDic objectForKey:@"source"];
            }
            if ([[youDaoDic objectForKey:@"author"] isKindOfClass:[NSString class]])
            {
                author = [youDaoDic objectForKey:@"author"];
            }
            if ([[youDaoDic objectForKey:@"notebook"] isKindOfClass:[NSString class]])
            {
                notebook = [youDaoDic objectForKey:@"notebook"];
            }
            [params SSDKSetupYouDaoNoteParamsByText:text
                                             images:images
                                              title:title
                                             source:source
                                             author:author
                                           notebook:notebook];
        }
        
        //Pinterest
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePinterest]])
        {
            NSString *decs = nil;
            NSString *url = nil;
            NSString *boardId = nil;
            SSDKImage *image = nil;
            
            NSDictionary *pinterestDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypePinterest]];
            
            if ([[pinterestDict objectForKey:@"decs"] isKindOfClass:[NSString class]])
            {
                decs = [pinterestDict objectForKey:@"decs"];
            }
            if ([[pinterestDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [pinterestDict objectForKey:@"url"];
            }
            if ([[pinterestDict objectForKey:@"boardId"] isKindOfClass:[NSString class]])
            {
                boardId = [pinterestDict objectForKey:@"boardId"];
            }
            if ([[pinterestDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [pinterestDict objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            [params SSDKSetupPinterestParamsByImage:image
                                               desc:decs
                                                url:[NSURL URLWithString:url]
                                            boardId:boardId];
        }
        
        //Flickr
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFlickr]])
        {
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *title = nil;
            NSArray *tags = [NSArray array];
            BOOL isPublic;
            BOOL isFriend;
            BOOL isFamily;
            NSInteger safetyLevel;
            NSInteger hidden;
            SSDKContentType contentType = SSDKContentTypeText;
            
            NSDictionary *flickrDic = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeFlickr]];
            
            if ([[flickrDic objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [flickrDic objectForKey:@"text"];
            }
            if ([[flickrDic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [flickrDic objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[flickrDic objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [flickrDic objectForKey:@"title"];
            }
            if ([[flickrDic objectForKey:@"tags"] isKindOfClass:[NSArray class]])
            {
                tags = [[flickrDic objectForKey:@"tages"] copy];
            }
            if ([[flickrDic objectForKey:@"isPublic"] isKindOfClass:[NSNumber class]])
            {
                isPublic = [[flickrDic objectForKey:@"isPublic"] boolValue];
            }
            if ([[flickrDic objectForKey:@"isFriend"] isKindOfClass:[NSNumber class]])
            {
                isFriend = [[flickrDic objectForKey:@"isFriend"] boolValue];
            }
            if ([[flickrDic objectForKey:@"isFamily"] isKindOfClass:[NSNumber class]])
            {
                isFamily = [[flickrDic objectForKey:@"isFamily"] boolValue];
            }
            if ([[flickrDic objectForKey:@"safetyLevel"] isKindOfClass:[NSNumber class]])
            {
                safetyLevel = [[flickrDic objectForKey:@"safetyLevel"] integerValue];
            }
            if ([[flickrDic objectForKey:@"hidden"] isKindOfClass:[NSNumber class]])
            {
                hidden = [[flickrDic objectForKey:@"hidden"] integerValue];
            }
            if ([[flickrDic objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[flickrDic objectForKey:@"type"] integerValue];
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
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDropbox]])
        {
            NSString *attachmentPath = nil;
            NSDictionary *dropBoxDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeDropbox]];
            
            if ([[dropBoxDict objectForKey:@"attachmentPath"] isKindOfClass:[NSString class]])
            {
                attachmentPath = [dropBoxDict objectForKey:@"attachmentPath"];
            }
            [params SSDKSetupDropboxParamsByAttachment:attachmentPath];
        }

        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeVKontakte]])
        {
       
           NSString *text = nil;
           NSMutableArray *images = [NSMutableArray array];
           NSString *url = nil;
           NSString *groupId = nil;
           BOOL friendsOnly;
           double latitude;
           double longitude;
           SSDKContentType contentType = SSDKContentTypeText;
           NSDictionary *vkDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeVKontakte]];
           
           
           if ([[vkDict objectForKey:@"text"] isKindOfClass:[NSString class]])
           {
               text = [vkDict objectForKey:@"text"];
           }
           if ([[vkDict objectForKey:@"url"] isKindOfClass:[NSString class]])
           {
               url = [vkDict objectForKey:@"url"];
           }
           
           if ([[vkDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
           {
               NSString *imagePath = [vkDict objectForKey:@"imageUrl"];
               SSDKImage *image = nil;
               if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                       options:MOBFRegexOptionsNoOptions
                                       inRange:NSMakeRange(0, 10)
                                    withString:imagePath])
               {
                   image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                   [images addObject:image];
               }
               else
               {
                   UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                   image = [[SSDKImage alloc]initWithImage:localImage
                                                    format:SSDKImageFormatJpeg
                                                  settings:nil];
                   [images addObject:image];
               }
               
           }
           else if([[vkDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
           {
               NSArray *imagePaths = [vkDict objectForKey:@"imageUrl"];
               
               for (NSString *imagePath in imagePaths)
               {
                   SSDKImage *image = nil;
                   if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                           options:MOBFRegexOptionsNoOptions
                                           inRange:NSMakeRange(0, 10)
                                        withString:imagePath])
                   {
                       image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                       [images addObject:image];
                   }
                   else
                   {
                       UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                       image = [[SSDKImage alloc]initWithImage:localImage
                                                        format:SSDKImageFormatJpeg
                                                      settings:nil];
                       [images addObject:image];
                   }
               }
           }
           if ([[vkDict objectForKey:@"groupId"] isKindOfClass:[NSString class]])
           {
               groupId = [vkDict objectForKey:@"groupId"];
           }
           if ([[vkDict objectForKey:@"friendsOnly"] isKindOfClass:[NSNumber class]])
           {
               friendsOnly = [[vkDict objectForKey:@"friendsOnly"] boolValue];
           }
           if ([[vkDict objectForKey:@"latitude"] isKindOfClass:[NSString class]])
           {
               latitude = [[vkDict objectForKey:@"latitude"] doubleValue];
           }
           if ([[vkDict objectForKey:@"longitude"] isKindOfClass:[NSString class]])
           {
               longitude = [[vkDict objectForKey:@"longitude"] doubleValue];
           }
           if ([[vkDict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
           {
               contentType = [[vkDict objectForKey:@"type"] integerValue];
           }
           
           [params SSDKSetupVKontakteParamsByText:text
                                           images:images
                                              url:[NSURL URLWithString:url]
                                          groupId:groupId
                                      friendsOnly:friendsOnly
                                         latitude:latitude
                                        longitude:longitude
                                             type:contentType];
        }
        
        //易信系列
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYiXin]])
        {
            NSDictionary *yiXinDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeYiXin]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformTypeYiXin);
        }
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinSession]])
        {
            NSDictionary *yiXinDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinSession]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformSubTypeYiXinSession);
        }
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinTimeline]])
        {
            NSDictionary *yiXinDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinTimeline]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformSubTypeYiXinTimeline);
        }
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinFav]])
        {
            NSDictionary *yiXinDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformSubTypeYiXinFav]];
            
            setYiXinShareParmas(yiXinDict, params, SSDKPlatformSubTypeYiXinFav);
        }
 
        //Mingdao
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMingDao]])
        {
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *url = nil;
            NSString *title = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            
            NSDictionary *mingDaoDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeMingDao]];
            
            
            if ([[mingDaoDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [mingDaoDict objectForKey:@"text"];
            }
            if ([[mingDaoDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [mingDaoDict objectForKey:@"url"];
            }
            if ([[mingDaoDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [mingDaoDict objectForKey:@"title"];
            }
            if ([[mingDaoDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [mingDaoDict objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[mingDaoDict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[mingDaoDict objectForKey:@"type"] integerValue];
            }
            
            [params SSDKSetupMingDaoParamsByText:text
                                           image:image
                                             url:[NSURL URLWithString:url]
                                           title:title
                                            type:contentType];
            
        }
        
        //Line
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLine]])
        {
            NSString *text = nil;
            SSDKImage *image = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            NSDictionary *lineDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeLine]];
            
            if ([[lineDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [lineDict objectForKey:@"text"];
            }
            if ([[lineDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [lineDict objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[lineDict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[lineDict objectForKey:@"type"] integerValue];
            }
            
            [params SSDKSetupLineParamsByText:text
                                        image:image
                                         type:contentType];
            
        }
        
        //whatapp
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeWhatsApp]])
        {
            
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *audioPath = nil;
            NSString *videoPath = nil;
            CGFloat menuX;
            CGFloat menuY;
            SSDKContentType contentType = SSDKContentTypeText;
            NSDictionary *whatAppDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeWhatsApp]];

            
            if ([[whatAppDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [whatAppDict objectForKey:@"text"];
            }
            if ([[whatAppDict objectForKey:@"audioPath"] isKindOfClass:[NSString class]])
            {
                audioPath = [whatAppDict objectForKey:@"audioPath"];
            }

            if ([[whatAppDict objectForKey:@"videoPath"] isKindOfClass:[NSString class]])
            {
                videoPath = [whatAppDict objectForKey:@"videoPath"];
            }

            if ([[whatAppDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [whatAppDict objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[whatAppDict objectForKey:@"menuX"] isKindOfClass:[NSNumber class]])
            {
                menuX = [[whatAppDict objectForKey:@"menuX"] floatValue];
            }
            if ([[whatAppDict objectForKey:@"menuY"] isKindOfClass:[NSNumber class]])
            {
                menuY = [[whatAppDict objectForKey:@"menuY"] floatValue];
            }
            
            [params SSDKSetupWhatsAppParamsByText:text
                                            image:image
                                            audio:audioPath
                                            video:videoPath
                                 menuDisplayPoint:CGPointMake(menuX, menuY)
                                             type:contentType];
        }
        
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKakao]])
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
            
            SSDKContentType contentType = SSDKContentTypeText;
            SSDKPlatformType subType = SSDKPlatformSubTypeKakaoTalk;
            
            NSDictionary *kakaoDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeKakao]];

            if ([[kakaoDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [kakaoDict objectForKey:@"text"];
            }
            if ([[kakaoDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [kakaoDict objectForKey:@"imageUrl"];
                SSDKImage *image = nil;
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
                                     withString:imagePath])
                {
                    image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                    [images addObject:image];
                }
                else
                {
                    UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                    image = [[SSDKImage alloc]initWithImage:localImage
                                                     format:SSDKImageFormatJpeg
                                                   settings:nil];
                    [images addObject:image];
                }
                
            }
            else if([[kakaoDict objectForKey:@"imageUrl"] isKindOfClass:[NSArray class]])
            {
                NSArray *imagePaths = [kakaoDict objectForKey:@"imageUrl"];
                for (NSString *imagePath in imagePaths)
                {
                    SSDKImage *image = nil;
                    if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                            options:MOBFRegexOptionsNoOptions
                                            inRange:NSMakeRange(0, 10)
                                         withString:imagePath])
                    {
                        image = [[SSDKImage alloc]initWithURL:[NSURL URLWithString:imagePath]];
                        [images addObject:image];
                    }
                    else
                    {
                        UIImage *localImage = [UIImage imageWithContentsOfFile:imagePath];
                        image = [[SSDKImage alloc]initWithImage:localImage
                                                         format:SSDKImageFormatJpeg
                                                       settings:nil];
                        [images addObject:image];
                    }
                }
            }
            if ([[kakaoDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [kakaoDict objectForKey:@"title"];
            }
            if ([[kakaoDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [kakaoDict objectForKey:@"url"];
            }
            if ([[kakaoDict objectForKey:@"permission"] isKindOfClass:[NSString class]])
            {
                permission = [kakaoDict objectForKey:@"permission"];
            }
            if ([[kakaoDict objectForKey:@"enableShare"] isKindOfClass:[NSNumber class]])
            {
                enableShare = [[kakaoDict objectForKey:@"enableShare"] boolValue];
            }
            if ([[kakaoDict objectForKey:@"imageWidth"] isKindOfClass:[NSNumber class]])
            {
                imageWidth = [[kakaoDict objectForKey:@"imageWidth"] floatValue];
            }
            if ([[kakaoDict objectForKey:@"imageHeight"] isKindOfClass:[NSNumber class]])
            {
                imageHeight = [[kakaoDict objectForKey:@"imageHeight"] floatValue];
            }
            if (imageHeight >= 0 && imageWidth >= 0)
            {
                defaultSize = CGSizeMake(imageWidth, imageHeight);
            }
            if ([[kakaoDict objectForKey:@"appButtonTitle"] isKindOfClass:[NSString class]])
            {
                appButtonTitle = [kakaoDict objectForKey:@"appButtonTitle"];
            }
            if ([[kakaoDict objectForKey:@"androidMarkParam"] isKindOfClass:[NSString class]])
            {
                androidMarkParam = [kakaoDict objectForKey:@"androidMarkParam"];
            }
            if ([[kakaoDict objectForKey:@"iphoneMarkParam"] isKindOfClass:[NSString class]])
            {
                iphoneMarkParam = [kakaoDict objectForKey:@"iphoneMarkParam"];
            }
            if ([[kakaoDict objectForKey:@"ipadMarkParam"] isKindOfClass:[NSString class]])
            {
                ipadMarkParam = [kakaoDict objectForKey:@"ipadMarkParam"];
            }
            if ([[kakaoDict objectForKey:@"androidExecParam"] isKindOfClass:[NSString class]])
            {
                NSString* execStr = [kakaoDict objectForKey:@"androidExecParam"];
                androidExecParam = @{@"androidExecParam" : execStr};
            }
            if ([[kakaoDict objectForKey:@"ipadExecParams"] isKindOfClass:[NSString class]])
            {
                
                NSString* execStr = [kakaoDict objectForKey:@"ipadExecParams"];
                ipadExecParams = @{@"ipadExecParams" : execStr};
                
            }
            if ([[kakaoDict objectForKey:@"iphoneExecParams"] isKindOfClass:[NSString class]])
            {
                NSString* execStr = [kakaoDict objectForKey:@"iphoneExecParams"];
                iphoneExecParams = @{@"iphoneExecParams" : execStr};
            }
            if ([[kakaoDict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[kakaoDict objectForKey:@"type"] integerValue];
            }
            if ([[kakaoDict objectForKey:@"subType"] isKindOfClass:[NSNumber class]])
            {
                subType = [[kakaoDict objectForKey:@"subType"] integerValue];
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
                                          type:contentType
                            forPlatformSubType:subType];
            
        }
        
        //支付宝好友
        if ([contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocial]])
        {
            NSString *text = nil;
            SSDKImage *image = nil;
            NSString *title = nil;
            NSString *url = nil;
            SSDKContentType contentType = SSDKContentTypeText;
            NSDictionary *aliPayDict = [contentDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)SSDKPlatformTypeAliPaySocial]];

            if ([[aliPayDict objectForKey:@"text"] isKindOfClass:[NSString class]])
            {
                text = [aliPayDict objectForKey:@"text"];
            }
            if ([[aliPayDict objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                title = [aliPayDict objectForKey:@"title"];
            }
            if ([[aliPayDict objectForKey:@"url"] isKindOfClass:[NSString class]])
            {
                url = [aliPayDict objectForKey:@"url"];
            }
            if ([[aliPayDict objectForKey:@"imageUrl"] isKindOfClass:[NSString class]])
            {
                NSString *imagePath = [aliPayDict objectForKey:@"imageUrl"];
                
                if ([MOBFRegex isMatchedByRegex:@"\\w://.*"
                                        options:MOBFRegexOptionsNoOptions
                                        inRange:NSMakeRange(0, 10)
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
            if ([[aliPayDict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
            {
                contentType = [[aliPayDict objectForKey:@"type"] integerValue];
            }

            [params SSDKSetupAliPaySocialParamsByText:text
                                                image:image
                                                title:title
                                                  url:[NSURL URLWithString:url]
                                                 type:contentType];
            
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

    [ShareSDK registerApp:appKey
          activePlatforms:platforms
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
                         case SSDKPlatformTypeGooglePlus:
#ifdef __SHARESDK_GOOGLE_PLUS__
                             [ShareSDKConnector connectGooglePlus:[GPPSignIn class]
                                                       shareClass:[GPPShare class]];
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
                        //待续..
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
                   
                    NSDictionary *KakaoDict = [platformConfig objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)obj]];
                    
                    if (KakaoDict && [[KakaoDict allKeys] count] > 0)
                    {
                        [appInfo SSDKSetupKaKaoByAppKey:[KakaoDict objectForKey:@"app_key"]
                                             restApiKey:[KakaoDict objectForKey:@"rest_api_key"]
                                            redirectUri:[KakaoDict objectForKey:@"redirect_uri"]
                                               authType:[KakaoDict objectForKey:@"auth_type"]];
                        
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
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[exception reason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    NSString *url = nil;
    NSString *sourceApp = nil;
    NSString *annotation = nil;
    
    if ([[params objectForKey:@"url"] isKindOfClass:[NSString class]])
    {
        url = [params objectForKey:@"url"];
    }
    if ([[params objectForKey:@"source_app"] isKindOfClass:[NSString class]])
    {
        sourceApp = [params objectForKey:@"source_app"];
    }
    if ([[params objectForKey:@"annotation"] isKindOfClass:[NSString class]])
    {
        annotation = [params objectForKey:@"annotation"];
    }
    
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
            
            if([action isEqualToString:@"registerAppAndSetPlatformConfig"])
            {
                ShareSDKRegisterAppAndSetPlatformConfig([paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"authorize"])
            {
                ShareSDKAuthorize (ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"isAuthorizedValid"])
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
            else if ([action isEqualToString:@"share"])
            {
                ShareSDKShare(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"multishare"])
            {
                ShareSDKOneKeyShare(ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"showShareMenu"])
            {
                ShareSDKShowShareMenu (ctx, [paramDict objectForKey:@"params"]);
            }
            else if ([action isEqualToString:@"showShareView"])
            {
                ShareSDKShowShareView (ctx, [paramDict objectForKey:@"params"]);
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