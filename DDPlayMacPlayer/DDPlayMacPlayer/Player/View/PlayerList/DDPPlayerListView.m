//
//  DDPPlayerListView.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/10/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPPlayerListView.h"
#import "DDPPlayerTableCellView.h"
#import "NSView+DDPTools.h"
#import <DDPCategory/NSString+DDPTools.h>

@interface DDPPlayerListView ()<NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate>
@property (weak) IBOutlet NSTableColumn *column;
@property (strong) IBOutlet NSMenu *tableMenu;

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSNumber *>*cellHeightDic;
@end

@implementation DDPPlayerListView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.columnAutoresizingStyle = NSTableViewUniformColumnAutoresizingStyle;
    self.tableView.doubleAction = @selector(doubleClickTableView:);
    self.tableView.target = self;
    self.column.width = CGRectGetWidth(self.frame);
    
    [self.tableMenu addItem:[[NSMenuItem alloc] initWithTitle:@"删除" action:@selector(onClickDeleteItem:) keyEquivalent:@""]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidEndLiveResize {
    [super viewDidEndLiveResize];
    [self reloadData];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    
    [self.cellHeightDic removeAllObjects];
    let indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfRows)];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0;
    } completionHandler:^{
        [self.tableView noteHeightOfRowsWithIndexesChanged:indexSet];        
    }];
}

- (void)viewDidMoveToWindow {
    if (self.window) {
        [self reloadData];
    }
}

- (void)reloadData {
    [self.cellHeightDic removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource, NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfRowAtPlayerListView:)]) {
        return [self.delegate numberOfRowAtPlayerListView:self];
    }
    return 0;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    DDPPlayerTableCellView *cell = [tableView makeViewWithIdentifier:@"cell" owner:self];
    if (cell == nil) {
        cell = [DDPPlayerTableCellView loadFromNib];
    }
    
    if ([self.delegate respondsToSelector:@selector(playerListView:titleAtRow:)]) {
        let title = [self.delegate playerListView:self titleAtRow:row];
        cell.label.stringValue = title;
        cell.label.toolTip = title;
    }
    
    NSInteger currentIndex = NSNotFound;
    if ([self.delegate respondsToSelector:@selector(currentPlayIndexAtPlayerListView:)]) {
        currentIndex = [self.delegate currentPlayIndexAtPlayerListView:self];
    }
    
    cell.showPoint = currentIndex == row;
    
    return cell;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self.delegate respondsToSelector:@selector(playerListView:titleAtRow:)]) {
        let index = @(row);
        var value = self.cellHeightDic[index];
        if (value == nil) {
            let title = [self.delegate playerListView:self titleAtRow:row];
            
            NSInteger currentIndex = NSNotFound;
            if ([self.delegate respondsToSelector:@selector(currentPlayIndexAtPlayerListView:)]) {
                currentIndex = [self.delegate currentPlayIndexAtPlayerListView:self];
            }
            
            CGFloat width = CGRectGetWidth(self.frame);
            if (currentIndex == row) {
                width -= 25;
            } else {
                width -= 10;
            }
            
            value = @([title heightForFont:nil width:width]);
            self.cellHeightDic[index] = value;
        }
        return value.doubleValue;
    }

    return 16;
}

#pragma mark - NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu {
    if (self.tableView.selectedRowIndexes.count == 0) {
        [menu cancelTrackingWithoutAnimation];
    }
}



#pragma mark - Private Method
- (void)doubleClickTableView:(NSTableView *)sender {
    if ([self.delegate respondsToSelector:@selector(playerListView:didSelectedRow:)]) {
        [self.delegate playerListView:self didSelectedRow:self.tableView.selectedRow];
    }
}

- (void)onClickDeleteItem:(NSMenuItem *)sender {
    let selectedRowIndexes = self.tableView.selectedRowIndexes;
    if ([self.delegate respondsToSelector:@selector(playerListView:didDeleteWithIndexSet:)]) {
        [self.delegate playerListView:self didDeleteWithIndexSet:selectedRowIndexes];
    }
    [self.tableView removeRowsAtIndexes:selectedRowIndexes withAnimation:NSTableViewAnimationEffectFade];
}



#pragma mark - 懒加载
- (NSMutableDictionary *)cellHeightDic {
    if (_cellHeightDic == nil) {
        _cellHeightDic = [NSMutableDictionary dictionary];
    }
    return _cellHeightDic;
}

@end
