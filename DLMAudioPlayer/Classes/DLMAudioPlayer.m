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

@end

@implementation DLMAudioPlayer

- (void)dealloc
{
    [_player removeTimeObserver:self];
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
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

//- (void)stop
//{
//    [self.player pause];
//    [self setContentUrl:_contentUrl];
//}

- (BOOL)isPlaying
{
    return false;
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
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            __strong typeof(weakself) self = weakself;
            self.currentTime = CMTimeGetSeconds(time);
            if (self.player.rate == 1.0) {
                [self playStart];
            }
        }];

    }
    return _player;
}

@end
