//
//  ImageProcessings.h
//  ReadForMe
//
//  Created by Kerim Njuhović on 5/7/16.
//  Copyright © 2016 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
#import <Foundation/Foundation.h>
#import "ExtractedTextController.h"
#import "ViewController.h"

@interface ImageProcessings : UIViewController <UINavigationControllerDelegate>

/**
 * Convert image to bitmap and to grayscale with small compression.
 * Processes separately each channel, red green and blue
 */
+ (UIImage *) toGrayscale:(UIImage *)initialImage;

/**
 * For each pixel in the image take the average value of the surrounding area. 
 * If the pixel is less than 90% of this value then it is black, if it is higher then it is white.
 * Filters out flat areas or areas that aren't changing very much
 */
+ (UIImage *) adaptiveTreshold:(UIImage *)sourceImage;

/**
 * Performs extraction of letters from image using Tesseract Framework and precompiled training data
 * Function return string that contains extracted text/letters from image
 */
+(NSString *) OpticalCharacterRecognition:(UIImage *)input_image andMaxDimension:(CGFloat)maxDimension;
@end
