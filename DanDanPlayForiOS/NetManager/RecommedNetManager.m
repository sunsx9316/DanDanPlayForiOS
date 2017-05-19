//
//  RecommedNetManager.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/3/11.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "RecommedNetManager.h"
#import "GDataXMLElement+Tools.h"

@implementation RecommedNetManager
+ (NSURLSessionDataTask *)recommedInfoWithCompletionHandler:(void(^)(JHHomePage *responseObject, NSError *error))completionHandler {
    
    if (completionHandler == nil) {
        return nil;
    }
    
    JHUser *user = [CacheManager shareCacheManager].user;
    
    return [self GETDataWithPath:[NSString stringWithFormat:@"%@/homepage?userId=%lu&token=%@", API_PATH, (unsigned long)user.identity, user.token] parameters:nil headerField:@{@"Accept" : @"application/xml"} completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else {
            NSError *err;
            GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:model.responseObject error:&err];
            
            if (err == nil) {
                JHHomePage *homePageModel = [[JHHomePage alloc] init];
                homePageModel.bangumis = [NSMutableArray array];
                homePageModel.bannerPages = [NSMutableArray array];
                GDataXMLElement *rootElement = document.rootElement;
                //滚动视图
                GDataXMLElement *aElement = [rootElement elementsForName:@"Banner"].firstObject;
                NSArray *aElements = [aElement elementsForName:@"BannerPage"];
                
                for (GDataXMLElement *element in aElements) {
                    JHBannerPage *model = [JHBannerPage yy_modelWithDictionary:[element keysValuesForElementKeys:@[@"Title", @"Description", @"ImageUrl", @"Url"]]];
                    [(NSMutableArray *)homePageModel.bannerPages addObject:model];
                }
                
                //每日推荐
                aElement = [rootElement elementsForName:@"Featured"].firstObject;
                JHFeatured *featuredModel = [JHFeatured yy_modelWithDictionary:[aElement keysValuesForElementKeys:@[@"Title", @"ImageUrl", @"Category", @"Introduction", @"Url"]]];
                homePageModel.todayFeaturedModel = featuredModel;
                
                //推荐番剧
                aElement = [rootElement elementsForName:@"Bangumi"].firstObject;
                aElements = [aElement elementsForName:@"BangumiOfDay"];
                
                for (GDataXMLElement *element in aElements) {
                    NSDictionary *dic = [element keysValuesForElementKeys:@[@"DayOfWeek", @"Bangumi"]];
                    JHBangumiCollection *model = [[JHBangumiCollection alloc] init];
                    model.weekDay = [dic[@"DayOfWeek"] integerValue];
                    model.bangumis = [NSMutableArray array];
                    [(NSMutableArray *)homePageModel.bangumis addObject:model];
                    
                    for (GDataXMLElement *aBangumiElement in dic[@"Bangumi"]) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[aBangumiElement keysValuesForElementKeys:@[@"Name", @"Keyword", @"ImageUrl", @"AnimeId", @"IsFavorite", @"Groups"]]];
                        
                        NSArray *groupsArr = [dic[@"Groups"] elementsForName:@"Group"];
                        dic[@"Groups"] = [NSMutableArray array];
                        for (GDataXMLElement *aGroupsElement in groupsArr) {
                            JHBangumiGroup *groupModel = [JHBangumiGroup yy_modelWithDictionary:[aGroupsElement keysValuesForAttributeKeys:@[@"GroupName", @"SearchUrl"]]];
                            [dic[@"Groups"] addObject:groupModel];
                        }
                        
                        JHBangumi *bangumiDataModel = [JHBangumi yy_modelWithDictionary:dic];
                        [(NSMutableArray *)model.bangumis addObject:bangumiDataModel];
                    }
                }
                
                completionHandler(homePageModel, err);
            }
            else {
                completionHandler(nil, err);
            }
        }
    }];
}

#pragma mark - 私有方法
/**
 *  获取今天星期
 *
 *  @return 1~6对应星期一~六 0对应星期天
 */
+ (NSInteger)weekDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return [comps weekday] - 1;
}
@end
