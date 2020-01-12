#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, CURRENT_STATE) {
    STATE_PAUSED,
    STATE_SAMPLING
};

@protocol PeriodProtocols <NSObject>
-(void) sendPeriods:(NSArray *) periods;
@end

#define MIN_FRAMES_FOR_FILTER_TO_SETTLE 10
@interface ViewController : UIViewController
@property(assign) id<PeriodProtocols> delegate;
-(void) stopCameraCapture;

@end

