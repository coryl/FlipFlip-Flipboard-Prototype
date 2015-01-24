//
//  ViewController.m
//  FlipFlip
//
//  Created by Cory on 2015-01-19.
//  Copyright (c) 2015 Cory. All rights reserved.
//

#import "ViewController.h"
#import "DemoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:self.panGesture];
    
    self.orderedViewArray = [[NSMutableArray alloc] init];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    for(int i = 1; i <= 6; i++){
        NSString *base = @"flipboard_";
        NSString *filename = [base stringByAppendingString:[NSString stringWithFormat:@"%i.png", i]];;
        NSLog(@"filename is %@", filename);
        DemoViewController *vc = (DemoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"demoVC"];
        [self.view addSubview:vc.view];
        [vc.imageView setImage:[UIImage imageNamed:filename]];
        [vc.view removeFromSuperview];
        [self.orderedViewArray addObject:vc];


    }
    
    currentPageIndex = 0;
    
    topBlockBehind = [self createFlippableBlockAsTop:YES ofPageIndex:currentPageIndex-1];
    bottomBlockBehind = [self createFlippableBlockAsTop:NO ofPageIndex:currentPageIndex+1];
    [self.view addSubview:topBlockBehind];
    [self.view addSubview:bottomBlockBehind];

    topBlock = [self createFlippableBlockAsTop:YES ofPageIndex:currentPageIndex];
    bottomBlock = [self createFlippableBlockAsTop:NO ofPageIndex:currentPageIndex];
    
    topBlock.hidden = YES;
    bottomBlock.hidden = YES;
    
    self.currentlyDisplayedView = ((DemoViewController *)[self.orderedViewArray objectAtIndex:currentPageIndex]).view;
    [self.view addSubview:self.currentlyDisplayedView];

    [self.view addSubview:topBlock];
    [self.view addSubview:bottomBlock];
}

-(UIImage *)screenshotOfPage:(int)pageNum{
    NSLog(@"generating a screenshot of page %i", pageNum);
    DemoViewController *vc = [self.orderedViewArray objectAtIndex:pageNum];
    return [self imageWithView:vc.view];
}

-(UIImage *)imageWithView:(UIView *)view
{
    [self.view addSubview:view];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [view removeFromSuperview];
    
    return img;
}

-(void)applyRotation:(CGFloat)degrees toView:(UIView*)view
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 4000;
    transform = CATransform3DRotate(transform, degrees *( M_PI / 180.0f), 1.0f,0.0f, 0.0f);
    view.layer.transform = transform;
}

-(void)applyRotation:(CGFloat)degrees toView:(UIView*)view withAnimationDuration:(NSTimeInterval)time completion:(void (^)(BOOL complete))block{
    [UIView animateWithDuration:time
     
                     animations:^{
                         [self applyRotation:degrees toView:view];
                     }
                     completion:^(BOOL finished){
                         if(block){
                             block(YES);}
                     }
     ];
}

-(void)handlePan:(UIPanGestureRecognizer *)gesture{    
    if(gesture.state == UIGestureRecognizerStateBegan){
        CGPoint velocity = [gesture velocityInView:self.view];
        //First figure out which direction we're going; if its up we'll only manipulate the bottom half, if its down we'll only manipulate the top half:
        if(velocity.y < 0.0f){
            initiallySwipingUp = YES;
            blockToManipulate = bottomBlock;
            if(currentPageIndex == self.orderedViewArray.count-1) gesture.enabled = NO;

        } else if(velocity.y > 0.0){
            initiallySwipingUp = NO;
            blockToManipulate = topBlock;
            if(currentPageIndex == 0) gesture.enabled = NO;;
        }
        
        topBlock.hidden = NO;
        bottomBlock.hidden = NO;
        self.currentlyDisplayedView.hidden = YES;
        
        //If they swipe fast enough, automatically animate the flip:
        /*if(velocity.y <= -400.0f){
            CGFloat halfwayPoint = 90;
            [self applyRotation:halfwayPoint toView:blockToManipulate withAnimationDuration:0.5];
            lastDegrees = halfwayPoint;
            gesture.enabled = NO;
        } else if(velocity.y >= 400.0f){
            CGFloat halfwayPoint = -90;
            [self applyRotation:halfwayPoint toView:blockToManipulate withAnimationDuration:0.5];
            lastDegrees = halfwayPoint;
            gesture.enabled = NO;
        }*/
        
    } else if (gesture.state == UIGestureRecognizerStateChanged){
        //Otherwise we'll animate as they pan:
        CGPoint translation = [gesture translationInView:self.view];
        CGFloat degrees = -translation.y/2;
        CGFloat bottom = 0;
        CGFloat halfway = 90;
        CGFloat top = 180;
        
        if(initiallySwipingUp == NO){
            bottom = -180;
            halfway = -90;
            top = 0;
        } else if(initiallySwipingUp == YES){
            //nothing yet
        }
        
        if(degrees >= bottom && degrees <= top){
            if(initiallySwipingUp == YES){
                //User swiped past the halfway point upwards:
                if(degrees >= halfway && !pageFlipped){
                    //create a new view of the page
                    FlippableBlockView *newInstance = [self createFlippableBlockAsTop:YES ofPageIndex:currentPageIndex+1];
                    
                    //hide the block that just swiped up to halfway point:
                    tempTransitionBlock = blockToManipulate;
                    tempTransitionBlock.alpha = 0;
                    
                    //reassign blockToManipulate:
                    blockToManipulate = newInstance;
                    [self.view insertSubview:newInstance aboveSubview:topBlock];
                    
                    pageFlipped = YES;
                }
                //User hasn't released touch, but is swiping back down, restore old view:
                else if (degrees < halfway && pageFlipped){
                    //get rid of the newly created block:
                    [blockToManipulate removeFromSuperview];
                    //reassign blockToManipulate to use the previous block:
                    blockToManipulate = tempTransitionBlock;
                    blockToManipulate.alpha = 1;
                    
                    pageFlipped = NO;
                }
            } else if (initiallySwipingUp == NO){
                if(degrees <= halfway && !pageFlipped){
                    //create new view of the new page:
                    FlippableBlockView *newInstance = [self createFlippableBlockAsTop:NO ofPageIndex:currentPageIndex-1];
                    //hide the block that just swiped down to halfway point:
                    tempTransitionBlock = blockToManipulate;
                    tempTransitionBlock.alpha = 0;
                    //reassign blockToManipulate:
                    blockToManipulate = newInstance;
                    [self.view insertSubview:newInstance aboveSubview:bottomBlock];

                    pageFlipped = YES;
                } else if (degrees > halfway && pageFlipped){
                    //get rid of the newly created block:
                    [blockToManipulate removeFromSuperview];
                    //reassign blockToManipulate to previous block:
                    blockToManipulate = tempTransitionBlock;
                    blockToManipulate.alpha = 1;
                    
                    pageFlipped = NO;
                }
            }
        
            CGFloat degreesToApply = degrees;
           
            //Alpha shadow adjustments on the blockToManipulate:
            CGFloat alpha = degreesToApply/800.0f;
            if(!initiallySwipingUp && !pageFlipped) alpha *= -1;
            if(pageFlipped){
                degreesToApply = 180 - degrees * -1;
                if(initiallySwipingUp){
                    //blockToManipulate alpha:
                    alpha = 90/800.0f - (degreesToApply-270)/800.0f;
                    
                    topBlock.shadowView.alpha = (degreesToApply-270)/200.0f;
                }
                else if(!initiallySwipingUp){
                    //blockToManipulate alpha:
                    alpha = (90/800.0f - (degreesToApply+90)/800.0f) * -1;
                    bottomBlock.shadowView.alpha = (90-degreesToApply)/200.0f ;
                }
            }
            blockToManipulate.shadowView.alpha = alpha;

            [self applyRotation:degreesToApply toView:blockToManipulate];
        }
        
        lastDegrees = degrees;
        
    } else if(gesture.state == UIGestureRecognizerStateEnded){
        self.panGesture.enabled = NO;
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             blockToManipulate.shadowView.alpha = 0;
                             topBlock.shadowView.alpha = 0;
                             bottomBlock.shadowView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }
         ];
        
        if(!pageFlipped){
            //didn't flip, animate to return the block to where it started,
            [self applyRotation:0 toView:blockToManipulate withAnimationDuration:0.5
                     completion:^(BOOL complete){
                         self.currentlyDisplayedView.hidden = NO;
                         topBlock.hidden = YES;
                         bottomBlock.hidden = YES;
                         self.panGesture.enabled = YES;
                     }];
        }
        if(pageFlipped){
            if(initiallySwipingUp){
                //The user swiped up and transitioned the page, meaning they are on the next page.
                currentPageIndex += 1;

                [tempTransitionBlock removeFromSuperview];
                [topBlockBehind removeFromSuperview];
                
                FlippableBlockView *temp = topBlock;
                topBlock = blockToManipulate;
                topBlockBehind = temp;
                
                bottomBlock = bottomBlockBehind;
                bottomBlockBehind = [self createFlippableBlockAsTop:NO ofPageIndex:currentPageIndex+1];
                [self.view insertSubview:bottomBlockBehind belowSubview:bottomBlock];
      
            } else {
                //They swiped down, meaning they are now on the previous page.
                currentPageIndex -= 1;
                NSLog(@"finishing with page index %i", currentPageIndex);
                if(currentPageIndex <= 0) currentPageIndex = 0;
                [tempTransitionBlock removeFromSuperview];
                [bottomBlockBehind removeFromSuperview];
                
                FlippableBlockView *temp = bottomBlock;
                bottomBlock = blockToManipulate;
                bottomBlockBehind = temp;
                
                topBlock = topBlockBehind;
                topBlockBehind = [self createFlippableBlockAsTop:YES ofPageIndex:currentPageIndex-1];
                [self.view insertSubview:topBlockBehind belowSubview:topBlock];

            }
            
            [self applyRotation:0 toView:blockToManipulate withAnimationDuration:0.2
                     completion:^(BOOL complete){
                         self.currentlyDisplayedView.hidden = NO;
                         topBlock.hidden = YES;
                         bottomBlock.hidden = YES;
                         
                         [self.currentlyDisplayedView removeFromSuperview];
                         self.currentlyDisplayedView = ((DemoViewController *)[self.orderedViewArray objectAtIndex:currentPageIndex]).view;
                         [self.view addSubview:self.currentlyDisplayedView];
                         
                         //ensure that topblock or bottom block are on top:
                         
                         for(FlippableBlockView *block in self.view.subviews){
                             if([block isKindOfClass:[FlippableBlockView class]]){
                                 if([block isEqual:topBlock] || [block isEqual:bottomBlock]){
                                     [self.view bringSubviewToFront:block];
                                 }
                             }
                         }
                         
                         self.panGesture.enabled = YES;

                     }];
        }
        
        pageFlipped = NO;
    }

    gesture.enabled = YES;

}

-(FlippableBlockView *)createFlippableBlockAsTop:(BOOL)top ofPageIndex:(int)index{
    //BOOL top tells us if this new block is ending up on top or bottom. If top, it means the bottom was flipped up, so top should show next page.
    if(index < 0) index = 0;
    if(index >= self.orderedViewArray.count - 1)
        index = (int)self.orderedViewArray.count-1;
    
    CGRect frame;
    if(top){
        frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
    } else {
        frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
    }
   
    FlippableBlockView *newBlock = [[FlippableBlockView alloc] initWithFrame:frame blockIsTop:top withImage:[self screenshotOfPage:index]];
   
    if(top) newBlock.layer.anchorPoint = CGPointMake(0.5, 1);
    else newBlock.layer.anchorPoint = CGPointMake(0.5, 0);
    newBlock.layer.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);

    return newBlock;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    return fabs(velocity.y) > fabs(velocity.x);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
