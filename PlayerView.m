//
//  PlayerView.m
//  Swing_Checker
//
//  Created by オオタ イサオ on 13/02/17.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import "PlayerView.h"

@implementation PlayerView

+(Class)layerClass {
    
    return [AVPlayerLayer class];
}

- (AVPlayer*)player { 
    return [(AVPlayerLayer *)[self layer] player];
}

-(void)setPlayer:(AVPlayer *)player { 
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)dealloc
{
    [super dealloc];
}

@end
