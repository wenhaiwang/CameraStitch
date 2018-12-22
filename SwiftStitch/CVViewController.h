//
//  CVViewController.h
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
#import "UIView+Toast.h"

@interface CVViewController : UIViewController<QBImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, weak) IBOutlet UIImageView* imageView;
//@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@end
