//
//  FlippableBlockView.h
//  FlipFlip
//
//  Created by Cory on 2015-01-21.
//  Copyright (c) 2015 Cory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DemoViewController.h"

@interface FlippableBlockView : UIView

@property UIImageView *imageView;
@property UIView *shadowView;
@property DemoViewController *vc;

-(id)initWithFrame:(CGRect)aRect blockIsTop:(BOOL)onTop withImage:(UIImage *)image;

@end
