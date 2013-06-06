//
//  HelloWorldLayer.m
//  Speed Ninja
//
//  Created by Abigail Thurmond on 5/24/13.
//  Copyright Abigail Thurmond 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"
#import "MainMenuScene.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    // 'scene' is an autorelease object.
  CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
    
}

- (void) addMonster {
    
    CCSprite * monster = [CCSprite spriteWithFile:@"SpeedTarget .png"];
    
    // Determine where to spawn the monster along the Y axis
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = monster.contentSize.height / 2;
    int maxY = winSize.height - monster.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = ccp(winSize.width + monster.contentSize.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    CCMoveTo * actionMove = [CCMoveTo actionWithDuration:actualDuration
        position:ccp(-monster.contentSize.width/2, actualY)];
    CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node){
        // CCCallBlockN in addMonster
        [_monsters removeObject:node];
        [node removeFromParentAndCleanup:YES];
        
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }];
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    monster.tag = 1;
    [_monsters addObject:monster];
}

- (void)gameLogic:(ccTime)dt {
    [self addMonster];
}

-(id) init
{
    // always call "super" init
    // Apple recommends to re-assign "self" with "super" return value
    if ((self = [super initWithColor:ccc4(255,255,255,255)])) {
        
        [self setTouchEnabled:YES];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *SpeedNinja = [CCSprite spriteWithFile:@"SpeedNinja .png"];
        SpeedNinja.position = ccp(SpeedNinja.contentSize.width/2, winSize.height/2);
        [self addChild:SpeedNinja z:2];
        
        [self schedule:@selector(gameLogic:) interval:1.0];
        
        [self setTouchEnabled:YES];
        
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        
        [self schedule:@selector(update:)];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"Ninja Background Music.mp3"];
        
        // Set the score to zero.
        score = 0;
        
        // Create and add the score label as a child.
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:20];
        scoreLabel.position = ccp(100, 300);
        [self addChild:scoreLabel z:1];
        
        CCSprite *background = [CCSprite spriteWithFile:@"Speed Ninja Background.bmp"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        // Add in the init method, after background
        [self initHUD];

    
}
    return self;
}

// Add methods for lives
- (void)initHUD
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    _lives = 3;
    
    for (int i = 0; i < 3; i++)
    {
        CCSprite  *live  = [CCSprite spriteWithFile:@"SpeedNinjaLives.png"];
        live.position = ccp(screen.width - live.contentSize.width/2 - 1*live.contentSize.width, screen.height - live.contentSize.height/2);
        [self addChild:live z:4];
    }
}

- (void)subtractLife
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    _lives--;
    CCSprite *lostLife = [CCSprite spriteWithFile:@"SpeedNinjaLostLives.png"];
    lostLife.position = ccp(screen.width - lostLife.contentSize.width/2 - _lives*lostLife.contentSize.width, screen.height - lostLife.contentSize.height/2);
    [self addChild:lostLife z:4];
    
    if (_lives <= 0)
    {
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
}
- (void)addPoint
{
    score = score + 100; // score++; will also work.
    [scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *projectile = [CCSprite spriteWithFile:@"NinjaShuriken.png"];
    projectile.position = ccp(20, winSize.height/2);
    
    // Determine offset of location to projectile
    CGPoint offset = ccpSub(location, projectile.position);
    
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
    int realX = winSize.width + (projectile.contentSize.width/2);
    float ratio = (float) offset.y / (float) offset.x;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far you're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Move projectile to actual endpoint
    [projectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         // CCCallBlockN in ccTouchesEnded
         [_projectiles removeObject:node];
         [node removeFromParentAndCleanup:YES];
     }],
      nil]];
    
    projectile.tag = 2;
    [_projectiles addObject:projectile];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"Thrown_Shuriken-Cody_Mahan-1151015923.mp3"];
}

- (void)update:(ccTime)dt {
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *monster in _monsters) {
            
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (CCSprite *monster in monstersToDelete) {
            [_monsters removeObject:monster];
            [self removeChild:monster cleanup:YES];
            // Subtract a life from Speed Ninja
            if (sprite == _monsters)
            {
                [self subtractLife];
            }

            [self addPoint]; 
            
            _monstersDestroyed++;
            if (_monstersDestroyed > 20) {
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        
        if (monstersToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
        [monstersToDelete release];
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_monsters release];
    _monsters = nil;
    [_projectiles release];
    _projectiles = nil;
    [super dealloc];
}

@end
