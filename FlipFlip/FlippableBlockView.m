//
//  FlippableBlockView.m
//  FlipFlip
//
//  Created by Cory on 2015-01-21.
//  Copyright (c) 2015 Cory. All rights reserved.
//

#import "FlippableBlockView.h"
#import "DemoViewController.h"

@implementation FlippableBlockView

-  (id)initWithFrame:(CGRect)aRect blockIsTop:(BOOL)onTop withImage:(UIImage *)image
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        self.imageView = [self createImageView];
        [self setupImage:image blockIsTop:onTop];
        
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.shadowView.backgroundColor = [UIColor blackColor];
        self.shadowView.alpha = 0;
        [self addSubview:self.shadowView];
        
    }
    
    return self;
}

-(void)setupImage:(UIImage *)image blockIsTop:(BOOL)onTop{
    CGFloat imgWidth = image.size.width;
    CGFloat imgHeight = image.size.height/2;
    CGRect topImgFrame = CGRectMake(0, 0, imgWidth, imgHeight);
    CGRect bottomImgFrame = CGRectMake(0, imgHeight, imgWidth, imgHeight);
    
    UIImage *finalImage;
    if(onTop){
        finalImage = [self crop:image withRect:topImgFrame];
    } else {
        finalImage = [self crop:image withRect:bottomImgFrame];
    }
    self.imageView.image = finalImage;

    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (UIImage *)crop:(UIImage *)image withRect:(CGRect)rect {
    
    rect = CGRectMake(rect.origin.x*image.scale,
                      rect.origin.y*image.scale,
                      rect.size.width*image.scale,
                      rect.size.height*image.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:image.scale
                                    orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

-(UIImageView*)createImageView
{
    UIImageView* iv = [[UIImageView alloc]init];
    iv.layer.allowsEdgeAntialiasing = YES;
    iv.layer.edgeAntialiasingMask = kCALayerTopEdge | kCALayerBottomEdge | kCALayerRightEdge | kCALayerLeftEdge;
    iv.clipsToBounds = YES;
    iv.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:iv];
    return iv;
}

/* FOR SOME REASON, SETTING THESE LAYER PROPERTIES INTERNALLY DOESN'T WORK!
-(void)setLayerProperties{
    if(self.initializedAsTop){
        //Top block:
        self.layer.anchorPoint = CGPointMake(0.5, 1);
        self.layer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    } else {
        //Bottom block:
        self.layer.anchorPoint = CGPointMake(0.5, 0);
        self.layer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}*/

@end
