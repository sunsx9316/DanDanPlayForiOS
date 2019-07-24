//
//  HomePageSearchFilterView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageSearchFilterView.h"
#import "DDPBaseTableView.h"
#import "DDPBaseCollectionView.h"
#import "DDPHomePageSearchFilterCollectionViewCell.h"
//#import <WMMenuView.h>
//#import "JHFilterMenuItem.h"


#define CELL_HEIGHT 44

//#define MENU_ITEM_IMG_TAG 1008
//#define MENU_ITEM_LINE_TAG 1009

@interface HomePageSearchFilterView ()<UITableViewDataSource, UITableViewDelegate/*, WMMenuViewDelegate, WMMenuViewDataSource*/, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
//@property (strong, nonatomic) WMMenuView *menuView;
@property (strong, nonatomic) DDPBaseCollectionView *collectionView;

@property (strong, nonatomic) UIView *popView;
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *bottomLineView;
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSNumber *>*selectedIndexDic;
@end

@implementation HomePageSearchFilterView
{
    NSInteger _selectedIndex;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
        _selectedIndex = -1;
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];

        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

//- (void)didMoveToWindow {
//    [super didMoveToWindow];
//    
//    [self reloadData];
//}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self reloadData];
}

- (void)reloadData {
    //        _selectedIndex = -1;
    
    [self.selectedIndexDic removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(defaultSelectedItemAtSection:)]) {
        NSInteger section = [self.dataSource numberOfSection];
        for (NSInteger i = 0; i < section; ++i) {
            self.selectedIndexDic[@(i)] = @([self.delegate defaultSelectedItemAtSection:i]);
        }
    }
    [self.collectionView reloadData];
//    [self.menuView reload];
}

- (NSInteger)selectedItemIndexAtSection:(NSInteger)section {
    return self.selectedIndexDic[@(section)].integerValue;
}

//- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
//             updateSectionTitle:(BOOL)updateSectionTitle {
//    
//}

//- (NSString *)titleInSection:(NSInteger)section {
//    return [_menuView itemAtIndex:section].text;
//}
//
//- (NSInteger)selectedItemIndexAtSection:(NSInteger)section {
//    NSNumber *number = self.selectedIndexDic[@(section)];
//    return number.integerValue;
//}
//
//- (void)selectedSubItemAtIndex:(NSInteger)index section:(NSInteger)section {
//    if (section > [self.dataSource numberOfItem] || index > [self.dataSource numberOfSubItemAtSection:section]) return;
//
//    self.selectedIndexDic[@(section)] = @(index);
//    [_tableView reloadData];
//}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfSection];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDPHomePageSearchFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DDPHomePageSearchFilterCollectionViewCell" forIndexPath:indexPath];
    cell.lineView.hidden = indexPath.item == [self.dataSource numberOfSection] - 1;
    [cell.titleButton setTitle:[self.dataSource itemTitleAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndexDic[@(indexPath.item)].integerValue inSection:indexPath.item]] forState:UIControlStateNormal];
    if (_selectedIndex == indexPath.item) {
        cell.titleButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    else {
        cell.titleButton.imageView.transform = CGAffineTransformIdentity;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(widthAtSection:)]) {
        return CGSizeMake([self.delegate widthAtSection:indexPath.item], self.height);
    }
    
    return CGSizeMake(80, self.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectedIndex != indexPath.item) {
        //将原先选中的小箭头还原
        DDPHomePageSearchFilterCollectionViewCell *item = (DDPHomePageSearchFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
        item.titleButton.imageView.transform = CGAffineTransformIdentity;
    }
    
    _selectedIndex = indexPath.item;
    DDPHomePageSearchFilterCollectionViewCell *cell = (DDPHomePageSearchFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
    
    void(^layoutAction)(void) = ^{
        NSInteger numberOfSubItem = [self.dataSource numberOfItemAtSection:indexPath.item];
        CGFloat cellHeight = CELL_HEIGHT;
        if (numberOfSubItem > 4) {
            cellHeight += 5;
            numberOfSubItem = 4;
        }
        
        self.tableView.frame = CGRectMake(0, 0, self.width, cellHeight * numberOfSubItem);
        cell.titleButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    };
    
    if (self.popView.superview == nil) {
        [self.superview addSubview:self.popView];
        [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
            make.right.left.bottom.mas_equalTo(0);
        }];
        
        [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            layoutAction();
            self.bgView.alpha = 1;
        } completion:nil];
    }
    else {
        [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            layoutAction();
        } completion:nil];
    }
    
    [self.tableView reloadData];

}

//#pragma mark - WMMenuViewDataSource
//- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu {
//    if ([self.dataSource respondsToSelector:@selector(numberOfItem)]) {
//        return [self.dataSource numberOfItem];
//    }
//    return 0;
//}
//
//- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index {
//    if ([self.dataSource respondsToSelector:@selector(itemTitleAtSection:)]) {
//        return [self.dataSource itemTitleAtSection:index];
//    }
//    return nil;
//}
//
//
//- (WMMenuItem *)menuView:(WMMenuView *)menu initialMenuItem:(WMMenuItem *)initialMenuItem atIndex:(NSInteger)index {
//
//    JHFilterMenuItem *item = [[JHFilterMenuItem alloc] initWithItem:initialMenuItem];
//
//    NSInteger numberOfTitle = [self numbersOfTitlesInMenuView:menu];
//    item.lineView.hidden = index == numberOfTitle - 1;
//    return item;
//}
//
//#pragma mark - WMMenuViewDelegate
//- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state atIndex:(NSInteger)index {
//    return [UIFont ddp_normalSizeFont].pointSize;
//}
//
//- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state atIndex:(NSInteger)index {
//    return [UIColor ddp_mainColor];
//}

//- (BOOL)menuView:(WMMenuView *)menu shouldSelesctedIndex:(NSInteger)index {
//    if ([self.dataSource respondsToSelector:@selector(numberOfSubItemAtSection:)] && [self.dataSource respondsToSelector:@selector(subItemTitleAtIndex:section:)]) {
//
//        if (_selectedIndex != index) {
//            //将原先选中的小箭头还原
////            UIImageView *originalImgView = [[menu itemAtIndex:_selectedIndex] viewWithTag:MENU_ITEM_IMG_TAG];
//            JHFilterMenuItem *item = (JHFilterMenuItem *)[menu itemAtIndex:_selectedIndex];
//            item.button.imageView.transform = CGAffineTransformIdentity;
//        }
//
//        _selectedIndex = index;
//        JHFilterMenuItem *item = (JHFilterMenuItem *)[menu itemAtIndex:index];
//
//        void(^layoutAction)(void) = ^{
//            NSInteger numberOfSubItem = [self.dataSource numberOfSubItemAtSection:index];
//            CGFloat cellHeight = CELL_HEIGHT;
//            if (numberOfSubItem > 4) {
//                cellHeight += 5;
//                numberOfSubItem = 4;
//            }
//
//            self.tableView.frame = CGRectMake(0, 0, self.width, cellHeight * numberOfSubItem);
//            item.button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
//        };
//
//        if (self.popView.superview == nil) {
//            [self.superview addSubview:self.popView];
//            [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.mas_bottom);
//                make.right.left.bottom.mas_equalTo(0);
//            }];
//
//            [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                layoutAction();
//                self.bgView.alpha = 1;
//            } completion:nil];
//        }
//        else {
//            [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                layoutAction();
//            } completion:nil];
//        }
//
//        [self.tableView reloadData];
//    }
//
//
//    return NO;
//}

//- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
//    if ([self.dataSource respondsToSelector:@selector(numberOfItem)]) {
//        NSInteger items = [self.dataSource numberOfItem];
//        if (items <= 3 && items > 0) {
//            return kScreenWidth / items;
//        }
//    }
//    return 60;
//}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemAtSection:)]) {
        return [self.dataSource numberOfItemAtSection:_selectedIndex];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DDPBaseTableViewCell className] forIndexPath:indexPath];
    if (cell.isFromCache == NO) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont ddp_normalSizeFont];
        cell.fromCache = YES;
    }
    
    NSString *title = [self.dataSource itemTitleAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:_selectedIndex]];
    cell.textLabel.text = title;
    cell.accessoryType = self.selectedIndexDic[@(_selectedIndex)].integerValue == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.dataSource itemTitleAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:_selectedIndex]];
    self.selectedIndexDic[@(_selectedIndex)] = @(indexPath.row);
    
//    [self.menuView updateTitle:title atIndex:_selectedIndex andWidth:NO];
//
    if ([self.delegate respondsToSelector:@selector(pageSearchFilterView:didSelectedItemAtIndexPath:title:)]) {
        [self.delegate pageSearchFilterView:self didSelectedItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:_selectedIndex] title:title];
    }
    
    [self dismissPopView];
}

#pragma mark - 私有方法
- (void)dismissPopView {
    _selectedIndex = -1;
    [self.collectionView reloadData];
//    DDPHomePageSearchFilterCollectionViewCell *cell = (DDPHomePageSearchFilterCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:_selectedIndexPath];
//
//    JHFilterMenuItem *item = (JHFilterMenuItem *)[self.menuView itemAtIndex:_selectedIndex];
//
////    UIImageView *imgView = [[self.menuView itemAtIndex:_selectedIndex] viewWithTag:MENU_ITEM_IMG_TAG];
//
//    item.button.imageView.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.alpha = 0;
        self.tableView.height = 0;
    } completion:^(BOOL finished) {
        [self.popView removeFromSuperview];
    }];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[DDPBaseTableViewCell class] forCellReuseIdentifier:[DDPBaseTableViewCell className]];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight = CELL_HEIGHT;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (DDPBaseCollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[DDPBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[DDPHomePageSearchFilterCollectionViewCell loadNib] forCellWithReuseIdentifier:@"DDPHomePageSearchFilterCollectionViewCell"];
        
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.alpha = 0;
        _bgView.backgroundColor = DDPRGBAColor(0, 0, 0, DEFAULT_BLACK_ALPHA);
        @weakify(self)
        [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            [self dismissPopView];
        }]];
    }
    return _bgView;
}

//- (WMMenuView *)menuView {
//    if (_menuView == nil) {
//        _menuView = [[WMMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, FILTER_VIEW_HEIGHT)];
//        _menuView.delegate = self;
//        _menuView.dataSource = self;
//        _menuView.backgroundColor = [UIColor whiteColor];
//        _menuView.style = WMMenuViewStyleDefault;
//        [self addSubview:_menuView];
//        [_menuView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.right.mas_equalTo(0);
//            make.bottom.equalTo(self.bottomLineView.mas_top);
//        }];
//    }
//    return _menuView;
//}

#pragma mark - 

- (UIView *)popView {
    if (_popView == nil) {
        _popView = [[UIView alloc] init];
        [_popView addSubview:self.bgView];
        [_popView addSubview:self.tableView];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _popView;
}

- (UIView *)bottomLineView {
    if (_bottomLineView == nil) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = DDPRGBColor(230, 230, 230);
        [self addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

- (NSMutableDictionary<NSNumber *,NSNumber *> *)selectedIndexDic {
    if (_selectedIndexDic == nil) {
        _selectedIndexDic = [NSMutableDictionary dictionary];
    }
    return _selectedIndexDic;
}

@end
