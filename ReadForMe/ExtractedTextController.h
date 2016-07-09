//
//  ExtractedTextController.h
//  ReadForMe
//
//  Created by Kerim Njuhović on 6/20/16.
//  Copyright © 2016 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtractedTextController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *OCR_TextView;
- (IBAction)DismissView:(id)sender;
@property NSString *text;
@end
