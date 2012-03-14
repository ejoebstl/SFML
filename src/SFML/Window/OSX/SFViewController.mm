////////////////////////////////////////////////////////////
//
// SFML - Simple and Fast Multimedia Library
// Copyright (C) 2007-2012 Marco Antognini (antognini.marco@gmail.com), 
//                         Laurent Gomila (laurent.gom@gmail.com), 
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it freely,
// subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented;
//    you must not claim that you wrote the original software.
//    If you use this software in a product, an acknowledgment
//    in the product documentation would be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such,
//    and must not be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source distribution.
//
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////
#import <SFML/Window/OSX/SFViewController.h>
#import <SFML/Window/OSX/SFOpenGLView.h>
#include <SFML/System/Err.hpp>
#include <SFML/Window/OSX/WindowImplCocoa.hpp>

@implementation SFViewController


////////////////////////////////////////////////////////
-(id)initWithView:(NSView *)view
{
    if ((self = [super init])) {
        m_requester = 0;
        
        // Retain the view for our own use.
        m_view = [view retain];
        
        if (m_view == nil) {
            
            sf::err() 
            << "No view was given to initWithWindow:."
            << std::endl;
            
            return self;
        }
        
        // Create the view.
        NSRect frame = [m_view frame];
        frame.origin.x = 0;
        frame.origin.y = 0;
        m_oglView = [[SFOpenGLView alloc] initWithFrame:frame];
        
        if (m_oglView == nil) {
            
            sf::err()
            << "Could not create an instance of NSOpenGLView "
            << "in (SFViewController -initWithView:)."
            << std::endl;
            
            return self;
        }
        
        // Set the (OGL) view to the view as its "content" view.
        [m_view addSubview:m_oglView];
    }
    
    return self;
}


////////////////////////////////////////////////////////
-(void)dealloc
{
    [self closeWindow];
    
    [m_view release];
    [m_oglView release];
    
    [super dealloc];
}


////////////////////////////////////////////////////////
-(void)setRequesterTo:(sf::priv::WindowImplCocoa *)requester
{
    // Forward to the view.
    [m_oglView setRequesterTo:requester];
    m_requester = requester;
}


////////////////////////////////////////////////////////
-(sf::WindowHandle)getSystemHandle
{
    return m_view;
}


////////////////////////////////////////////////////////
-(void)changeTitle:(NSString *)title
{
    sf::err() << "Cannot change the title of the view." << std::endl;
}


////////////////////////////////////////////////////////
-(void)enableKeyRepeat
{
    [m_oglView enableKeyRepeat];
}


////////////////////////////////////////////////////////
-(void)disableKeyRepeat
{
    [m_oglView disableKeyRepeat];
}


////////////////////////////////////////////////////////
-(void)hideMouseCursor
{
    [NSCursor hide];
}


////////////////////////////////////////////////////////
-(void)showMouseCursor
{
    [NSCursor unhide];
}


////////////////////////////////////////////////////////
-(void)hideWindow
{
    [m_view setHidden:YES];
}


////////////////////////////////////////////////////////
-(void)showWindow
{
    [m_view setHidden:NO];
}


////////////////////////////////////////////////////////
-(void)closeWindow
{
    sf::err() << "Cannot close the view." << std::endl;
    [self setRequesterTo:0];
}


////////////////////////////////////////////////////////
-(void)setCursorPositionToX:(unsigned int)x Y:(unsigned int)y
{
    if (m_requester == 0) return;
    
    // Create a SFML event.
    m_requester->mouseMovedAt(x, y);
    
    // Flip for SFML window coordinate system
    y = NSHeight([[m_view window] frame]) - y;
    
    // Adjust for view reference instead of window
    y -= NSHeight([[m_view window] frame]) - NSHeight([m_oglView frame]);
    
    // Convert to screen coordinates
    NSPoint screenCoord = [[m_view window] convertBaseToScreen:NSMakePoint(x, y)];
    
    // Flip screen coodinates
    float const screenHeight = NSHeight([[[m_view window] screen] frame]);
    screenCoord.y = screenHeight - screenCoord.y;
    
    CGDirectDisplayID screenNumber = (CGDirectDisplayID)[[[[[m_view window] screen] deviceDescription] valueForKey:@"NSScreenNumber"] intValue];
    
    // Place the cursor.
    CGDisplayMoveCursorToPoint(screenNumber, CGPointMake(screenCoord.x, screenCoord.y));
    /*
     CGDisplayMoveCursorToPoint -- Discussion :
     
     No events are generated as a result of this move. 
     Points that lie outside the desktop are clipped to the desktop.
     */
}


////////////////////////////////////////////////////////////
-(NSPoint)position
{
    NSPoint pos = [m_view frame].origin;
    
    // Flip screen coodinates
    float const screenHeight = NSHeight([[[m_view window] screen] frame]);
    pos.y = screenHeight - pos.y;
    
    return pos;
}

////////////////////////////////////////////////////////.
-(void)setWindowPositionToX:(unsigned int)x Y:(unsigned int)y
{
    sf::err() << "Cannot move the view." << std::endl;
}


////////////////////////////////////////////////////////////
-(NSSize)size
{
    return [m_view frame].size;
}

////////////////////////////////////////////////////////
-(void)resizeTo:(unsigned int)width by:(unsigned int)height
{
    NSRect frame = NSMakeRect([m_view frame].origin.x,
                              [m_view frame].origin.y,
                              width,
                              height);
    
    [m_view setFrame:frame];
}


////////////////////////////////////////////////////////
-(void)setIconTo:(unsigned int)width
              by:(unsigned int)height 
            with:(sf::Uint8 const *)pixels
{
    sf::err() << "Cannot set an icon to the view." << std::endl;
}


////////////////////////////////////////////////////////
-(void)processEvent
{
    sf::err() << "Cannot process event from the view." << std::endl;
}


////////////////////////////////////////////////////////
-(void)applyContext:(NSOpenGLContext *)context
{
    [m_oglView setOpenGLContext:context];
    [context setView:m_oglView];
}


@end
