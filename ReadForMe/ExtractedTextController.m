//
//  ExtractedTextController.m
//  ReadForMe
//
//  Created by Kerim Njuhović on 6/20/16.
//  Copyright © 2016 Developer. All rights reserved.
//

#import "ExtractedTextController.h"

@implementation ExtractedTextController
@synthesize text, OCR_TextView;
-(void)viewDidLoad{
    [super viewDidLoad];
    OCR_TextView.text = text;
    NSLog(@"Value received %@", text);
}

- (IBAction)DismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
