//
//  ViewController.h
//  FlipFlip
//
//  Created by Cory on 2015-01-19.
//  Copyright (c) 2015 Cory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlippableBlockView.h"

@interface ViewController : UIViewController <UIGestureRecognizerDelegate> {
    FlippableBlockView *bottomBlock, *topBlock, *bottomBlockBehind, *topBlockBehind;
    BOOL initiallySwipingUp;
    BOOL pageFlipped;
    CGFloat lastDegrees;
    FlippableBlockView *blockToManipulate, *tempTransitionBlock;
    int currentPageIndex;
}

@property UIPanGestureRecognizer *panGesture;
@property NSMutableArray *orderedViewArray;
@property UIView *currentlyDisplayedView;

@end

