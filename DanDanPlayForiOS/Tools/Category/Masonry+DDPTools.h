//
//  Masonry+AICTools.h
//  AICoin
//
//  Created by JimHuang on 2018/11/9.
//  Copyright © 2018 AICoin. All rights reserved.
//

#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface MASConstraintMaker (DDPTools)

/**
 将原来edges的left和right改为了 Leading和Trailing
 */
@property (nonatomic, strong, readonly) MASConstraint *directionEdges;

@end


@interface UIView (DDPConstraint)

/**
 根据版本适配返回的顶部 11.0之后会返回 safeAreaLayoutGuideTop

 @return 根据版本适配返回的顶部
 */
@property (nonatomic, strong, readonly) MASViewAttribute * _Nullable ddp_safeTop;


/**
 根据版本适配返回的底部 11.0之后会返回 safeAreaLayoutGuideBottom

 @return 根据版本适配返回的底部
 */
@property (nonatomic, strong, readonly) MASViewAttribute * _Nullable ddp_safeBottom;

/**
 根据版本适配返回的左

 @return 11.0之后会返回 safeAreaLayoutGuideLeft
 */
@property (nonatomic, strong, readonly) MASViewAttribute * _Nullable ddp_safeLeft;

/**
 根据版本适配返回的右

 @return 11.0之后会返回 safeAreaLayoutGuideRight
 */
@property (nonatomic, strong, readonly) MASViewAttribute * _Nullable ddp_safeRight;

/**
 根据版本适配返回的Leading
 
 @return 11.0之后会返回 safeAreaLayoutGuideLeft
 */
@property (nonatomic, strong, readonly) MASViewAttribute * _Nullable ddp_safeLeading;

/**
 根据版本适配返回的Trailing
 
 @return 11.0之后会返回 safeAreaLayoutGuideRight
 */
@property (nonatomic, strong, readonly) MASViewAttribute * _Nullable ddp_safeTrailing;

@end

NS_ASSUME_NONNULL_END
