//
//  ofxiPhoneWebViewControlle.mm
//  emptyExample
//
//  Created by Daan van Hasselt on 5/28/12.
//  Copyright (c) 2012 Touchwonders B.V. All rights reserved.
//

#include "ofxiPhoneWebViewController.h"

///-------------------------------------------------
/// c++ OF class
///-------------------------------------------------

#pragma mark - C++ OF class

//--------------------------------------------------------------
void ofxiPhoneWebViewController::showView(int frameWidth, int frameHeight, BOOL animated, BOOL addToolbar, BOOL transparent, BOOL scroll) {
    
    // init delegate
    _delegate = [[ofxiPhoneWebViewDelegate alloc] init];
    _delegate.delegate = this;
    
    // create the view
    if(isRetina()) {
        frameWidth = frameWidth/2;
        frameHeight = frameHeight/2;
    }
    CGRect frame = CGRectMake(0, 0, frameWidth, frameHeight);
    createView(addToolbar, frame, transparent, scroll);
  
    // add to glView
    [ofxiPhoneGetGLParentView() addSubview:_view];
       
    if(animated){
        CATransition *applicationLoadViewIn =[CATransition animation];
        [applicationLoadViewIn setDuration:2.0];
        [applicationLoadViewIn setType:kCATransitionReveal];
        [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[_view layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    }

}

//--------------------------------------------------------------
void ofxiPhoneWebViewController::hideView(BOOL animated){
    if(animated){
        [UIView animateWithDuration:0.5 animations:^{
            _view.alpha = 0;
            // TODO: Choose between slide view & alpha.
            //_view.transform = CGAffineTransformMakeTranslation( _view.bounds.size.width/2, _view.bounds.size.height);      // transform down
        } completion:^(BOOL finished) {
            [_view removeFromSuperview];
            [_view release];
            [_webView release];
            [_delegate release];
        }];
    }
    else{
        [_view removeFromSuperview];
        [_view release];
        [_webView release];
        [_delegate release];
    }
    
}

//--------------------------------------------------------------
void ofxiPhoneWebViewController::setAutoRotation(bool _autoRotation){
    
        autoRotation = _autoRotation;
    
}

//--------------------------------------------------------------
void ofxiPhoneWebViewController::setOrientation(ofOrientation orientation){
    
    float rotation = 0;
    int screenWidth = ofGetWindowWidth();
    int screenHeight = ofGetWindowHeight();
    
    if(isRetina()) {
        screenWidth = screenWidth/2;
        screenHeight = screenHeight/2;
    }
    
    if(orientation == OF_ORIENTATION_180) {
        rotation = PI;
    }
    if(orientation == OF_ORIENTATION_90_LEFT) {
        rotation = PI / 2.0;
    }
    if(orientation == OF_ORIENTATION_90_RIGHT) {
        rotation = -PI / 2.0;
    }
    
    // Set thenchor point top-left and center
    //_view.layer.anchorPoint = CGPointMake(0.0, 0.0);
    //_view.center = CGPointMake(CGRectGetWidth(_view.bounds), 0.0);
    // Rotate
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, rotation);
    _view.transform = rotationTransform;
    // Resize
    _view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
}

//--------------------------------------------------------------
void ofxiPhoneWebViewController::loadNewUrl(NSURL *url) {
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

//--------------------------------------------------------------
void ofxiPhoneWebViewController::loadLocalFile(string & filename) {
  
    NSString *_filename = [NSString stringWithCString:filename.c_str() encoding:[NSString defaultCStringEncoding]];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:_filename ofType:@"html" inDirectory:@"www"];
        
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:baseURL];

}

#pragma mark Private

//--------------------------------------------------------------
void ofxiPhoneWebViewController::createView(BOOL withToolbar, CGRect frame, BOOL transparent, BOOL scroll){
    
    ///////////////////////////////////////////////////////////////////
    // Init view
    ///////////////////////////////////////////////////////////////////
    _view = [[UIView alloc] initWithFrame:frame];
    // Resize properties
    _view.autoresizesSubviews = YES;
    _view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
                             UIViewAutoresizingFlexibleBottomMargin |
                             UIViewAutoresizingFlexibleWidth |
                             UIViewAutoresizingFlexibleHeight;
    // Background:
    if(!transparent) {
        _view.backgroundColor = [UIColor whiteColor];
        _view.alpha = 0.5;
    }
    ///////////////////////////////////////////////////////////////////
    // Add toolbar with close button and title:
    ///////////////////////////////////////////////////////////////////
    if(withToolbar){
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, _view.bounds.size.width, 44)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"Browser" style:UIBarButtonItemStylePlain target:nil action:nil];
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:_delegate action:@selector(closeButtonTapped)];
        [toolbar setItems:[NSArray arrayWithObjects:spacer, title, spacer, closeButton, nil]];
        [toolbar setAutoresizesSubviews:YES];
        [toolbar setAutoresizingMask:
         UIViewAutoresizingFlexibleWidth ];
        [_view addSubview:toolbar];
    }
    ///////////////////////////////////////////////////////////////////
    // Add webview
    ///////////////////////////////////////////////////////////////////
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                           withToolbar ? 44 : 0,
                                                           _view.bounds.size.width, 
                                                           withToolbar ? _view.bounds.size.height - 44 : _view.bounds.size.height)];
    _webView.tag = 0;
    [_view addSubview:_webView];
    _webView.delegate = _delegate;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // Background
    if(transparent) {
        _webView.opaque = false;
        _webView.backgroundColor = [UIColor clearColor];
    }
    // Scrollable
    if(!scroll) {
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.bounces = NO;
    }

}

bool ofxiPhoneWebViewController::isRetina(){
    
    bool isRetina;
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if ([UIScreen instancesRespondToSelector:@selector(scale)])
		{
			CGFloat scale = [[UIScreen mainScreen] scale];
            
			if (scale > 1.0)
			{
				// isIpad 3
				isRetina = true;
			} else {
				// isIpad 1 or 2
				isRetina = false;
			}
		}
        
	} else {
        
		if ([UIScreen instancesRespondToSelector:@selector(scale)])
		{
			CGFloat scale = [[UIScreen mainScreen] scale];
            
			if (scale > 1.0)
			{
				// iPhone Retina
				isRetina = true;
			} else {
				// iPhone
				isRetina = false;
			}
		}
	}
    
    return isRetina;
    
}


#pragma mark Callbacks

//--------------------------------------------------------------
void ofxiPhoneWebViewController::didStartLoad() {
    ofxiPhoneWebViewControllerEventArgs args = ofxiPhoneWebViewControllerEventArgs(_webView.request.URL, ofxiPhoneWebViewStateDidStartLoading, nil);
    ofNotifyEvent(event, args, this);
}

//--------------------------------------------------------------
void ofxiPhoneWebViewController::didFinishLoad() {
    ofxiPhoneWebViewControllerEventArgs args = ofxiPhoneWebViewControllerEventArgs(_webView.request.URL, ofxiPhoneWebViewStateDidFinishLoading, nil);
    ofNotifyEvent(event, args, this);
}

//--------------------------------------------------------------
void ofxiPhoneWebViewController::didFailLoad(NSError *error) {
    ofxiPhoneWebViewControllerEventArgs args = ofxiPhoneWebViewControllerEventArgs(_webView.request.URL, ofxiPhoneWebViewStateDidFailLoading, error);
    ofNotifyEvent(event, args, this);
}

///-------------------------------------------------
/// obj-c webview delegate
///-------------------------------------------------
#pragma mark - Obj-c WebView Delegate

@implementation ofxiPhoneWebViewDelegate

@synthesize delegate;

- (void)closeButtonTapped {
    delegate->hideView(YES);
}

//
// UIWebviewDelegate methods
//

- (void)webViewDidStartLoad:(UIWebView *)webView {
    delegate->didStartLoad();
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    delegate->didFinishLoad();
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    delegate->didFailLoad(error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[request.URL scheme] isEqual:@"of"]) {
        // We can call to an internal function from here:
        // TODO: Use pathComponents instead of host to get variables.
        cout << [[request.URL host] UTF8String] << endl;
        if ([[request.URL host] isEqual:@"closeWindow"]) {
            delegate->hideView(YES);
        }
        return NO; // Tells the webView not to load the URL
    }
    else {
        return YES; // Tells the webView to go ahead and load the URL
    }
    
}

@end