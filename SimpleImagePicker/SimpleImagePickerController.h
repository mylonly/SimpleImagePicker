//
//  SimpleImagePickerController.h
//  SimpleImagePicker
//
//  Created by 田祥根 on 15/6/18.
//
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>

@class SimpleImagePickerController;

@protocol SimpleImagePickerControllerDelegate <NSObject>


@optional

- (void)simpleImagePickerController:(SimpleImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets;

- (void)selectCamera:(SimpleImagePickerController*)imagePickerController;

- (UIView*)customFooterViewOfImagePicker:(SimpleImagePickerController*)imagePickerController;

@end

typedef NS_ENUM(NSUInteger, SimpleImagePickerControllerFilterType)
{
    SimpleImagePickerControllerFilterTypeNone = 0,
    SimpleImagePickerControllerFilterTypePhotos,
    SimpleImagePickerControllerFilterTypeVideos
};



@interface SimpleImagePickerController : UICollectionViewController

@property (nonatomic,weak) id<SimpleImagePickerControllerDelegate> delegate;

@property (nonatomic,assign) SimpleImagePickerControllerFilterType filterType;

@property (nonatomic,strong) NSMutableOrderedSet *selectedAssetURLs;
@property (nonatomic,strong) UIColor* baseColor;

@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@property (nonatomic, assign) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic, assign) NSUInteger numberOfColumnsInLandscape;

+ (BOOL)isAccessible;

@end
