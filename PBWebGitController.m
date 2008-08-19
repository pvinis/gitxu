//
//  PBWebGitController.m
//  GitTest
//
//  Created by Pieter de Bie on 14-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBWebGitController.h"


@implementation PBWebGitController

@synthesize diff;

- (void) awakeFromNib
{
	[detailController addObserver:self forKeyPath:@"webCommit" options:0 context:@"ChangedCommit"];
	
	NSLog([[NSBundle mainBundle] resourcePath]);
	NSString* file = [[NSBundle mainBundle] pathForResource:@"commit" ofType:@"html"];
	NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:file]];
	currentSha = @"Not Loaded";
	[[view mainFrame] loadRequest:request];	
}

- (void) webView:(id) v didFinishLoadForFrame:(id) frame
{
	id script = [view windowScriptObject];
	[script setValue: self forKey:@"Controller"];
	currentSha = @"";

	[self changeContentTo: detailController.webCommit];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"ChangedCommit") {
		[self changeContentTo: detailController.webCommit];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void) changeContentTo: (PBGitCommit *) content
{
	if (content == nil)
		return;

	if ([currentSha isEqualToString: content.sha] || [currentSha isEqualToString:@"Not Loaded"])
		return;
	
	currentSha = content.sha;
	id script = [view windowScriptObject];
	[script setValue: content forKey:@"CommitObject"];
	[script callWebScriptMethod:@"loadCommit" withArguments: nil];
}

- (void) log: (NSString*) logMessage
{
	NSLog(logMessage);
}

- (void) selectCommit: (NSString*) sha
{
	NSPredicate* selection = [NSPredicate predicateWithFormat:@"sha == %@", sha];
	NSArray* selectedCommits = [detailController.repository.revisionList.commits filteredArrayUsingPredicate:selection];
	// TODO: reimplement this. How can we set the new commit? Our detailscontroller is read-only
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
	return NO;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name {
	return NO;
}

@end
