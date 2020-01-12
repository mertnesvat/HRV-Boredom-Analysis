#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PulseDetector.h"
#import "Filter.h"

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AnalysisDelegate>{
    BOOL showText;
}
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureDevice *camera;
@property(nonatomic, strong) PulseDetector *pulseDetector;
@property(nonatomic, strong) Filter *filter;
@property(nonatomic, assign) CURRENT_STATE currentState;
@property(nonatomic, assign) int validFrameCounter;

@property (nonatomic, strong) UILabel * PulseRate;
@property (nonatomic, strong) UILabel * ValidFrames;
@property (nonatomic, strong) UILabel * analyzing;
@property (nonatomic, strong) UIProgressView * progress;

@end

@implementation ViewController

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resume];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.PulseRate = [[UILabel alloc]initWithFrame:(CGRect){0,0,self.view.frame.size.width,200}];
    [self.PulseRate setNumberOfLines:0];
    self.PulseRate.backgroundColor = [UIColor systemBlueColor];
    self.PulseRate.textAlignment = 1;
    self.PulseRate.textColor = [UIColor whiteColor];
    [self.view addSubview:self.PulseRate];
    
    self.ValidFrames = [[UILabel alloc]initWithFrame:(CGRect){0,self.PulseRate.frame.origin.y+self.PulseRate.frame.size.height,self.view.frame.size.width,100}];
    self.ValidFrames.backgroundColor = [UIColor lightGrayColor];
    self.ValidFrames.textColor = [UIColor blackColor];
    self.ValidFrames.textAlignment = 1;
    self.ValidFrames.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:self.ValidFrames];
    
    self.analyzing = [[UILabel alloc]initWithFrame:(CGRect){0,self.ValidFrames.frame.origin.y+self.ValidFrames.frame.size.height,self.view.frame.size.width,100}];
    self.analyzing.backgroundColor = [UIColor grayColor];
    self.analyzing.textColor = [UIColor blackColor];
    self.analyzing.textAlignment = 1;
    self.analyzing.font = [UIFont boldSystemFontOfSize:20];
    self.analyzing.text = @"Analyzing... Please wait until progress bar finishes!";
    [self.analyzing setNumberOfLines:0];
    [self.view addSubview:self.analyzing];
    
    self.progress = [[UIProgressView alloc] initWithFrame:(CGRect){0,self.analyzing.frame.origin.y+(self.analyzing.frame.size.height),self.view.frame.size.width,100}];
    self.progress.backgroundColor = [UIColor lightGrayColor];
    self.progress.progressTintColor = [UIColor blackColor];
    [self.view addSubview:self.progress];
    


    self.filter = [[Filter alloc]init];
    
    self.pulseDetector = [[PulseDetector alloc]init];
    self.pulseDetector.delegate = self;
    
    [self.view setBackgroundColor:UIColor.whiteColor];
    
    [self startCameraCapture];

}

// Start capturing frames
- (void) startCameraCapture {
    
    //Create AVCapture
    self.session = [[AVCaptureSession alloc] init];
    
    //Get the default camera device
    self.camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //Turn on the flashlight mode-without it the pulse cannot be detected
    if([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.camera lockForConfiguration:nil];
        self.camera.torchMode=AVCaptureTorchModeOn;
        [self.camera unlockForConfiguration];
    }
    
    //Create an AVCaptureInput camera device
    NSError *error=nil;
    AVCaptureInput* cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.camera error:&error];
    if (cameraInput == nil) {
        NSLog(@"Error to create camera capture:%@",error);
    }
    
    //Set output
    AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    //Create a queue to run captures
    dispatch_queue_t captureQueue=dispatch_queue_create("captureQueue", NULL);
    
    //Set up your own capture delegate
    [videoOutput setSampleBufferDelegate:self queue:captureQueue];
    
    //Configured pixel format
    videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey, nil];
    
    //Frame size-use the smallest frame (size available) 188x144
    [self.session setSessionPreset:AVCaptureSessionPresetLow];
    
    //Adding inputs and outputs
    [self.session addInput:cameraInput];
    [self.session addOutput:videoOutput];
    
    //Start Up
    [self.session startRunning];
    [self torchModeOn];
    
    //Camera status
    self.currentState=STATE_SAMPLING;
    
    //Stop the program
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //Timer executes every 0.1 seconds to update the UI
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];

}

-(void) stopCameraCapture {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pause];
        [self.session stopRunning];
        self.session=nil;
        [self dismissViewControllerAnimated:true completion:nil];
    });
}

#pragma mark Pause and Resume of pulse detection
-(void) pause {
    if(self.currentState==STATE_PAUSED) return;
    
    //Turn off the flash
    if([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.camera lockForConfiguration:nil];
        self.camera.torchMode=AVCaptureTorchModeOff;
        [self.camera unlockForConfiguration];
    }
    self.currentState=STATE_PAUSED;
    
    //Program shut down or exit background
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void) resume {
    if(self.currentState!=STATE_PAUSED) return;
    
    //Turn off the flash
    if([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.camera lockForConfiguration:nil];
        self.camera.torchMode=AVCaptureTorchModeOn;
        [self.camera unlockForConfiguration];
    }
    self.currentState=STATE_SAMPLING;
    
    //Program shut down or exit background
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void) torchModeOn {
    if([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.camera lockForConfiguration:nil];
        self.camera.torchMode=AVCaptureTorchModeOn;
        [self.camera unlockForConfiguration];
    }
}

//Calculate the HUE from RGB
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN(g, b ));
    max = MAX( r, MAX(g, b ));
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        // r = g = b = 0
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h=2+(b-r)/delta;
    else
        *h=4+(r-g)/delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}

//Processing frames of video
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //Judge to stop and not to do anything
    if(self.currentState==STATE_PAUSED) {
        
        //Reset our frame counter
        self.validFrameCounter=0;
        return;
    }
    //Determine the value of blood fluctuations
    if (self.validFrameCounter == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Callback or notify the main thread to refresh，
            self.PulseRate.font = [UIFont boldSystemFontOfSize:23];
            self.PulseRate.text=@"Keep your finger on the flash!";
        });
    } else {
        /*Obtained data (can be used to display progress bar or ECG) */
        // NSLog(@"int:%d",self.validFrameCounter);
        
        if (!showText) {
            //Notify the main thread to refresh
            dispatch_async(dispatch_get_main_queue(), ^{
                //Callback or notify the main thread to refresh，
                self.PulseRate.font = [UIFont boldSystemFontOfSize:20];
                self.PulseRate.text = @"Put your finger gently to the Camera with covering Flash!";
            });
        }
    }

    //Image buffer
    CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //Lock image buffer
    CVPixelBufferLockBaseAddress(cvimgRef,0);
    
    //Access data
    size_t width=CVPixelBufferGetWidth(cvimgRef);
    
    size_t height=CVPixelBufferGetHeight(cvimgRef);
    
    //Get image bytes
    uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
    
    size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
    
    //Rgb value of average frame
    float r=0,g=0,b=0;
    for(int y=0; y<height; y++) {
        for(int x=0; x<width*4; x+=4) {
            b+=buf[x];
            g+=buf[x+1];
            r+=buf[x+2];
        }
        buf+=bprow;
    }
    r/=255*(float) (width*height);
    g/=255*(float) (width*height);
    b/=255*(float) (width*height);
    
    //Convert from rgb to hsv colourspace
    float h,s,v;
    
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    //Do a check and see if a finger is placed on the camera
    if(s>0.5 && v>0.5) {
        
        //Increase the number of valid frames
        self.validFrameCounter++;
        
        //Filter tone value, the filter is a simple bandpass filter that removes any DC components and high frequency
        float filtered=[self.filter processValue:h];
        
        
        if(self.validFrameCounter > MIN_FRAMES_FOR_FILTER_TO_SETTLE) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self progress] setProgress:20/(float)self.validFrameCounter];
            });
            //Add new value to pulse detector
            [self.pulseDetector addNewValue:filtered atTime:CACurrentMediaTime()];
        }
    } else {
        self.validFrameCounter = 0;
        
        //Clear pulse detector-we only need to do this once
        [self.pulseDetector reset];
    }
}

-(void) update {
    
    NSInteger distance =  MIN(100, (100 * self.validFrameCounter)/MIN_FRAMES_FOR_FILTER_TO_SETTLE);
    
    //Distance equal to 100 display loading
    if (distance == 100) showText = NO;
    
    self.ValidFrames.text = [NSString stringWithFormat:@"Frames are added: %ld%%",distance];
    
    //If we stop then there is nothing to do
    if(self.currentState==STATE_PAUSED) return;
    
    //Pulse repetition rate pulse detector with average period obtained
    float avePeriod=[self.pulseDetector getAverage];
    
    
    //Resulting value (post-processing)
//    NSLog(@"avePeriod:%f",avePeriod);
    
    if(avePeriod==INVALID_PULSE_PERIOD) {
        
        //No value available. No processing for now. May be used later.

        
    } else {
        
        showText = YES;//Heart bar appears showing heart rate value
        
        //Show value
        float pulse=60.0/avePeriod;
   
        dispatch_async(dispatch_get_main_queue(), ^{
            //Callback or notify the main thread to refresh，
            self.PulseRate.font = [UIFont boldSystemFontOfSize:60];
            self.PulseRate.text=[NSString stringWithFormat:@"%0.0f", pulse];
        });
        
    }
}

-(void)periodsReady:(NSArray *) periods {
    
    [[self delegate] sendPeriods:periods];
    
//    HRVUtils *utils = [[HRVUtils alloc] init];
//
//    double rmmsd = [utils calcRMSSD:periods];
//    double avnn = [utils calcAVNN:periods];
//    double sdnn = [utils calcSDNN:periods];
//    double pnn = [utils calcPNN50:periods];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.rmmsd.text = [NSString stringWithFormat:@"%.2f | %.2f | %.2f| %.2f",rmmsd,avnn,sdnn, pnn];
//    });
//
}

@end
