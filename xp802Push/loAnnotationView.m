//
//  loAnnotationView.m
//  xp802Push
//
//  Created by Lova on 2014/2/27.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loAnnotationView.h"


UIView* centerView;
NSTimer* timer;

@implementation loAnnotationView

- (id)initWithPoint:(CGPoint)point
{
    CGRect frame=CGRectMake(160+point.x,160+point.y, 16, 16);
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.backgroundColor=[UIColor whiteColor];
        self.layer.cornerRadius=self.frame.size.height/2;
        
        centerView=[[UIView alloc]initWithFrame:CGRectMake(3, 3, 10, 10)];
        centerView.backgroundColor=[UIColor redColor];
        centerView.layer.cornerRadius=centerView.frame.size.height/2;
        
        
        [self addSubview:centerView];

        
        double randomTime=arc4random()%10*0.1 + 2;   //2~3

        timer= [NSTimer scheduledTimerWithTimeInterval:randomTime
                                                target:self
                                              selector:@selector(shakeSelf)
                                              userInfo:nil
                                               repeats:YES];
        
        
    }
    return self;
}

-(void)shakeSelf
{
    NSLog(@"shake!");
    [UIView animateWithDuration:1 animations:^{
        self.frame=CGRectMake(0, 0, 16, 16);
    } completion:^(BOOL finished) {
        self.frame=CGRectMake(3, 3, 10, 10);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
