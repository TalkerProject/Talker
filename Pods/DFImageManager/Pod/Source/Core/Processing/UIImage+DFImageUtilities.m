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

#import "UIImage+DFImageUtilities.h"

@implementation UIImage (DFImageUtilities)

+ (CGFloat)df_scaleForImage:(nullable UIImage *)image targetSize:(CGSize)targetSize contentMode:(DFImageContentMode)contentMode {
    CGSize bitmapSize = CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
    CGFloat scaleWidth = targetSize.width / bitmapSize.width;
    CGFloat scaleHeight = targetSize.height / bitmapSize.height;
    return (contentMode == DFImageContentModeAspectFill) ? MAX(scaleWidth, scaleHeight) : MIN(scaleWidth, scaleHeight);
}

+ (UIImage *)df_decompressedImage:(UIImage *)image scale:(CGFloat)scale {
    if (!image) {
        return nil;
    }
    if (image.images) {
        return image;
    }
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    if (scale < 1.f) {
        imageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    }

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, (size_t)imageSize.width, (size_t)imageSize.height, CGImageGetBitsPerComponent(imageRef), 0, colorSpaceRef, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst));
    if (colorSpaceRef) {
        CGColorSpaceRelease(colorSpaceRef);
    }
    if (!contextRef) {
        return image;
    }
    
    CGContextDrawImage(contextRef, (CGRect){CGPointZero, imageSize}, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    if (decompressedImageRef) {
        CGImageRelease(decompressedImageRef);
    }
    return decompressedImage;
}

+ (UIImage *)df_croppedImage:(UIImage *)image normalizedCropRect:(CGRect)cropRect {
    CGSize imageSize = CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
    CGRect imageCropRect = CGRectMake((CGFloat)floor(cropRect.origin.x * imageSize.width),
                                      (CGFloat)floor(cropRect.origin.y * imageSize.height),
                                      (CGFloat)floor(cropRect.size.width * imageSize.width),
                                      (CGFloat)floor(cropRect.size.height * imageSize.height));
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], imageCropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef scale:image.scale orientation:image.imageOrientation];
    if (croppedImageRef) {
        CGImageRelease(croppedImageRef);
    }
    return croppedImage;
}

+ (UIImage *)df_imageWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    [[UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, image.size} cornerRadius:cornerRadius] addClip];
    [image drawInRect:(CGRect){CGPointZero, image.size}];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return processedImage;
}

@end
