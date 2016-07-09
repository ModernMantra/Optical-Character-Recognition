//
//  ViewController.h
//  ReadForMe
//
//  Created by Kerim Njuhović on 3/8/16.
//  Copyright © 2016 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageProcessings.h"
#import "ExtractedTextController.h"
@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *pickerController;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UILabel *processLabel;
- (IBAction)takePhoto:(id)sender;

-(void)saveToPhotoAlbum:(UIImage*)image;

@property (weak, nonatomic) IBOutlet UIButton *takePhoto_buttonProperty;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

