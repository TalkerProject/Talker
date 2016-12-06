//
//  TVIVideoFrame.h
//  TwilioVideo
//
//  Copyright © 2016 Twilio Inc. All rights reserved.
//

#import <CoreVideo/CoreVideo.h>

#import "TVII420Frame.h"

/**
 *  Represents a video frame provided by a `TVICameraCapturer`.
 */
typedef struct TVIVideoFrame {
    /**
     *  @brief The timestamp in nanoseconds at which this frame was captured.
     */
    int64_t             timestamp;
    /**
     *  @brief A CVImageBuffer which contains the image data for the frame.
     */
    CVImageBufferRef    imageBuffer;
    /**
     *  @brief The orientation metadata for the frame.
     */
    TVIVideoOrientation orientation;
} TVIVideoFrame;

