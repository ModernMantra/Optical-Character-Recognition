//
//  ImageProcessings.m
//  ReadForMe
//
//  Created by Kerim Njuhović on 5/7/16.
//  Copyright © 2016 Developer. All rights reserved.
//

#import "ImageProcessings.h"
#import <TesseractOCR/TesseractOCR.h>
@implementation ImageProcessings
float IMAGE_HEIGHT, IMAGE_WIDTH;
+ (UIImage *) toGrayscale:(UIImage *)initialImage
{
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, initialImage.size.width * initialImage.scale, initialImage.size.height * initialImage.scale);
    NSLog(@"Image dimensions are %f, %f, %f", initialImage.size.width, initialImage.size.height, initialImage.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    IMAGE_HEIGHT = height;
    IMAGE_WIDTH = width;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [initialImage CGImage]);
    
    for(int y = 0; y < height; y++){
        for(int x = 0; x < width; x++){
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            uint32_t gray = 0.21 * rgbaPixel[RED] + 0.71 * rgbaPixel[GREEN] + 0.07 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:initialImage.scale
                                           orientation:UIImageOrientationRight];
    
    return resultUIImage;
}

+ (UIImage *) adaptiveTreshold:(UIImage *)initialImage{
    
    CGRect imageRect = CGRectMake(0, 0, initialImage.size.width * initialImage.scale, initialImage.size.height * initialImage.scale);
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [initialImage CGImage]);
    
    int IMAGE_HEIGHT = imageRect.size.height;
    int IMAGE_WIDTH = imageRect.size.width;
    int S = (IMAGE_WIDTH/8);
    float T =  (0.15f);
    /*
     checking whether conversion from bitmap to UIimage and vice versa works
     */
    //UIImageWriteToSavedPhotosAlbum([ImageProcessings convertBitmapRGBA8ToUIImage:input withWidth:IMAGE_WIDTH withHeight:IMAGE_HEIGHT], nil, nil, nil);
    
    unsigned long* integralImg = (unsigned long*)malloc(IMAGE_WIDTH*IMAGE_HEIGHT*sizeof(unsigned long*));
    long sum=0;
    int count=0;
    int index = 0;
    int x1, y1, x2, y2;
    int s2 = S/2;
    // create the integral image
    for (int i = 0; i < IMAGE_WIDTH; i++){
        // reset this column sum
        sum = 0;
        for (int j = 0; j < IMAGE_HEIGHT; j++){
            index = j*IMAGE_WIDTH+i;
            uint8_t *rgbaPixel = (uint8_t *) &pixels[index];
            sum += rgbaPixel[index];
            
            if (i==0)
                integralImg[index] = sum;
            else
                integralImg[index] = integralImg[index-1] + sum;
        }
    }
    // perform thresholding
    for (int i = 0; i < width; i++){
        for (int j = 0; j < height; j++){
            index = j*IMAGE_WIDTH+i;
            uint8_t *rgbaPixel = (uint8_t *) &pixels[index];
            uint32_t value;
            // set the SxS region
            x1=i-s2;
            x2=i+s2;
            y1=j-s2;
            y2=j+s2;
            count = (x2-x1)*(y2-y1);
            // check the border
            if (x1 < 0)
                x1 = 0;
            if (x2 >= IMAGE_WIDTH)
                x2 = IMAGE_WIDTH-1;
            if (y1 < 0)
                y1 = 0;
            if (y2 >= IMAGE_HEIGHT)
                y2 = IMAGE_HEIGHT-1;
            
            // I(x,y)=s(x2,y2)-s(x1,y2)-s(x2,y1)+s(x1,x1)
            sum = integralImg[y2*IMAGE_WIDTH+x2] -
            integralImg[y1*IMAGE_WIDTH+x2] -
            integralImg[y2*IMAGE_WIDTH+x1] +
            integralImg[y1*IMAGE_WIDTH+x1];
            
            if ((long)(rgbaPixel[1]*count) < (long)(sum*(1.0-T)) && (long)(rgbaPixel[2]*count) < (long)(sum*(1.0-T)) && (long)(rgbaPixel[3]*count) < (long)(sum*(1.0-T))){
                value = 0;
            }
            else{
                value = 255;
            }
            rgbaPixel[1] = value;
            rgbaPixel[2] = value;
            rgbaPixel[3] = value;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:initialImage.scale
                                           orientation:UIImageOrientationRight];
    //UIImageWriteToSavedPhotosAlbum(resultUIImage, NULL, NULL, NULL);
    return resultUIImage;
}



+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {
    
    CGImageRef imageRef = image.CGImage;
    
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
    if(!context) {
        return NULL;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
    
    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;
    
    unsigned char *newBitmap = NULL;
    
    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);
        
        if(newBitmap) {	// Copy the data
            for(int i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }
    }
    else {
        NSLog(@"Error getting bitmap pixel data\n");
    }
    
    CGContextRelease(context);
    
    return newBitmap;
}

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);	// RGBA
    
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer
                                withWidth:(int) width
                               withHeight:(int) height {
    
    
    size_t bufferLength = width * height * 32;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if(colorSpaceRef == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,	// data provider
                                    NULL,		// decode
                                    YES,			// should interpolate
                                    renderingIntent);
    
    uint32_t* pixels = (uint32_t*)malloc(bufferLength);

    if(pixels == NULL) {
        NSLog(@"Error: Memory not allocated for bitmap");
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);
        return nil;
    }
    
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow, 
                                                 colorSpaceRef,
                                                 bitmapInfo);
    
    if(context == NULL) {
        NSLog(@"Error context not created");
        free(pixels);
    }
    
    UIImage *image = nil;
    if(context) {
        
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);

        CGImageRelease(imageRef);	
        CGContextRelease(context);	
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);
    
    free(pixels);
    
    return image;
}

+(NSString *) OpticalCharacterRecognition:(UIImage *)input_image andMaxDimension:(CGFloat)maxDimension{
    
    CGSize scaledSize = CGSizeMake(maxDimension, maxDimension);
    CGFloat scaleFactor;
    
    if (input_image.size.width > input_image.size.height) {
        scaleFactor = input_image.size.height / input_image.size.width;
        scaledSize.width = maxDimension;
        scaledSize.height = scaledSize.width * scaleFactor;
    } else {
        scaleFactor = input_image.size.width / input_image.size.height;
        scaledSize.height = maxDimension;
        scaledSize.width = scaledSize.height * scaleFactor;
    }
    
    UIGraphicsBeginImageContext(scaledSize);
    [input_image drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    G8Tesseract *tesseract = [[G8Tesseract alloc]init];
    tesseract.language = @"eng";
    tesseract.maximumRecognitionTime = 20.0;
    tesseract.image = picture1.g8_blackAndWhite;
    [tesseract recognize];
    NSString *value = [tesseract recognizedText];
    NSLog(@"Recognised text is %@", value);
    NSLog(@"%@", tesseract.characterBoxes);
  
    UIImageWriteToSavedPhotosAlbum([tesseract imageWithBlocks:tesseract.characterBoxes drawText:NO thresholded:NO], nil, nil, nil);

    return value;
}

@end
