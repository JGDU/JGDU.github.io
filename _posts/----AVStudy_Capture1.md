---
layout:     post
title:     AV秘籍-捕捉媒体1
author:     haolj
summary:    .
categories: objc
thumbnail: heart
tags:
 - AVFoundation
 - 视频捕捉
---



### AVFoundation 捕捉类介绍

1.  捕捉会话 - AVCaptureSession
2. 捕捉设备 - AVCaptureDevice
3. 捕捉设备的输入 - AVCaptureDeviceInput
4. 捕捉设备的输出 - AVCaptureOutput
5. 捕捉连接 - AVCaptureConnection
6. 捕捉预览 - AVCaptureVideoPreviewLayer

	呈现层 预览当前设置的session捕捉的内容,
	
{% highlight  objc %}
	
	    self.captureSession = [[AVCaptureSession alloc]init];

	
	 ///这设置会话的预设值 (用来控制会话的质量和格式)
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //////---------------------------添加video input -------
    ///设置默认的视频捕捉设备 (默认返回后置摄像头)
    AVCaptureDevice  * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    ///获取一个input
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    
    if (videoInput) {
        ///查看input是否可以添加会话中
        if([self.captureSession canAddInput:videoInput])
        {
            [self.captureSession addInput:videoInput];
        }
        
    }else
    {
        return NO;
    }
    
    
    //////---------------------------添加audio input -------
    //获取音频捕捉设备
    AVCaptureDevice * audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    
    if (audioDevice) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
            self.activeVideoInput= videoInput;
        }
    }else
    {
        return NO;
    }
    
    //设置 图片的AVCapture OutPut
    self.imageOutput= [[AVCaptureStillImageOutput alloc]init];
    self.imageOutput . outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};;
    
    
    
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    ///添加 视频的out put
    self.movieOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    

{% endhighlight %}


↑↑↑↑↑↑↑↑↑↑↑↑创建一个session 以及设置了输入输出




{% highlight  objc %}

    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
    
	-(void)stopSession {

    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
    }

{% endhighlight %}



↑↑↑↑↑↑↑↑↑↑↑↑开始和停止一个session


{% highlight  objc %}

	+ (Class)layerClass {
    // Listing 6.2
    return [AVCaptureVideoPreviewLayer class];
	}

	- (AVCaptureSession*)session {
    // Listing 6.2
    return [(AVCaptureVideoPreviewLayer*)self.layer session];
	}

	- (void)setSession:(AVCaptureSession *)session {
    // Listing 6.2    
    [(AVCaptureVideoPreviewLayer*)self.layer setSession:session];
	}

{% endhighlight %}

↑↑↑↑↑↑↑↑↑↑↑↑设置设置view 的layer为AVCaptureVideoPreviewLayer  并且设置AVCaptureVideoPreviewLayer的session


此时,已经可以看到在手机屏幕上看到摄像头捕获的内容.

###切换摄像头

{% highlight  objc %}


typedef NS_ENUM(NSInteger, AVCaptureDevicePosition) {
	AVCaptureDevicePositionUnspecified         = 0,
	AVCaptureDevicePositionBack                = 1,
	AVCaptureDevicePositionFront               = 2
} NS_AVAILABLE(10_7, 4_0) __TVOS_PROHIBITED;



- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {

    
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice * device  in devices) {
        if (device.position == position) {
            return device;
        }
    }
    
    return nil;
}

{% endhighlight %}


↑↑↑ 获取对应位置的摄像头


{% highlight  objc %}


///获取当前活动的摄像头
- (AVCaptureDevice *)activeCamera {
    return  self.activeVideoInput.device;
}


///获取非活跃的摄像头
- (AVCaptureDevice *)inactiveCamera {

    AVCaptureDevice * device = nil;
    
    if (self.cameraCount>1) {
     
        if ([self activeCamera].position == AVCaptureDevicePositionFront) {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }else
        {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        
    }

}

- (BOOL)canSwitchCameras {

    // Listing 6.6
    
    return self.cameraCount>1;
}



/////获取摄像头个数
- (NSUInteger)cameraCount {
    
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

///切换摄像头
- (BOOL)switchCameras {
    
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError * error;
    
    ///获取非活跃设备
    AVCaptureDevice * videoDevice = [self inactiveCamera];
    
    ///获取非活跃设备的 输入对象
    AVCaptureDeviceInput * videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        ///1. 开始配置
        [self.captureSession beginConfiguration];
        //2. 移除之前的Video
        [self.captureSession removeInput:self.activeVideoInput];
        //3. 添加新的video
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput  = videoInput;
        } else
        {
            //4.避免错误添加之前的input进去
            [self.captureSession addInput:self.activeVideoInput];
        }
        //5. 提交配置
        [self.captureSession commitConfiguration];
    }else
    {
        ///错误处理
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    
    
    return YES;
}


{% endhighlight %}


至此反转摄像头功能完成


{% highlight  objc %}

#pragma mark - Focus Methods

///是否支持点击对焦
- (BOOL)cameraSupportsTapToFocus {
    
    return [[self activeCamera] isFocusPointOfInterestSupported];
    
}

- (void)focusAtPoint:(CGPoint)point {
    
    AVCaptureDevice * device = [self activeCamera];
    
    ///当前支持兴趣点对焦 并且当前为自动
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError * error;
       
        if ([device lockForConfiguration:&error]) {
            //设置兴趣点
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }else
        {
            [self.delegate deviceConfigurationFailedWithError:error];
        }

    }
    

}


{% endhighlight %}



