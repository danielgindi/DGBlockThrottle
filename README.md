DGBlockThrottle
===============

A little utility to throttle calls to a block in ObjC. This is great for many uses, one of the most common is handling progress of a `NSURLConnection` request. Because you may receive many calls for new bytes, and may want to make sure you only call the progress delegate/block once every 150ms or so.

Simply call it like this:

```objc
    void (^myThrottledBlock) = 
        [DGBlockThrottle throttledBlock: myCodeBlock
                                onQueue: dispatch_get_main_queue()
                                   wait: 0.3
                                leading: NO
                               trailing: YES];
    
    // Now we can call `myThrottledBlock()` many times, and `myCodeBlock` will only be called once every 300 ms!
```

Arguments:

* `throttledBlock` is obviously the block that you want to throttle. The only kind of block accepted is a `void` returning, no-arguments block.
* `wait` is the amount of time (in seconds) to wait between calls to your block.
* `leading` means whether you want the first call to the throttle block to execute your block or not. This allows 
* `trailing` means whether you want to have another call to your block issued after you have stopped calling the throttled block.

If you call the override of `[DGBlockThrottle throttledBlock:onQueue:wait:]` then the default is `leading: NO` and `trailing: YES`

## Me
* Hi! I am Daniel Cohen Gindi. Or in short- Daniel.
* danielgindi@gmail.com is my email address.
* That's all you need to know.

## Help

If you like what you see here, and want to support the work being done in this repository, you could:
* Actually code, and issue pull requests
* Spread the word
* 
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CHRDHZE79YTMQ)

## License

All the code here is under MIT license. Which means you could do virtually anything with the code.
I will appreciate it very much if you keep an attribution where appropriate.

    The MIT License (MIT)
    
    Copyright (c) 2013 Daniel Cohen Gindi (danielgindi@gmail.com)
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
