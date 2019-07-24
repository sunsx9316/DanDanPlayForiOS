//
//  DDPPlayerSelectedIndexView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/1.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPPlayerSelectedIndexView.h"
#import "DDPSelectedTableViewCell.h"
#import "DDPBaseTableView.h"

@interface DDPPlayerSelectedIndexView ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

@end

@implementation DDPPlayerSelectedIndexView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textColor = [UIColor whiteColor];
    
    self.blurView.layer.cornerRadius = 4;
    self.blurView.layer.masksToBounds = true;
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.showEmptyView = true;
    [self.tableView registerCellFromClass:[DDPSelectedTableViewCell class]];
    
    [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    
    if (ddp_isLandscape()) {
        [self.blurView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.bottom.mas_equalTo(-20);
            make.width.mas_equalTo(self).multipliedBy(0.5);
        }];
    }
    else {
        [self.blurView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self).multipliedBy(0.5);
            make.centerY.mas_equalTo(0);
            make.width.mas_equalTo(self).multipliedBy(0.8);
        }];
    }
}

- (void)show {
    
    if (self.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.tableView reloadData];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setEffect:(UIVisualEffect *)effect {
    self.blurView.effect = effect;
}

- (UIVisualEffect *)effect {
    return self.blurView.effect;
}

- (void)setContentViewBgColor:(UIColor *)contentViewBgColor {
    self.blurView.backgroundColor = contentViewBgColor;
}

- (UIColor *)contentViewBgColor {
    return self.blurView.backgroundColor;
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    if ([self.dataSource respondsToSelector:@selector(emptyTitleInIndexView:)]) {
        NSString *title = [self.dataSource emptyTitleInIndexView:self];
        if (title.length > 0) {
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowBlurRadius = 3;
            
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor whiteColor], NSShadowAttributeName : shadow}];
            return str;
        }
    }
    
    return nil;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if ([self.dataSource respondsToSelector:@selector(emptyDescriptionInIndexView:)]) {
        NSString *text = [self.dataSource emptyDescriptionInIndexView:self];
        if (text.length > 0) {
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowBlurRadius = 3;
            
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor whiteColor], NSShadowAttributeName : shadow}];
            return str;
        }
    }
    return nil;
}

#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(selectedIndexViewDidTapEmptyView)]) {
        [self.delegate selectedIndexViewDidTapEmptyView];
        [self dismiss];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.dataSource respondsToSelector:@selector(numbeOfSectionInIndexView:)]) {
        return [self.dataSource numbeOfSectionInIndexView:self];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(indexView:numbeOfRowInSection:)]) {
        return [self.dataSource indexView:self numbeOfRowInSection:section];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPSelectedTableViewCell *cell = [tableView dequeueReusableCellWithClass:[DDPSelectedTableViewCell class] forIndexPath:indexPath];
    
    cell.titleLabel.textColor = self.textColor;
    
    if ([self.delegate respondsToSelector:@selector(selectedIndexPathForIndexView)]) {
        NSIndexPath *index = [self.delegate selectedIndexPathForIndexView];
        cell.iconImgView.hidden = [index isEqual:indexPath] == false;
    }
    else {
        cell.iconImgView.hidden = true;
    }
    
    if ([self.dataSource respondsToSelector:@selector(indexView:titleAtIndexPath:)]) {
        NSString *title = [self.dataSource indexView:self titleAtIndexPath:indexPath];
        cell.titleLabel.text = title;
    }
    else {
        cell.titleLabel.text = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if ([self.delegate respondsToSelector:@selector(selectedIndexView:didSelectedIndexPath:)]) {
        [self.delegate selectedIndexView:self didSelectedIndexPath:indexPath];
    }
    [tableView reloadData];
}


@end
