//
//  QBAssetCell.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/06.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetCell.h"

@interface QBAssetCell ()
{
    QBVideoIndicatorView *videoIndicatorView;
    UIView *overlayView;
}
@end

@implementation QBAssetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.image = [UIImage imageNamed:@"添加拍照.png"];
        self.imageView.layer.borderWidth = 1.f;
        self.imageView.layer.borderColor = [UIColor redColor].CGColor;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    // Show/hide overlay view
    overlayView.hidden = !(selected && self.showsOverlayViewWhenSelected);
}

@end
