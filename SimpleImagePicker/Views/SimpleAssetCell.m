//
//  QBAssetCell.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/06.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "SimpleAssetCell.h"

@interface SimpleAssetCell ()
{
    QBVideoIndicatorView *m_videoIndicatorView;
    UIImageView *m_overlayView;
}
@end

@implementation SimpleAssetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.image = [UIImage imageNamed:@"添加拍照.png"];
        [self.contentView addSubview:self.imageView];
        
        m_overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-27, 2, 25, 25)];
        m_overlayView.layer.cornerRadius = 12.5f;
        m_overlayView.layer.borderWidth = 1.f;
        m_overlayView.layer.borderColor = [UIColor whiteColor].CGColor;
        m_overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.contentView addSubview:m_overlayView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    // Show/hide overlay view
    
    if (self.selected)
    {
        m_overlayView.image = [UIImage imageNamed:@"selected.png"];
        m_overlayView.layer.borderWidth = 0.f;
        CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        k.values = @[@(0.1),@(1.0),@(1.25)];
        k.keyTimes = @[@(0.0),@(0.2),@(0.8),@(1.0)];
        k.calculationMode = kCAAnimationLinear;
        [m_overlayView.layer addAnimation:k forKey:@"Show"];
    }
    else
    {
        m_overlayView.image = nil;
        m_overlayView.layer.borderWidth = 1.f;
    }
}

@end
