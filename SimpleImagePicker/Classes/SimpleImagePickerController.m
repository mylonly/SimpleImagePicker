//
//  SimpleImagePickerController.m
//  SimpleImagePicker
//
//  Created by 田祥根 on 15/6/18.
//
//

#import "SimpleImagePickerController.h"
#import "SimpleAssetCell.h"
#import "SimpleCameraCell.h"
#import "SimpleImagePreviewController.h"

#ifndef SCREENWIDTH
#define SCREENWIDTH  [[UIScreen mainScreen] bounds].size.width
#endif

#ifndef Y_OFFSET
#define Y_OFFSET (IS_IOS7?20:0)
#endif

#ifndef IS_IOS7
#define IS_IOS7  [[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0
#endif

#ifndef SCREENHEIGHT
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#endif


@interface SimpleImagePickerController ()<UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSArray *m_groupTypes;
    ALAssetsLibrary *m_assetsLibrary;
    NSArray *m_assetsGroups;
    ALAssetsGroup *m_assetsGroup;
    NSArray *m_assets;
    NSUInteger m_numberOfAssets;
    NSUInteger m_numberOfPhotos;
    NSUInteger m_numberOfVideos;
    NSIndexPath *m_indexPathForLastVisibleItem;
    NSIndexPath *m_lastSelectedItemIndexPath;
    
    UIView* m_headerView;
    UIView* m_footerView;
    UIButton* m_titleBtn;
    UIButton* m_doneBtn;
    UIButton* m_previewBtn;
    UITableView* m_tableView;
}
@end

@implementation SimpleImagePickerController

static NSString * const reuseIdentifier = @"ImageCell";
static NSString * const cameraIdentifier = @"CameraIdentifier";

+ (BOOL)isAccessible
{
    return ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] &&
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]);
}


- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        // Set default values
        m_groupTypes = @[
                         @(ALAssetsGroupSavedPhotos),
                         @(ALAssetsGroupPhotoStream),
                         @(ALAssetsGroupAlbum)
                         ];
        self.filterType = SimpleImagePickerControllerFilterTypeNone;
        self.minimumNumberOfSelection = 1;
        self.maximumNumberOfSelection = 9;
        self.numberOfColumnsInPortrait = 4;
        self.numberOfColumnsInLandscape = 7;
        self.baseColor = [UIColor colorWithRed:0 green:202 blue:223 alpha:1];
        m_assetsLibrary = [ALAssetsLibrary new];
        _selectedAssetURLs = [NSMutableOrderedSet orderedSet];
        self.collectionView.allowsMultipleSelection = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    [self createHeaderView];
    [self createFooterView];
    
    [self updateBtn];
    
    self.collectionView.frame = CGRectMake(0, m_headerView.frame.origin.y+m_headerView.frame.size.height, SCREENWIDTH, self.view.bounds.size.height-m_headerView.frame.size.height-m_footerView.frame.size.height);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[SimpleAssetCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[SimpleCameraCell class] forCellWithReuseIdentifier:cameraIdentifier];
    
    [self updateAssetsGroups];
    
    m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.collectionView.frame.origin.y, SCREENWIDTH, 0) style:UITableViewStylePlain];
    m_tableView.dataSource = self;
    m_tableView.delegate = self;
    m_tableView.backgroundColor = [UIColor colorWithRed:120 green:120 blue:200 alpha:1];
    m_tableView.backgroundView = nil;
    m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_tableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBtn];
//    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ACTION

- (void)createHeaderView
{
    if (!m_headerView)
    {
        m_headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREENWIDTH,Y_OFFSET+44)];
        m_headerView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:m_headerView];

        UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,Y_OFFSET, 44, 44)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:self.baseColor forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [m_headerView addSubview:cancelBtn];
        
        m_doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-44, Y_OFFSET, 44, 44)];
        [m_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [m_doneBtn setTitleColor:cancelBtn.titleLabel.textColor forState:UIControlStateNormal];
        [m_doneBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        m_doneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [m_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [m_headerView addSubview:m_doneBtn];
        
        m_titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,Y_OFFSET+7,0,30)];
        [m_titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [m_titleBtn setImage:[UIImage imageNamed:@"down_arrow.png"] forState:UIControlStateNormal];
        [m_titleBtn setImage:[UIImage imageNamed:@"up_arrow.png"] forState:UIControlStateSelected];
        [m_titleBtn setBackgroundImage:[UIImage imageNamed:@"bg.png"] forState:UIControlStateHighlighted];
        [m_titleBtn addTarget:self action:@selector(changeAlbumState:) forControlEvents:UIControlEventTouchDown];
        [m_titleBtn addTarget:self action:@selector(changeAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [m_headerView addSubview:m_titleBtn];
    }
}
- (void)createFooterView
{
    if ([_delegate respondsToSelector:@selector(customFooterViewOfImagePicker:)])
    {
        m_footerView = [_delegate customFooterViewOfImagePicker:self];
    }
    else
    {
        m_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-40, SCREENWIDTH, 40)];
        m_footerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        [self.view addSubview:m_footerView];
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, SCREENWIDTH, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [m_footerView addSubview:line];
        UIButton* originBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7.5, 60, 25)];
        originBtn.layer.cornerRadius = 2.f;
        originBtn.layer.borderColor = [UIColor grayColor].CGColor;
        originBtn.layer.borderWidth = 0.5f;
        [originBtn setTitle:@"原图" forState:UIControlStateNormal];
        originBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [originBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [originBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [m_footerView addSubview:originBtn];
        
        m_previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH-70, 7.5, 60, 25)];
        m_previewBtn.layer.cornerRadius = 2.f;
        m_previewBtn.layer.borderWidth = 0.5f;
        m_previewBtn.layer.masksToBounds = YES;
        m_previewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        m_previewBtn.layer.borderColor = [UIColor grayColor].CGColor;
        [m_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [m_previewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [m_previewBtn setBackgroundImage:[self imageWithColor:self.baseColor andSize:m_previewBtn.bounds.size] forState:UIControlStateNormal];
        [m_previewBtn setBackgroundImage:[self imageWithColor:[UIColor whiteColor] andSize:m_previewBtn.bounds.size] forState:UIControlStateDisabled];
        [m_previewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        m_previewBtn.enabled = NO;
        [m_previewBtn addTarget:self action:@selector(previewAction:) forControlEvents:UIControlEventTouchUpInside];
        [m_footerView addSubview:m_previewBtn];
    }
}

#pragma mark ACTION

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)updateAssetsGroups
{
    [self updateAssetsGroupsWithCompletion:^{
        if (m_assetsGroups.count)
        {
            m_assetsGroup = m_assetsGroups[0];
            [self changeAlbumTitle:[m_assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
            [self setupAssetsGroup];
            [m_tableView reloadData];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [m_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }];
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)doneAction:(UIButton*)sender
{
    if ([_delegate respondsToSelector:@selector(simpleImagePickerController:didSelectAssets:)])
    {
        [_delegate simpleImagePickerController:self didSelectAssets:_selectedAssetURLs.array];
    }
    [self cancelAction];
}

- (void)previewAction:(UIButton*)sender
{
    SimpleImagePreviewController* preview = [[SimpleImagePreviewController alloc] init];
    preview.selectedAssetURLs = _selectedAssetURLs;
    [self presentViewController:preview animated:YES completion:^{
        
    }];
}

- (void)updateBtn
{
    if (_selectedAssetURLs.count >= _minimumNumberOfSelection)
    {
        m_doneBtn.enabled = YES;
        m_previewBtn.enabled = YES;
        NSString* previewTitle = [NSString stringWithFormat:@"预览(%d)",(int)_selectedAssetURLs.count];
        CGSize titleSize = [previewTitle sizeWithFont:m_previewBtn.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, m_previewBtn.bounds.size.height)];
        if (titleSize.width < 60)
        {
            titleSize = CGSizeMake(60, titleSize.height);
        }
        [m_previewBtn setTitle:previewTitle forState:UIControlStateNormal];
        m_previewBtn.frame = CGRectMake(SCREENWIDTH-titleSize.width-20, m_previewBtn.frame.origin.y, titleSize.width+10, m_previewBtn.bounds.size.height);
        m_previewBtn.layer.borderWidth = 0.f;
    }
    else
    {
        NSString* previewTitle = @"预览";
        CGSize titleSize = [previewTitle sizeWithFont:m_previewBtn.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, m_previewBtn.bounds.size.height)];
        if (titleSize.width < 60)
        {
            titleSize = CGSizeMake(60, titleSize.height);
        }
        [m_previewBtn setTitle:previewTitle forState:UIControlStateNormal];
        m_doneBtn.enabled = NO;
        m_previewBtn.enabled = NO;
        m_previewBtn.layer.borderWidth = 0.5f;
    }
}

- (void)changeAlbumState:(UIButton*)sender
{
    sender.layer.cornerRadius = 2.f;
    sender.layer.borderWidth = 0.5f;
    sender.layer.borderColor = [UIColor colorWithRed:205 green:205 blue:205 alpha:1].CGColor;
}

- (void)changeAlbum:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (m_assetsGroups.count)
    {
        CGFloat tableViewHeight = m_assetsGroups.count*60;
        tableViewHeight = tableViewHeight>240?240:tableViewHeight;
        [UIView animateWithDuration:0.5 animations:^{
            m_tableView.frame = CGRectMake(0, m_tableView.frame.origin.y, SCREENWIDTH, sender.selected?tableViewHeight:0);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)changeAlbumTitle:(NSString*)title
{
    CGSize titleSize = [title sizeWithFont:m_titleBtn.titleLabel.font constrainedToSize:CGSizeMake(240, m_titleBtn.frame.size.height)];
    m_titleBtn.frame = CGRectMake(0, 0, titleSize.width>160?titleSize.width:160, titleSize.height>30?titleSize.height:30);
    m_titleBtn.center = CGPointMake(SCREENWIDTH/2, Y_OFFSET+22);
    [m_titleBtn setTitle:title forState:UIControlStateNormal];
    [m_titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -m_titleBtn.imageView.image.size.width, 0, m_titleBtn.imageView.image.size.width)];
    [m_titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, m_titleBtn.titleLabel.bounds.size.width, 0, -m_titleBtn.titleLabel.bounds.size.width)];
}

- (void)setupAssetsGroup
{
    [self updateAssets];
    [self.collectionView reloadData];
}
- (void)updateAssetsGroupsWithCompletion:(void (^)(void))completion
{
    [self fetchAssetsGroupsWithTypes:m_groupTypes completion:^(NSArray *assetsGroups) {
        // Map assets group to dictionary
        NSMutableDictionary *mappedAssetsGroups = [NSMutableDictionary dictionaryWithCapacity:assetsGroups.count];
        for (ALAssetsGroup *assetsGroup in assetsGroups) {
            NSMutableArray *array = mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]];
            if (!array) {
                array = [NSMutableArray array];
            }
            [array addObject:assetsGroup];
            mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]] = array;
        }
        
        // Pick the groups to be shown
        NSMutableArray *sortedAssetsGroups = [NSMutableArray arrayWithCapacity:m_groupTypes.count];
        
        for (NSValue *groupType in m_groupTypes) {
            NSArray *array = mappedAssetsGroups[groupType];
            
            if (array) {
                [sortedAssetsGroups addObjectsFromArray:array];
            }
        }
        m_assetsGroups = sortedAssetsGroups;
        if (completion) {
            completion();
        }
    }];
}

- (void)fetchAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    ALAssetsFilter *assetsFilter;
    
    switch (self.filterType) {
        case SimpleImagePickerControllerFilterTypeNone:
            assetsFilter = [ALAssetsFilter allAssets];
            break;
            
        case SimpleImagePickerControllerFilterTypePhotos:
            assetsFilter = [ALAssetsFilter allPhotos];
            break;
            
        case SimpleImagePickerControllerFilterTypeVideos:
            assetsFilter = [ALAssetsFilter allVideos];
            break;
    }
    
    for (NSNumber *type in types) {
        [m_assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                     usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                         if (assetsGroup) {
                                             // Apply assets filter
                                             [assetsGroup setAssetsFilter:assetsFilter];
                                             
                                             // Add assets group
                                             [assetsGroups addObject:assetsGroup];
                                         } else {
                                             numberOfFinishedTypes++;
                                         }
                                         
                                         // Check if the loading finished
                                         if (numberOfFinishedTypes == types.count) {
                                             if (completion) {
                                                 completion(assetsGroups);
                                             }
                                         }
                                     } failureBlock:^(NSError *error) {
                                         NSLog(@"Error: %@", [error localizedDescription]);
                                     }];
    }
}

- (void)fetchAssetsFromSelectedAssetURLsWithCompletion:(void (^)(NSArray *assets))completion
{
    // Load assets from URLs
    // The asset will be ignored if it is not found
    NSMutableOrderedSet *selectedAssetURLs = _selectedAssetURLs;
    
    __block NSMutableArray *assets = [NSMutableArray array];
    
    void (^checkNumberOfAssets)(void) = ^{
        if (assets.count == selectedAssetURLs.count) {
            if (completion) {
                completion([assets copy]);
            }
        }
    };
    
    for (NSURL *assetURL in selectedAssetURLs) {
        [m_assetsLibrary assetForURL:assetURL
                       resultBlock:^(ALAsset *asset) {
                           if (asset) {
                               // Add asset
                               [assets addObject:asset];
                               
                               // Check if the loading finished
                               checkNumberOfAssets();
                           } else {
                               [m_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                   [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                           // Add asset
                                           [assets addObject:result];
                                           
                                           // Check if the loading finished
                                           checkNumberOfAssets();
                                           
                                           *stop = YES;
                                       }
                                   }];
                               } failureBlock:^(NSError *error) {
                                   NSLog(@"Error: %@", [error localizedDescription]);
                               }];
                           }
                       } failureBlock:^(NSError *error) {
                           NSLog(@"Error: %@", [error localizedDescription]);
                       }];
    }
}

- (void)updateAssets
{
    NSMutableArray *assets = [NSMutableArray array];
    __block NSUInteger numberOfAssets = 0;
    __block NSUInteger numberOfPhotos = 0;
    __block NSUInteger numberOfVideos = 0;
    
    [m_assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            numberOfAssets++;
            
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if ([type isEqualToString:ALAssetTypePhoto]) numberOfPhotos++;
            else if ([type isEqualToString:ALAssetTypeVideo]) numberOfVideos++;
            
            [assets addObject:result];
        }
    }];
    
    m_assets = assets;
    m_numberOfAssets = numberOfAssets;
    m_numberOfPhotos = numberOfPhotos;
    m_numberOfVideos = numberOfVideos;
}


#pragma mark tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_assetsGroups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *  ablumCellIdentifier = @"AblumCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ablumCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ablumCellIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    ALAssetsGroup* assetGroup = m_assetsGroups[indexPath.row];
    NSUInteger numberOfAsserts = [assetGroup numberOfAssets];
    if (numberOfAsserts)
    {
        [assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                cell.imageView.image = [UIImage imageWithCGImage:[result thumbnail]];
                
            }
        }];
    }
    cell.textLabel.text = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)numberOfAsserts];
    return cell;
}

#pragma mark UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    m_assetsGroup = m_assetsGroups[indexPath.row];
    [self changeAlbumTitle:[m_assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    [self changeAlbum:m_titleBtn];
    [self setupAssetsGroup];
}

#pragma mark UICollectionViewFlewLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfColumns;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        numberOfColumns = self.numberOfColumnsInPortrait;
    } else {
        numberOfColumns = self.numberOfColumnsInLandscape;
    }
    CGFloat width = (CGRectGetWidth(self.view.frame) - 2.0 * (numberOfColumns + 1)) / numberOfColumns;
    return CGSizeMake(width, width);
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.f;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return m_numberOfAssets+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item)
    {
        SimpleAssetCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        // Image
        ALAsset *asset = m_assets[m_numberOfAssets - indexPath.item];
        UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
        cell.imageView.image = image;
        NSURL* assetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
        
        if ([_selectedAssetURLs containsObject:assetUrl])
        {
            cell.selected = YES;
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
        }
        return cell;
    }
    else
    {
        SimpleCameraCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cameraIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark <UICollectionViewDelegate>


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return !(_selectedAssetURLs.count == self.maximumNumberOfSelection);
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item)
    {
        ALAsset* asset  = m_assets[m_numberOfAssets - indexPath.item];
        NSURL* assetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
        [_selectedAssetURLs addObject:assetUrl];
        [self updateBtn];
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(selectCamera:)])
        {
            [_delegate selectCamera:self];
        }
        else
        {
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = NO;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerController animated:YES completion:^{}];
            }
            else
            {
                NSLog(@"不存在照相机");
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item)
    {
        ALAsset* asset  = m_assets[m_numberOfAssets - indexPath.item];
        NSURL* assetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
        [_selectedAssetURLs removeObject:assetUrl];
        [self updateBtn];
    }
    else
    {
         
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!error)
            {
                [_selectedAssetURLs addObject:assetURL];
                [self updateBtn];
                [self updateAssetsGroups];
            }
        }];
    }];
}



@end
