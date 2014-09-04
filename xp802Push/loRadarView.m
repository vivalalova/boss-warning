//
//  loRadarView.m
//  xp802Push
//
//  Created by Lova on 2014/2/26.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loRadarView.h"
#import "loLocation.h"
#import "loConnectPHP.h"
#import "loAnnotationView.h"
#import <Parse/Parse.h>
#import "loLocation.h"

double x = 0;
UIView *warningBarContentView;

UIImageView *radar;
UITapGestureRecognizer *tap;
NSTimer *radarRotatetimer;

NSTimer *warningCheck;

CGFloat const viewWidth = 320;

@implementation loRadarView

- (id)init {
	self = [super initWithFrame:CGRectMake(0, -568, viewWidth, 568)];
	if (self) {
		_isBossWarning = NO;
		// Initialization code
		[self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];




		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(gotBossWarning)
		                                             name:@"gotBossWarning"
		                                           object:nil];

		radar = [[UIImageView alloc]initWithFrame:CGRectMake(0, -160, viewWidth, 292)];
		radar.image = [UIImage imageNamed:@"Radar_preview.png"];
		[self rotateRadar];
		[self addSubview:radar];

		tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
		[self addGestureRecognizer:tap];

		_viewForAnnotationView = [[UIView alloc]initWithFrame:radar.frame];
		// _viewForAnnotationView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
		_viewForAnnotationView.layer.cornerRadius = _viewForAnnotationView.frame.size.height / 2;
		[self addSubview:_viewForAnnotationView];


		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(warningBarContentViewHeading:)
		                                             name:@"radarHeading" object:nil];



///////////////
		_warningBar = [[UIView alloc]initWithFrame:CGRectMake(0, -200, viewWidth, 136)];
		_warningBar.backgroundColor = [UIColor clearColor];


		UIImageView *contentView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Warning_View.png"]];
		contentView.frame = CGRectMake(0, 0, 320, 136);
		[_warningBar addSubview:contentView];


		warningBarContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 136)];
		warningBarContentView.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7f];
		warningBarContentView.layer.cornerRadius = 5;
		UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(moveLeft:)];
		swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
		[warningBarContentView addGestureRecognizer:swipLeft];


		UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(moveRight:)];
		swipRight.direction = UISwipeGestureRecognizerDirectionRight;
		[warningBarContentView addGestureRecognizer:swipRight];

		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
		[warningBarContentView addGestureRecognizer:tap];

		[_warningBar addSubview:warningBarContentView];



		UIView *fuckView = [[UIView alloc]initWithFrame:CGRectMake(233, 37, 80, 80)];
		fuckView.backgroundColor = [UIColor redColor];
		fuckView.layer.cornerRadius = fuckView.frame.size.height / 2;
		[warningBarContentView addSubview:fuckView];

		UIView *shitView = [[UIView alloc]initWithFrame:CGRectMake(233, 37, 70, 70)];
		shitView.backgroundColor = [UIColor whiteColor];
		shitView.layer.cornerRadius = shitView.frame.size.height / 2;
		[warningBarContentView addSubview:shitView];

		_whoWarned = [[FBProfilePictureView alloc]initWithFrame:CGRectMake(233, 37, 64, 64)];
		_whoWarned.layer.cornerRadius = _whoWarned.frame.size.height / 2;
		[warningBarContentView addSubview:_whoWarned];

		fuckView.center = _whoWarned.center;
		shitView.center = _whoWarned.center;



		_loLabelWhoWarned = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, 200, 44)];
		_loLabelWhoWarned.text = @"WARNING!";
		[_loLabelWhoWarned setTextColor:[UIColor colorWithRed:0.9 green:87 / 256 blue:60 / 256 alpha:1]];

		//     [warningBarContentView addSubview:_loLabelWhoWarned];

		warningCheck = [NSTimer scheduledTimerWithTimeInterval:5
		                                                target:self
		                                              selector:@selector(warningCheck)
		                                              userInfo:nil
		                                               repeats:YES];

		[[NSNotificationCenter defaultCenter]addObserver:self
		                                        selector:@selector(warningCheck)
		                                            name:@"warningCheck"
		                                          object:nil];
	}
	return self;
}

- (void)show {
	self.frame = CGRectMake(0, 0, viewWidth, 568);
	self.alpha = 0;

	radar.frame = CGRectMake(0, -160, viewWidth, 292);
	_viewForAnnotationView.frame = radar.frame;
	[UIView animateWithDuration:0.5 animations: ^{
	    radar.frame = CGRectMake(0, 20, viewWidth, 292);
	    _viewForAnnotationView.frame = radar.frame;
	    self.alpha = 1;
	} completion: ^(BOOL finished) {
	    [[loLocation sharedInstance].locationManager startUpdatingHeading];
	    //  [[loLocation sharedInstance].locationManager startUpdatingLocation];
	}];
}

- (void)hide {
	[[loLocation sharedInstance].locationManager stopUpdatingHeading];
	//  [[loLocation sharedInstance].locationManager stopUpdatingLocation];

	for (UIView *view in _viewForAnnotationView.subviews) {
		[view removeFromSuperview];
	}
	_viewForAnnotationView.transform = CGAffineTransformMakeRotation(0);

	[UIView animateWithDuration:0.5 animations: ^{
	    self.alpha = 0;
	    radar.frame = CGRectMake(0, -160, viewWidth, 320);
	    _viewForAnnotationView.frame = radar.frame;
	} completion: ^(BOOL finished) {
	    self.frame = CGRectMake(0, -568, viewWidth, 568);
	}];
}

/*
   -(void)show
   {


   self.frame=CGRectMake(0, 0, viewWidth, 568);
   self.alpha=0;

   radar.frame=CGRectMake(0, -160, viewWidth, 320);
   _viewForAnnotationView.frame=radar.frame;
   [UIView animateWithDuration:0.5 animations:^{
   radar.frame=CGRectMake(0, 74, viewWidth, 320);
   _viewForAnnotationView.frame=radar.frame;
   self.alpha=1;
   }completion:^(BOOL finished) {
   [[loLocation sharedInstance].locationManager startUpdatingHeading];
   [[loLocation sharedInstance].locationManager startUpdatingLocation];
   }];
   }


   -(void)hide
   {
   [[loLocation sharedInstance].locationManager stopUpdatingHeading];
   [[loLocation sharedInstance].locationManager stopUpdatingLocation];

   for (UIView* view in _viewForAnnotationView.subviews) {
   [view removeFromSuperview];
   }
   _viewForAnnotationView.transform=CGAffineTransformMakeRotation(0);

   [UIView animateWithDuration:0.5 animations:^{
   self.alpha=0;
   radar.frame=CGRectMake(0, -160, viewWidth, 320);
   _viewForAnnotationView.frame=radar.frame;
   }completion:^(BOOL finished) {
   self.frame=CGRectMake(0, -568, viewWidth, 568);

   }];
   }
 */

- (void)gotBossWarning {
	//  NSLog(@"got ");
	_isBossWarning = YES;
	_loLabelWhoWarned.text = @"WARNING!";
	[_loLabelWhoWarned setTextColor:[UIColor colorWithRed:0.9 green:87 / 256 blue:60 / 256 alpha:1]];


	[[loLocation sharedInstance].locationManager startUpdatingLocation];

	dispatch_async(dispatch_get_main_queue(), ^{
	    _whoWarned.profileID  = [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:[NSString stringWithFormat:@"SELECT warned_fb_id FROM `all_groups` where group_id ='%@'",
	                                                                                       [loConnectPHP shareInstance].plistDict[@"group_id"]]
	                                                                              withKey:@"warned_fb_id"];
	});


	[UIView animateWithDuration:0.5 animations: ^{
	    _warningBar.frame = CGRectMake(0, 0, viewWidth, _warningBar.frame.size.height);
	}];


	//set image of loviewcontroller
	[[NSNotificationCenter defaultCenter] postNotificationName:@"changeImageOfLOViewController" object:nil];
}

- (void)cancelBossWarning {
}

#warning rotate
- (void)rotateRadar {
//    if (radarRotatetimer==nil) {
//        radarRotatetimer=[NSTimer scheduledTimerWithTimeInterval:1
//                                                          target:self
//                                                        selector:@selector(rotateRadar)
//                                                        userInfo:nil
//                                                         repeats:YES];
//    }



//    [UIView animateWithDuration:10 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
//        radar.transform=CGAffineTransformMakeRotation(x+=M_PI_2);
//    } completion:^(BOOL finished) {
//        [self rotateRadar];
//    }];

//    [self runSpinAnimationOnView:radar duration:1 rotations:0.5 repeat:YES];

//    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        [radar setTransform:CGAffineTransformRotate(radar.transform, M_PI_2)];
//    }completion:^(BOOL finished){
//        if (finished) {
//            [self rotateRadar];
//        }
//    }];
}

- (void)runSpinAnimationOnView:(UIView *)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0 /* full rotation*/ * rotations * duration];
	rotationAnimation.duration = duration;
	rotationAnimation.cumulative = YES;
	rotationAnimation.repeatCount = repeat;

	[view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark - tap event

- (void)moveLeft:(UISwipeGestureRecognizer *)sender {
	UIView *content = sender.view;

	if (content.frame.origin.x == 0) {
		[UIView animateWithDuration:0.5 animations: ^{
		    content.frame = CGRectMake(-50,
		                               0,
		                               viewWidth,
		                               90);
		}];
	}
}

- (void)moveRight:(UISwipeGestureRecognizer *)sender {
	UIView *content = sender.view;

	if (content.frame.origin.x == -50) {
		[UIView animateWithDuration:0.5 animations: ^{
		    content.frame = CGRectMake(0,
		                               0,
		                               viewWidth,
		                               90);
		}];
	}
}

- (void)tap {
	if ([_loLabelWhoWarned.text isEqualToString:@"Save!!!  (´▽｀)"]) {
		_isBossWarning = NO;

		[UIView animateWithDuration:0.5 animations: ^{
		    _warningBar.frame = CGRectMake(0, -200, viewWidth, _warningBar.frame.size.height);
		}];

		return;
	}

	UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Cancel the Alarm?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil, nil];

	[actionSheet showInView:self.warningBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// NSLog(@"index %d",buttonIndex);
	if (buttonIndex == 0) {
		NSString *groupID = [loConnectPHP shareInstance].plistDict[@"group_id"];
		NSString *message = [NSString stringWithFormat:@"Save!!!  (´▽｀)"];
		NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
		                      [NSString stringWithFormat:@"%@", message], @"alert",
		                      nil];


		[[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`all_groups` SET  `warned_fb_id` =  '' WHERE  `all_groups`.`group_id` ='%@'",
		                                           [loConnectPHP shareInstance].plistDict[@"group_id"]]
		                                afterSYNC:-1
		                               Completion: ^{
		    PFPush *push = [[PFPush alloc]init];
		    [push setChannel:[NSString stringWithFormat:@"a%@", groupID]];
		    [push setData:data];
		    [push sendPushInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
		        if (succeeded) {
		            [_loLabelWhoWarned setText:@"Save!!!  (´▽｀)"];
		            [_loLabelWhoWarned setTextColor:[UIColor colorWithRed:180 / 256 green:100 / 256 blue:256 / 256 alpha:1]];
		            //  [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImageOfLOViewController" object:nil];
				}
			}];
		}];
	}
}

#pragma mark - annos
- (void)setAnnos:(NSMutableArray *)usersLocation;
{
	for (UIView *view in _viewForAnnotationView.subviews) {
		[view removeFromSuperview];
	}


	for (id temp in[loConnectPHP shareInstance].usersPoint) {
		NSValue *value = temp;
		CGPoint point;

		[value getValue:&point];


		loAnnotationView *anno = [[loAnnotationView alloc]initWithPoint:point];

		[_viewForAnnotationView addSubview:anno];
	}
}


- (void)warningBarContentViewHeading:(CLHeading *)newHeading {
	_viewForAnnotationView.transform = CGAffineTransformMakeRotation(([loLocation sharedInstance].locationManager.heading.trueHeading * -1) / 180 * M_PI);
}

- (void)warningCheck {
	if (_isBossWarning) {
		[[loConnectPHP shareInstance]loSQLCommandWithStringReturn:[NSString stringWithFormat:@"SELECT warned_fb_id FROM `all_groups` where group_id='%@'",
		                                                           [loConnectPHP shareInstance].plistDict[@"group_id"]]
		                                                  withKey:@"warned_fb_id"
		                                               Completion: ^(NSString *thekey) {
		    // NSLog(@"the key %@",thekey);
		    if ([thekey isEqualToString:@""]) {
		        _isBossWarning = NO;
		        _loLabelWhoWarned.text = @"Save!!!  (´▽｀)";
		        [_loLabelWhoWarned setTextColor:[UIColor colorWithRed:180 / 256 green:100 / 256 blue:256 / 256 alpha:1]];
		        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImageOfLOViewController" object:nil];


		        [UIView animateWithDuration:1 animations: ^{
		            _warningBar.frame = CGRectMake(0, -160, 320, 292);
				}];

		        [[NSNotificationCenter defaultCenter]postNotificationName:@"shut" object:nil];
			}
		    else {
			}
		    return;
		}];
	}
	else {
	}
}

#pragma mark - CLLocation

@end
