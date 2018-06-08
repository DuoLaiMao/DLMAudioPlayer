//
//  DLMAudioPlayer.h
//  DLMAudioPlayer
//
//  Created by YangJian on 2018/6/7.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class DLMAudioPlayer;
@protocol DLMAudioPlayerProtocol <NSObject>

- (void)startPlayWithAudioPlayer:(DLMAudioPlayer *)player;

- (void)playFinishWithAudioPlayer:(DLMAudioPlayer *)player;

- (void)playFailedWithAudioPlayer:(DLMAudioPlayer *)player;

@end

@interface DLMAudioPlayer : NSObject

+ (instancetype)audioPlayer;

@property (strong, nonatomic, readonly) AVPlayer *player;

@property (assign, nonatomic, readonly) NSTimeInterval currentTime;

@property (strong, nonatomic) NSString *contentUrl;

@property (assign, nonatomic) id<DLMAudioPlayerProtocol> delegate;

- (void)play;

- (void)pause;

//- (void)stop;

- (BOOL)isPlaying;

@end
