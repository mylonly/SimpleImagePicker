//
//  QBCheckmarkView.h
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/06.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBCheckmarkView : UIView

@property (nonatomic, assign)  CGFloat borderWidth;
@property (nonatomic, assign)  CGFloat checkmarkLineWidth;

@property (nonatomic, strong)  UIColor *borderColor;
@property (nonatomic, strong)  UIColor *bodyColor;
@property (nonatomic, strong)  UIColor *checkmarkColor;

@end
