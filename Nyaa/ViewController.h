//
//  ViewController.h
//  Nyaa
//
//  Created by yaqinking on 4/30/15.
//  Copyright (c) 2015 yaqinking. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Torrent.h"
#import "AFNetworking.h"

@interface ViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *descriptionImageView;
@property (weak) IBOutlet NSTextField *descriptionTextField;

@property NSMutableArray *list;
@property int pageOffset;
@property int currentPageOffset;
@property NSString *keyword;
@property NSString *category;
@property NSString *requestURLString;

@property AFHTTPRequestOperationManager *manager;


- (void) setDescriptionPageWithURL:(NSString *)url;

- (void)configureMenuItems;
- (void)configureTableViewDataSourceWithURLString:(NSString *)urlString;

- (void)loadCategoryPage:(id)sender;

- (void)loadNextPage:(id)sender;
- (void)loadPreviousPage:(id)sender;

- (void)searchNormal:(id)sender;
- (void)searchSukebei:(id)sender;
@end