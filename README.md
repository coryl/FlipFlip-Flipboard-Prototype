# FlipFlip-Flipboard-Prototype
(This is an experimental UI/UX design project for fun). A barebones control similar to Flipboard's page flipping animation.

![ScreenShot](http://giant.gfycat.com/AdeptUnimportantGlassfrog.gif)

# How to Use
Simply insert your viewControllers into `self.orderedViewArray`. The demo just uses images, but it supports view controller views with live UI elements. 

# Key Learnings and Decisions
- Most of the magic happens with this single piece of code:
```objective-c
-(void)applyRotation:(CGFloat)degrees toView:(UIView*)view
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 4000;
    transform = CATransform3DRotate(transform, degrees *( M_PI / 180.0f), 1.0f,0.0f, 0.0f);
    view.layer.transform = transform;
}
```
- This rotates a UIView's transform in 3D, allowing it to look like its flipping over.
- So I made a subclass called `FlippableBlockView` which is essentially a UIView with some properties.
- At minimum there are 4 `FlippableBlockView`'s on screen at any given time. 2 for the current page, 1 behind top, 1 behind bottom.
- After a successful flip, regenerate previews for the previous/next page (behind top and behind bottom).

# Refactor
It works well enough, but some things I would have liked to fix/improve are:
- Shadows: It would be way better to put the shadow alpha code in:
`-(void)applyRotation:(CGFloat)degrees toView:(UIView*)view`
- Finer touch: it gets a bit touchy when you try to swipe fast, also the animation durations are fixed in time.
- Page limits: Rather than stop allowing the page to turn when you hit either `0` or `self.orderdViewArray.count`, it would be nicer to allow some degree of flipping and show a black view behind. 

### Helpful sources I used:  
I got started with Stephen Zaharuk's proof of concept:
http://www.infragistics.com/community/blogs/stevez/archive/2014/04/08/ios-objective-c-how-to-simulate-a-flipboard-style-page-turn.aspx
