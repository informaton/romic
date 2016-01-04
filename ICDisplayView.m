//
//  ICDisplayView.m
//  HP3577A_mac_gui
//
//  Created by Hyatt Moore IV
//  Copyright 2016 Informaton. All rights reserved.
//

#import "ICDisplayView.h"


@implementation ICDisplayView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
//		[[NSColor whiteColor] set];
		[self setItemPropertiesToDefault:self];
    }
    return self;
}

- (void)awakeFromNib {
//	[self setItemPropertiesToDefault:self];

}
- (void)setItemPropertiesToDefault:(id)sender
{
	[[NSColor greenColor] setStroke];
	NSFrameRect([self frame]);


}

- (void)drawBackground
{
	
	[[NSColor greenColor] setStroke];
	NSFrameRect([self frame]);
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	
	[super drawRect:dirtyRect];
	
	// This next line sets the the current fill color parameter of the Graphics Context
	// You might want to use _bounds or self.bounds if you want to be sure to fill the entire bounds rect of the view. 	
	//[[NSColor whiteColor] setFill];
	// This next function fills a rect the same as dirtyRect with the current fill color of the Graphics Context.
    //NSRectFill(dirtyRect);
	
	// ********** Your drawing code here ********** // 2
	[[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
	
    [self drawTrace];

}

- (void) drawTrace {
	
	[[NSColor yellowColor] setStroke];
	NSRect theframe = [self bounds];
//	NSRect thebounds = [self bounds];
	float width = theframe.size.width;
	float height = theframe.size.height;
	
	NSBezierPath* aPath = [NSBezierPath bezierPath];
	[aPath setLineWidth:1.0];
	[aPath moveToPoint:NSMakePoint(theframe.origin.x, theframe.origin.y)];
	float num_samples = 401;
	for(float x=theframe.origin.x, y=theframe.origin.y+height/2;x<width;x+=width/num_samples, y+=sin(pi*2* x) ) // height/num_samples)
	{
		[aPath lineToPoint:NSMakePoint(x , y )];
	}
	[aPath stroke];
}


@end
