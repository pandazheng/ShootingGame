//
//  GameScene.m
//  ShootingGame
//
//  Created by KazukiKubo on 2013/02/19.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Item.h"
#import "ParallelPattern.h"
#import "NormalPattern.h"
#import "ThreeWayPattern.h"


@implementation GameScene

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init {
    if (self = [super initWithColor:ccc4(255,255,255,255)]) {
        _items = [NSMutableArray new];
        _bullets = [NSMutableArray new];
        // player関連を持つlayer
        _playerLayer = [[PlayerLayer alloc] init];
        [self addChild:_playerLayer z:0];
        // item関連を持つlayer
        _itemLayer = [[ItemLayer alloc] init];
        [self addChild:_itemLayer z:1];
        // 敵関連を持つlayer
        _enemyLayer = [[EnemyLayer alloc] init];
        [self addChild:_enemyLayer z:2];
        // ユーザーの操作を受けるlayer
        _gamePadLayer = [[GamePadLayer alloc] init];
        [self addChild:_gamePadLayer z:3];

        [self schedule:@selector(update:)];
    }
    return self;
}

// プレイヤーをtouchした位置に移動させる(runActionを使わないバージョン)
-(void)movePlayer {
    // 長さ1に正規化されたベクトル
    CGPoint v = ccpNormalize(ccpSub(_gamePadLayer.touchLocation, _playerLayer.player.position));
    _playerLayer.player.position = ccpAdd(v, _playerLayer.player.position);
}

// 今のところ当たり判定君, @param dt : 1/60sec
-(void)update:(ccTime)dt {
    if (_gamePadLayer.isTouches) {
        [self movePlayer];
    }
    
    NSMutableArray *itemsToDelete = [NSMutableArray new];
    Player *player = _playerLayer.player;
    
    CGRect playerRect = CGRectMake(player.position.x - (player.contentSize.width/2), player.position.y - (player.contentSize.height/2), player.contentSize.width, player.contentSize.height);
    
    // TODO: 同じような制御構文(当たり判定)
    for (Item *item in _itemLayer.items) {
        CGRect itemRect = CGRectMake(item.position.x - (item.contentSize.width/2), item.position.y - (item.contentSize.height/2), item.contentSize.width, item.contentSize.height);
        if (CGRectIntersectsRect(playerRect, itemRect)) { // itemとplayerが接触した。
            [itemsToDelete addObject:item];
            // playerの状態を変化させる。
            [self changeBulletPattern:item.type];
        }
    }

    // 敵と弾の当たり判定
    for (CCSprite *enemy in _enemyLayer.enemies) {
        CGRect enemyRect = CGRectMake(enemy.position.x - (enemy.contentSize.width/2), enemy.position.y - (enemy.contentSize.height/2), enemy.contentSize.width, enemy.contentSize.height);
        for (CCSprite *bullet in _playerLayer.bullets) {
            CGRect bulletRect = CGRectMake(bullet.position.x - (bullet.contentSize.width/2), bullet.position.y - (bullet.contentSize.height/2), bullet.contentSize.width, bullet.contentSize.height);
            if (CGRectIntersectsRect(enemyRect, bulletRect)) {
                [itemsToDelete addObject:enemy];
                [itemsToDelete addObject:bullet];
            }
        }
    }
    
    // TODO: 同じような制御構文(削除方法)
    for (CCSprite *item in itemsToDelete) {
        [_itemLayer.items removeObject:item];
        [_itemLayer removeChild:item cleanup:YES];
    }
    
    for (CCSprite *enemy in itemsToDelete) {
        [_enemyLayer.enemies removeObject:enemy];
        [_enemyLayer removeChild:enemy cleanup:YES];
    }
    
    for (CCSprite *bullet in itemsToDelete) {
        [_playerLayer.bullets removeObject:bullet];
        [_playerLayer removeChild:bullet cleanup:YES];
    }
}

-(void)changeBulletPattern:(ItemType)itemType {
    switch (itemType) {
        case ItemTypeParallel:
            [_playerLayer setBulletPattern:[ParallelPattern new]];
            break;
        case ItemTypeNormal:
            [_playerLayer setBulletPattern:[NormalPattern new]];
            break;
        case ItemTypeThreeWay:
            [_playerLayer setBulletPattern:[ThreeWayPattern new]];
        default:
            break;
    }
}

@end
