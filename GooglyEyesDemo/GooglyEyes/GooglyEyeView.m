/*
 Copyright 2016-present Google Inc. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

@import QuartzCore;

#import "GooglyEyeView.h"
#import "EyePhysics.h"

static const CGFloat kBorderWidth = 4.0;
static const CGFloat kMinimumEyeOpenProbability = 0.3;

@interface GooglyEyeView ()

@property(nonatomic, strong) EyePhysics *physics;
@property(nonatomic, assign) CGRect irisRect;
@property(nonatomic, assign) CGFloat openProbability;
@property(nonatomic, assign) CGFloat faceAngle;

@end

@implementation GooglyEyeView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.physics = [[EyePhysics alloc] init];
    self.irisRect = CGRectZero;
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = kBorderWidth;
    self.layer.masksToBounds = YES;
  }
  return self;
}

- (void)updateEyeRect:(CGRect)eyeRect
    withEyeOpenProbability:(CGFloat)probability
               eulerZAngle:(CGFloat)angle {
  self.frame = eyeRect;
  self.layer.cornerRadius = self.frame.size.height / 2;
  self.openProbability = probability;
  self.faceAngle = angle;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  if (self.openProbability < kMinimumEyeOpenProbability) {
    // Draw the eyelid for the closed eye.

    // Fill the view with yellow as the closed eye color.
    [[UIColor yellowColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);

    // Draw the eyelid based on the face roll angle.
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    CGPoint start = [self.physics point:CGPointMake(0, self.frame.size.height / 2)
                           rotatedAngle:self.faceAngle
                           aroundAnchor:center];
    CGPoint end = [self.physics point:CGPointMake(self.frame.size.width, self.frame.size.height / 2)
                 rotatedAngle:self.faceAngle
                 aroundAnchor:center];
    UIBezierPath *eyelidPath = [UIBezierPath bezierPath];
    [eyelidPath moveToPoint:CGPointMake(0, start.y)];
    [eyelidPath addLineToPoint:CGPointMake(self.frame.size.width, end.y)];
    eyelidPath.lineWidth = kBorderWidth;
    [[UIColor blackColor] setStroke];
    [eyelidPath stroke];
  } else {
    // Draw the iris for the open eye.

    // Fill the view with white as the eyeball color.
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);

    // Draw iris.
    self.irisRect = [self.physics nextIrisRectFrom:self.frame withIrisRect:self.irisRect];
    CGRect iris = [self.superview convertRect:self.irisRect toView:self];
    [[UIColor blackColor] setFill];
    UIBezierPath *irisPath = [UIBezierPath bezierPathWithOvalInRect:iris];
    [irisPath fill];
  }
}

@end
