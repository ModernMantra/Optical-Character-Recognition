//
//  ViewController.m
//  ReadForMe
//
//  Created by Kerim Njuhović on 3/8/16.
//  Copyright © 2016 Developer. All rights reserved.
//

#import "ViewController.h"
UIImage *uiImage;
NSString *valueToBePassed;
@interface ViewController ()

@end

@implementation ViewController
@synthesize takePhoto_buttonProperty, imageView, spinner, processLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Application Loaded!");
    [self initialViewSetUp];
    [spinner setAlpha:0];
    processLabel.text = @"";
}

-(void)viewDidDisappear:(BOOL)animated{
    imageView.image = NULL;
    [spinner stopAnimating];
    spinner.alpha = 0;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    processLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"Function -viewDidAppear- triggered");
}

-(void)initialViewSetUp{
    takePhoto_buttonProperty.layer.cornerRadius = 3.0f;
    takePhoto_buttonProperty.layer.borderColor = [UIColor blueColor].CGColor;
}

-(void)changeProcessLabelAppearance:(NSString*)textToBeShown{
    //Disappear
    [UIView animateWithDuration:1.0 animations:^(void) {
        processLabel.alpha = 1;
        processLabel.alpha = 0;
    }
                     completion:^(BOOL finished){
                         //Appear
                         [UIView animateWithDuration:1.0 animations:^(void) {
                             processLabel.text = textToBeShown;
                             processLabel.alpha = 1;
                         }];
                     }];
}

- (IBAction)takePhoto:(id)sender {
    NSLog(@"Step 1 -> photo taking");
    
    UIAlertController * alert=[UIAlertController
                               
                               alertControllerWithTitle:@"Choose Source of Image" message:@"You can take image noew by your phone camera, or select image form gallery"preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* galleryButton = [UIAlertAction
                                actionWithTitle:@"Image Gallery"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self GalleryButtonPressed];
                                    
                                }];
    UIAlertAction* cameraButton = [UIAlertAction
                               actionWithTitle:@"Take Photo"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self CameraButtonPressed];
                                   
                               }];
    
    [alert addAction:galleryButton];
    [alert addAction:cameraButton];
    
    [self presentViewController:alert animated:YES completion:nil];


}


- (void)GalleryButtonPressed{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)CameraButtonPressed{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

/*
 Even though method exists, for clear code it is 
 constructed custom method
 */
-(void)saveToPhotoAlbum:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

/*
 MAIN METHOD FROM WHICH ALL OTHER ARE CALLED
 Method is called after image is taken and
 converted to grayscale
 */
-(void)ImageProcessings{
    // save original image to default phone photo album
    [self saveToPhotoAlbum:uiImage];
    UIImage *originalImage = uiImage;
    UIImage *grayScaleImage = [ImageProcessings toGrayscale:uiImage];
    [self saveToPhotoAlbum:grayScaleImage];
    NSLog(@"Step 2 -> Image converted to grayscale");
    // set original taken image as main view
    imageView.image = uiImage;
    // after second delay, chnage imageview
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^{
                       imageView.image = grayScaleImage;
                       [self changeProcessLabelAppearance:@"Gray Scaling"];
                    });
    
    // applying treshold or BINARISATION of image
    UIImage *blackAndWhite = [ImageProcessings adaptiveTreshold:grayScaleImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8.2 * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^{
                       // new converted image set to be on main screen
                       imageView.image = blackAndWhite;
                       [self saveToPhotoAlbum:blackAndWhite];
                       [self changeProcessLabelAppearance:@"Binarisation"];

                   });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.2 * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^{
                       // new converted image set to be on main screen
                       if (originalImage){
                           [self changeProcessLabelAppearance:@"Blob Extraction"];
                               valueToBePassed = [ImageProcessings OpticalCharacterRecognition:originalImage andMaxDimension:640];
                               spinner.alpha = 1.0;
                               [spinner startAnimating];
                       }
                   });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 21 * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^{
                       [self performSegueWithIdentifier:@"go" sender:self];
                   });
}


#pragma mark UIImagePickerController delegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    uiImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.backgroundColor = [UIColor whiteColor];
        [self dismissViewControllerAnimated:YES completion:nil];
        // all processing of image, starting from converting to grayscale, tresholding,etc.
        [self ImageProcessings];
    });
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
    uiImage = img;
    imageView.image=img;
}

#pragma mark Segue delegate methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"go"]){
        ExtractedTextController *object = segue.destinationViewController;
        object.text = valueToBePassed;
    }
}

@end
