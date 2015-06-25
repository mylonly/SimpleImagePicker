//
//  SimpleImagePreviewController.m
//  SimpleImagePicker
//
//  Created by 田祥根 on 15/6/23.
//
//

#import "SimpleImagePreviewController.h"
#import "SimpleImagePreviewView.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define PREVIEWIMAGEVIEWBASE 1000

@interface SimpleImagePreviewController ()<UIScrollViewDelegate>
{
    UILabel* m_numLabel;
    UIScrollView* m_scrollView;
    UIImageView* m_selectedView;
    
    UIButton* m_cancelBtn;
    UIButton* m_doneBtn;
    
    SimpleImagePreviewView* m_currentPreviewImageView;
}
@end

@implementation SimpleImagePreviewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    m_scrollView.bounces = NO;
    m_scrollView.delegate = self;
    m_scrollView.pagingEnabled = YES;
    m_scrollView.backgroundColor = [UIColor blackColor];

    [self.view addSubview:m_scrollView];
    
    
    for (int i = 0;i < _selectedAssetURLs.count;i++)
    {
        NSURL* assetUrl = _selectedAssetURLs[i];
        ALAssetsLibrary* libaray = [[ALAssetsLibrary alloc] init];
        [libaray assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
            SimpleImagePreviewView* imageView = [[SimpleImagePreviewView alloc] initWithFrame:CGRectMake(i*m_scrollView.bounds.size.width, 0, m_scrollView.bounds.size.width, m_scrollView.bounds.size.height)];
            imageView.selected = YES;
            imageView.tag = PREVIEWIMAGEVIEWBASE+i+1;
            imageView.image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            [m_scrollView addSubview:imageView];
            if (!i)
            {
                m_currentPreviewImageView = imageView;
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }
    [m_scrollView setContentSize:CGSizeMake(m_scrollView.bounds.size.width*_selectedAssetURLs.count, m_scrollView.bounds.size.height)];
    
    [self createHeader];
    [self createFooter];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)createHeader
{
    m_numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    m_numLabel.center = CGPointMake(self.view.bounds.size.width/2, 22);
    m_numLabel.layer.cornerRadius = 20.f;
    m_numLabel.layer.masksToBounds = YES;
    m_numLabel.font = [UIFont boldSystemFontOfSize:18];
    m_numLabel.textAlignment = NSTextAlignmentCenter;
    m_numLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    m_numLabel.textColor = [UIColor whiteColor];
    m_numLabel.text = [NSString stringWithFormat:@"1/%d",_selectedAssetURLs.count];
    [self.view addSubview:m_numLabel];
    
    m_selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-30, 5, 25, 25)];
    m_selectedView.layer.cornerRadius = 12.5f;
    m_selectedView.layer.borderColor = [UIColor whiteColor].CGColor;
    m_selectedView.layer.borderWidth = 0.f;
    m_selectedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    m_selectedView.image = [UIImage imageNamed:@"selected.png"];
    m_selectedView.userInteractionEnabled = YES;
    [self.view addSubview:m_selectedView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedAction:)];
    [m_selectedView addGestureRecognizer:tap];
}

- (void)createFooter
{
    m_cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 40, 60, 25)];
    m_cancelBtn.layer.cornerRadius = 12.5f;
    m_cancelBtn.layer.masksToBounds = YES;
    m_cancelBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    [m_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [m_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [m_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_cancelBtn];
    
    
    m_doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, self.view.bounds.size.height - 40, 60, 25)];
    m_doneBtn.layer.cornerRadius = 12.5f;
    m_doneBtn.layer.masksToBounds = YES;
    m_doneBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    [m_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    [m_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [m_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_doneBtn];
}

#pragma mark Action

- (void)cancelAction:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)doneAction:(UIButton*)sender
{
    for (int i = 0; i < _selectedAssetURLs.count; i++)
    {
        SimpleImagePreviewView* imagePreview =(SimpleImagePreviewView*)[m_scrollView viewWithTag:PREVIEWIMAGEVIEWBASE+i+1];
        if (!imagePreview.selected) {
            [_selectedAssetURLs removeObjectAtIndex:i];
        }
    }
    [self cancelAction:m_cancelBtn];
}

- (void)selectedAction:(UITapGestureRecognizer*)gesture
{
    m_currentPreviewImageView.selected = !m_currentPreviewImageView.selected;
    [self performSelectorInBackground:@selector(updateHeader) withObject:nil];
}


- (void)updateHeader
{
    if (!m_currentPreviewImageView) {
        return;
    }
    m_numLabel.text = [NSString stringWithFormat:@"%d/%d",m_currentPreviewImageView.tag - PREVIEWIMAGEVIEWBASE,_selectedAssetURLs.count];

    if ((m_selectedView.image && m_currentPreviewImageView.selected) ||(!m_selectedView.image && !m_currentPreviewImageView.selected))
    {
        return;
    }
    
    if (m_currentPreviewImageView.selected)
    {
        m_selectedView.image = [UIImage imageNamed:@"selected.png"];
        m_selectedView.layer.borderWidth = 0.f;
        CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        k.values = @[@(0.1),@(1.0),@(1.25)];
        k.keyTimes = @[@(0.0),@(0.2),@(0.8),@(1.0)];
        k.calculationMode = kCAAnimationLinear;
        [m_selectedView.layer addAnimation:k forKey:@"Show"];    }
    else
    {
        m_selectedView.image = nil;
        m_selectedView.layer.borderWidth = 1.f;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    int offset = scrollView.contentOffset.x;
    int width = self.view.bounds.size.width;
    NSInteger m = offset%width;
    NSInteger tag = offset/width+m/(width/2)+1;
    
    m_currentPreviewImageView =(SimpleImagePreviewView*)[m_scrollView viewWithTag:PREVIEWIMAGEVIEWBASE+tag];
    [self performSelectorInBackground:@selector(updateHeader) withObject:nil];
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
