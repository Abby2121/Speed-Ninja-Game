//
//  HelloWorldLayer.h
//  Speed Ninja
//
//  Created by Abigail Thurmond on 5/17/13.
//  Copyright Abigail Thurmond 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor {
    int score;
    CCLabelTTF *scoreLabel;
    NSMutableArray *sprite;
    NSMutableArray *_monsters;
    NSMutableArray *_projectiles;
    NSMutableArray *_SpeedNinja;
    NSMutableArray *_live;
    NSMutableArray *_lostlive;
    
    int _monstersDestroyed;
    int _lives;
    
}

// -(void)addPoint declared in .h and .m under init
- (void)addPoint;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
