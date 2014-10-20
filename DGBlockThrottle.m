//
//  DGBlockThrottle.m
//  DGBlockThrottle
//
//  Created by Daniel Cohen Gindi on 10/20/14.
//  Copyright (c) 2014 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/DGBlockThrottle
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DGBlockThrottle.h"

@implementation DGBlockThrottle

+ (void(^)())throttledBlock:(void (^)())block
                    onQueue:(dispatch_queue_t)queue
                       wait:(CFTimeInterval)wait
{
    return [self throttledBlock:block onQueue:queue wait:wait leading:NO trailing:YES];
}

+ (void(^)())throttledBlock:(void (^)())block
                    onQueue:(dispatch_queue_t)queue
                       wait:(CFTimeInterval)wait
                    leading:(BOOL)hasLeadingCall
{
    return [self throttledBlock:block onQueue:queue wait:wait leading:hasLeadingCall trailing:YES];
}

+ (void(^)())throttledBlock:(void (^)())block
                    onQueue:(dispatch_queue_t)queue
                       wait:(CFTimeInterval)wait
                   trailing:(BOOL)hasTrailingCall
{
    return [self throttledBlock:block onQueue:queue wait:wait leading:NO trailing:hasTrailingCall];
}

+ (void(^)())throttledBlock:(void (^)())block
                    onQueue:(dispatch_queue_t)queue
                       wait:(CFTimeInterval)wait
                    leading:(BOOL)hasLeadingCall
                   trailing:(BOOL)hasTrailingCall
{
    if (block)
    {
        __block NSTimeInterval previous = 0.0;
        __block dispatch_source_t dSource = nil;
        
        void (^trailingBlock)() = ^{
            
            previous = !hasLeadingCall ? 0.0 : [NSDate timeIntervalSinceReferenceDate];
            
            if (dSource)
            {
                // Cancel trailing call as we are calling the block again
                dispatch_source_cancel(dSource);
                dSource = nil;
            }
            
            // Call block
            dispatch_async(queue, block);
            
        };
        
        void (^throttled)() = ^{
            
            NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
            if (!previous && !hasLeadingCall)
            {
                previous = now;
            }
            
            NSTimeInterval remaining = wait - (now - previous);
            if (remaining <= 0.0 || remaining > wait)
            {
                if (dSource)
                {
                    // Cancel trailing call as we are calling the block again
                    dispatch_source_cancel(dSource);
                    dSource = nil;
                }
                
                // Set the last call time to now
                previous = now;
                
                // Call block
                dispatch_async(queue, block);
            }
            
            // Now check if we need a trailing call and we haven't scheduled it yet
            else if (!dSource && hasTrailingCall)
            {
                dSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                // timeout = setTimeout(trailingBlock, remaining);
                
                dispatch_source_set_timer(dSource, dispatch_time(DISPATCH_TIME_NOW, remaining * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
                dispatch_source_set_event_handler(dSource, trailingBlock);
                dispatch_resume(dSource);
            }
            
        };
        
        return throttled;
    }
    else
    {
        return ^{};
    }
}

@end
