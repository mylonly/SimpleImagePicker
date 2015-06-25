//
//  SimpleCameraCell.m
//  SimpleImagePicker
//
//  Created by 田祥根 on 15/6/23.
//
//

#import "SimpleCameraCell.h"

@implementation SimpleCameraCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        self.imageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.imageView.image = [UIImage imageNamed:@"camera.png"];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}


@end
