//
//  SimpleImagePreviewView.m
//  SimpleImagePicker
//
//  Created by 田祥根 on 15/6/24.
//
//

#import "SimpleImagePreviewView.h"
@interface SimpleImagePreviewView()
{
    CGRect oldFrame;
}
@end


@implementation SimpleImagePreviewView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        // 旋转手势
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
        [self addGestureRecognizer:rotationGestureRecognizer];
        
        // 缩放手势
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        [self addGestureRecognizer:pinchGestureRecognizer];
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        oldFrame = self.frame;
    }
    return self;
}

- (void)rotateView:(UIRotationGestureRecognizer*)gesture
{
    UIView *view = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, gesture.rotation);
        [gesture setRotation:0];
    }
}

- (void)pinchView:(UIPinchGestureRecognizer*)gesture
{
    UIView *view = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale);
        gesture.scale = 1;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (view.frame.size.width < oldFrame.size.width)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            } completion:^(BOOL finished) {
                self.transform = CGAffineTransformMakeRotation(0);
            }];

        }
    }
}

- (void)tapView:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self resetImageView];
    }
}

- (void)resetImageView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}
@end
