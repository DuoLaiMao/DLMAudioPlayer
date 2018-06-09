//
//  DLMAudioPlayer.m
//  DLMAudioPlayer
//
//  Created by YangJian on 2018/6/7.
//

#import "DLMAudioPlayer.h"

@interface DLMAudioPlayer ()
@property (strong, nonatomic, readwrite) AVPlayer *player;
@property (assign, nonatomic, readwrite) NSTimeInterval currentTime;
@property (assign, nonatomic) id playerObserver;

@end

@implementation DLMAudioPlayer

- (void)dealloc
{
    [_player removeTimeObserver:self.playerObserver];
    [_player removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)audioPlayer
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        //播放完成
        [center addObserver:self selector:@selector(playFinish:)
                       name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        //播放出错
        [center addObserver:self selector:@selector(playError:)
                       name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    }
    
    return self;
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isEqual:self.player] && [keyPath isEqualToString:@"status"]) {
        NSNumber *status = [change valueForKey:NSKeyValueChangeNewKey];
        switch (status.integerValue) {
            case AVPlayerStatusUnknown:{
                break;
            }
            case AVPlayerStatusReadyToPlay:{
                break;
            }
            case AVPlayerStatusFailed: {
                [self playError:nil];
                break;
            }
            default:
                break;
        }
    }
}

- (void)playStart
{
    if ([self.delegate respondsToSelector:@selector(startPlayWithAudioPlayer)]) {
        [self.delegate startPlayWithAudioPlayer:self];
    }
}

- (void)playFinish:(NSNotification *)noti
{
    if ([self.delegate respondsToSelector:@selector(playFinishWithAudioPlayer:)]) {
        [self.delegate playFinishWithAudioPlayer:self];
    }
}

- (void)playError:(NSNotification *)noti
{
    if ([self.delegate respondsToSelector:@selector(playFailedWithAudioPlayer:)]) {
        [self.delegate playFailedWithAudioPlayer:self];
    }
}

#pragma mark -
- (void)setContentUrl:(NSString *)contentUrl
{
    _contentUrl = [contentUrl copy];

    NSURL *url = [NSURL URLWithString:contentUrl];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:item];
}

- (void)play
{
    self.currentTime = 0.f;
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (BOOL)isPlaying
{
    if ([self.player respondsToSelector:@selector(timeControlStatus)]) {
        return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying ? true : false;
    } else {
        if (self.player.rate == 0.0) {
            return false;
        } else {
            return true;
        }
    }
}

#pragma mark -
- (AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        //监听状态
        [_player addObserver:self forKeyPath:@"status"
                     options:NSKeyValueObservingOptionNew context:nil];
        
        __weak typeof(self) weakself = self;
        self.playerObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            __strong typeof(weakself) self = weakself;
            self.currentTime = CMTimeGetSeconds(time);
            NSLog(@"currentTime:%.2f", self.currentTime);
        }];
    }
    return _player;
}

@end
