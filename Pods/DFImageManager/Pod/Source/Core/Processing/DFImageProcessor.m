// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DFImageProcessor.h"
#import "DFImageRequest.h"
#import "DFImageRequestOptions.h"
#import "UIImage+DFImageUtilities.h"

#if __has_include("DFImageManagerKit+GIF.h")
#import "DFImageManagerKit+GIF.h"
#endif

NSString *DFImageProcessingCornerRadiusKey = @"DFImageProcessingCornerRadiusKey";

@implementation DFImageProcessor

- (instancetype)init {
    if (self = [super init]) {
        _shouldDecompressImages = YES;
    }
    return self;
}

#pragma mark <DFImageProcessing>

- (BOOL)isProcessingForRequestEquivalent:(nonnull DFImageRequest *)request1 toRequest:(nonnull DFImageRequest *)request2 {
    if (request1 == request2) {
        return YES;
    }
    if (!(CGSizeEqualToSize(request1.targetSize, request2.targetSize) &&
          request1.contentMode == request2.contentMode &&
          request1.options.allowsClipping == request2.options.allowsClipping)) {
        return NO;
    }
    NSNumber *cornerRadius1 = request1.options.userInfo[DFImageProcessingCornerRadiusKey];
    NSNumber *cornerRadius2 = request2.options.userInfo[DFImageProcessingCornerRadiusKey];
    return (!cornerRadius1 && !cornerRadius2) || ((!!cornerRadius1 && !!cornerRadius2) && [cornerRadius1 isEqualToNumber:cornerRadius2]);
}

- (BOOL)shouldProcessImage:(nonnull UIImage *)image forRequest:(nonnull DFImageRequest *)request partial:(BOOL)partial {
#if __has_include("DFImageManagerKit+GIF.h")
    if ([image isKindOfClass:[DFAnimatedImage class]]) {
        return NO;
    }
#endif
    return YES;
}

- (nullable UIImage *)processedImage:(nonnull UIImage *)image forRequest:(nonnull DFImageRequest *)request partial:(BOOL)partial {
    if (![self shouldProcessImage:image forRequest:request partial:partial]) {
        return image;
    }
    if (request.contentMode == DFImageContentModeAspectFill && request.options.allowsClipping) {
        image = [DFImageProcessor _croppedImage:image aspectFillPixelSize:request.targetSize];
    }
    CGFloat scale = [UIImage df_scaleForImage:image targetSize:request.targetSize contentMode:request.contentMode];
    if (scale < 1.f || self.shouldDecompressImages) {
        image = [UIImage df_decompressedImage:image scale:scale];
    }
    NSNumber *normalizedCornerRadius = request.options.userInfo[DFImageProcessingCornerRadiusKey];
    if (normalizedCornerRadius) {
        CGFloat cornerRadius = normalizedCornerRadius.floatValue * MIN(image.size.width, image.size.height);
        image = [UIImage df_imageWithImage:image cornerRadius:cornerRadius];
    }
    return image;
}

+ (nullable UIImage *)_croppedImage:(nonnull UIImage *)image aspectFillPixelSize:(CGSize)targetSize {
    CGSize scaledSize = ({
        CGFloat scale = [UIImage df_scaleForImage:image targetSize:targetSize contentMode:DFImageContentModeAspectFill];
        CGSizeMake(CGImageGetWidth(image.CGImage) * scale, CGImageGetHeight(image.CGImage) * scale);
    });
    CGRect cropRect = CGRectMake((scaledSize.width - targetSize.width) / 2.f, (scaledSize.height - targetSize.height) / 2.f, targetSize.width, targetSize.height);
    CGRect normalizedCropRect = CGRectMake(cropRect.origin.x / scaledSize.width, cropRect.origin.y / scaledSize.height, cropRect.size.width / scaledSize.width, cropRect.size.height / scaledSize.height);
    return [UIImage df_croppedImage:image normalizedCropRect:normalizedCropRect];
}

@end
