//
//  DDPPlayView.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/9/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPPlayView.h"
#import <DDPShare/DDPShare.h>

@implementation DDPPlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    if (self.keyDownCallBack) {
        self.keyDownCallBack(event);
    }
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    [sender enumerateDraggingItemsWithOptions:kNilOptions forView:nil classes:@[NSURL.class] searchOptions:@{NSPasteboardURLReadingFileURLsOnlyKey : @(YES)} usingBlock:^(NSDraggingItem * _Nonnull draggingItem, NSInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = draggingItem.item;
        [self sendParseMessageWithURL:url];
        *stop = YES;
    }];
    return YES;
}

- (void)sendParseMessageWithURL:(NSURL *)url {
    DDPParseMessage *message = [[DDPParseMessage alloc] init];
    message.path = url.path;
    [[DDPMessageManager sharedManager] sendMessage:message];
}

@end
