//
//  SimpleImagePreviewController.m
//  SimpleImagePicker
//
//  Created by 田祥根 on 15/6/23.
//
//

#import "SimpleImagePreviewController.h"

@interface SimpleImagePreviewController ()
{
    UILabel* m_numLabel;
    UIScrollView* m_scrollView;
    UIImageView* m_selectedView;
}
@end

@implementation SimpleImagePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    m_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:m_scrollView];
    
    m_numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    m_numLabel.center = CGPointMake(self.view.bounds.size.width/2, 22);
    m_numLabel.layer.cornerRadius = 20.f;
    m_numLabel.layer.masksToBounds = YES;
    m_numLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    m_numLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:m_numLabel];
    
    m_selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-27, 2, 25, 25)];
    m_selectedView.layer.cornerRadius = 12.5f;
    m_selectedView.layer.borderColor = [UIColor whiteColor].CGColor;
    m_selectedView.layer.borderWidth = 1.f;
    m_selectedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    [self.view addSubview:m_selectedView];
    
    UIView* footView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 40)];
    [self.view addSubview:footView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
