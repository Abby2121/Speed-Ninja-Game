//
//  GameOverLayer.h
//  Speed Ninja
//
//  Created by Abigail Thurmond on 5/19/13.
//  Copyright 2013 Abigail Thurmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor
    
+(CCScene *) sceneWithWon:(BOOL)won;
-(id)initWithWon:(BOOL)won;


@end
