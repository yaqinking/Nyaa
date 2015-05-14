//
//  ViewController.m
//  Nyaa
//
//  Created by yaqinking on 4/30/15.
//  Copyright (c) 2015 yaqinking. All rights reserved.
//

#import "ViewController.h"
#import "AFOnoResponseSerializer.h"
#import "Ono.h"
#import "NyaaAPI.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.list                       = [[NSMutableArray alloc] init];
    self.pageOffset                 = 1;
    self.manager                    = [AFHTTPRequestOperationManager manager];
    self.manager.responseSerializer = [AFOnoResponseSerializer HTMLResponseSerializer];
    self.requestURLString           = [NSString stringWithFormat:NYAA_SEARCH_NORMAL_PIC,self.pageOffset];
    
    [self configureTableViewDataSourceWithURLString:self.requestURLString];
    
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(openTorrentDownloadURL)];
    [self configureMenuItems];
    NSLog(@"Page offset %d",self.pageOffset);
    self.category = @"Normal Pic";//Default load Normal Pic category page
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
#pragma mark - NSTableViewDataSource protocol
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"List count %lu",(unsigned long)[self.list count]);
    return [self.list count];
}

#pragma mark - NSTableViewDelegate protocol
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Torrent *torrent = self.list[row];
    NSString *identifier = tableColumn.identifier;
    [self.tableView setRowHeight:50.0];
    if ([identifier isEqualToString:@"MainCell"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        [cellView.textField setStringValue:torrent.torrentName];
        return cellView;
    }
    return nil;
}
//When tableView select row did change
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    //    NSLog(@"current select row %lu",[self.tableView selectedRow]);
    //Do update image and paragraph
    [self.tableView sizeToFit];
    Torrent *t = [[Torrent alloc] init];
    t = [self.list objectAtIndex:[self.tableView selectedRow]];
    NSLog(@"Torrent Page URL -> %@",t.detailURL);
    [self.descriptionTextField setStringValue:t.torrentName];
    [self setDescriptionPageWithURL:t.detailURL];
    
    
}
#pragma mark - TableView Double Click Action
- (void) openTorrentDownloadURL {
    //    NSLog(@"openDownloadURL");
    Torrent *t = [[Torrent alloc] init];
    
    t = [self.list objectAtIndex:[self.tableView selectedRow]];
    NSString *downloadStr = [t.detailURL stringByReplacingOccurrencesOfString:@"view" withString:@"download"];
    //    NSLog(@"Download String -> %@",downloadStr);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadStr]];
}


#pragma mark - Configure Torrent Display list
- (void) setTorrentInfoURLBy:(ONOXMLDocument *) responseDocument CSSSelector:(NSString *)aCSSSelector {
    if ([aCSSSelector isEqualTo:CSS_TORRENT_NAME]) {
        //Get Torrent Name and Detail Page URL
        for (ONOXMLElement *element in [responseDocument CSS:CSS_TORRENT_NAME]) {
            __unused NSString *name = [element stringValue];
            //        NSLog(@"Torrent Name --> %@ \n",name);
            
            NSString *str  = [element description];
            //            NSLog(@"str --> %@\n------------------------",str);
            
            
            NSError *error = nil;
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_EXTRACT_URL
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray *arrayOfAllMatches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
            
            for (NSTextCheckingResult *match in arrayOfAllMatches) {
                NSString* substringForMatch = [str substringWithRange:match.range];
                //substringForMatch contains some unnecessary link,So use containsString method to flite
                //                NSLog(@"subStringForMatch -> %@",substringForMatch);
                //Because it's nyaa so I use this method to convert &amp; to & then get download link
                if ([substringForMatch containsString:@"page"]) {
                    __unused NSString *subURLString = [substringForMatch stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                    //                NSLog(@"Extracted Page URL: %@",subURLString);
                    Torrent *torrent    = [[Torrent alloc] init];
                    torrent.torrentName = name;
                    torrent.detailURL   = subURLString;
                    [self.list addObject:torrent];
                }
            }
        }
        
    }
    
    if ([aCSSSelector isEqualTo:CSS_TORRENT_DESCRIPTION]) {
        for (ONOXMLElement *element in [responseDocument CSS:CSS_TORRENT_DESCRIPTION]) {
            __unused NSString *name = [element stringValue];
            
            NSString *str  = [element description];
            NSError *error = nil;
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_EXTACT_IMAGE_URL
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSArray *arrayOfAllMatches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
            for (NSTextCheckingResult *match in arrayOfAllMatches) {
                NSString* substringForMatch = [str substringWithRange:match.range];
                
                NSLog(@"Extracted Image URL: %@",substringForMatch);
                if ([substringForMatch containsString:@"tinypic"]) {
                    //If image source from tinypic don't display , It's too slow to load.
                    return ;
                }
                if ([substringForMatch isNotEqualTo:@""]) {
                    NSImage *descImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:substringForMatch]];
                    if (descImage) {
                        [self.descriptionImageView setImage:descImage];
                        [self.descriptionImageView sizeToFit];
                        [self.descriptionImageView setNeedsDisplay];
                        return ;
                    }
                }
                
                
                
            }
            //Default display image
            NSImage *mashiro = [NSImage imageNamed:@"mashiro"];
            [self.descriptionImageView setImage:mashiro];
        }
        
    }
    
}
- (void)setDescriptionPageWithURL:(NSString *)url {
    [self.manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             //             NSLog(@"%@",responseDocument);
             [self setTorrentInfoURLBy:responseDocument CSSSelector:CSS_TORRENT_DESCRIPTION];
             
         }
         failure:nil];
}

- (void)configureTableViewDataSourceWithURLString:(NSString *)urlString {
    self.requestURLString = urlString;
    [self.manager GET:self.requestURLString
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
                  [self setTorrentInfoURLBy:responseDocument CSSSelector:CSS_TORRENT_NAME];
                  //             for (Torrent *t in self.list) {
                  //
                  //                 NSLog(@"Torrent Name %@ \n",t.torrentName);
                  //                 NSLog(@"Torrent Detail URL %@\n",t.detailURL);
                  //             }
                  
                  [self.tableView reloadData];
              } failure:nil];
}

# pragma mark - Menu Item

- (void)configureMenuItems {
    NSMenu *mainMenu = [NSApp mainMenu];
    //Main menu item
    NSMenuItem *cateMenuItem   = [mainMenu itemWithTitle:@"Category"];
    NSMenuItem *navMenuItem    = [mainMenu itemWithTitle:@"Nav"];
    NSMenuItem *searchMenuItem = [mainMenu itemWithTitle:@"Search"];
    //Sub menu
    NSMenu *cateMenu   = [cateMenuItem submenu];
    NSMenu *navMenu    = [navMenuItem submenu];
    NSMenu *searchMenu = [searchMenuItem submenu];
    //Cate sub menu item
    NSMenuItem *nomalPicMenuItem    = [cateMenu itemWithTitle:@"Normal Pic"];
    NSMenuItem *normalMusicMenuItem = [cateMenu itemWithTitle:@"Normal Music"];
    NSMenuItem *normalLiveMenuItem  = [cateMenu itemWithTitle:@"Normal Live"];
    NSMenuItem *artPicMenuItem      = [cateMenu itemWithTitle:@"Art Pic"];
    NSMenuItem *artGameCGMenuItem   = [cateMenu itemWithTitle:@"Art Game CG"];
    //Nav sub menu item
    NSMenuItem *nextPageMenuItem     = [navMenu itemWithTitle:@"Next Page"];
    NSMenuItem *previousPageMenuItem = [navMenu itemWithTitle:@"Previous Page"];
    //Search sub menu item
    NSMenuItem *normalSearchMenuItem = [searchMenu itemWithTitle:@"Normal Search"];
    NSMenuItem *artSearchMenuItem    = [searchMenu itemWithTitle:@"Art Search"];
    //--------------Category--------------
    [nomalPicMenuItem setTarget:self];
    [nomalPicMenuItem setAction:@selector(loadCategoryPage:)];
    [normalMusicMenuItem setTarget:self];
    [normalMusicMenuItem setAction:@selector(loadCategoryPage:)];
    [normalLiveMenuItem setTarget:self];
    [normalLiveMenuItem setAction:@selector(loadCategoryPage:)];
    [artPicMenuItem setTarget:self];
    [artPicMenuItem setAction:@selector(loadCategoryPage:)];
    [artGameCGMenuItem setTarget:self];
    [artGameCGMenuItem setAction:@selector(loadCategoryPage:)];
    //--------------Nav-----------------
    [nextPageMenuItem setTarget:self];
    [nextPageMenuItem setAction:@selector(loadNextPage:)];
    [previousPageMenuItem setTarget:self];
    [previousPageMenuItem setAction:@selector(loadPreviousPage:)];
    //-------------Search---------------
    [normalSearchMenuItem setTarget:self];
    [normalSearchMenuItem setAction:@selector(loadCategoryPage:)];
    [artSearchMenuItem setTarget:self];
    [artSearchMenuItem setAction:@selector(loadCategoryPage:)];
    
}

#pragma mark - Menu Item Action
- (void)loadCategoryPage:(id) sender {
    NSLog(@"%@",[sender title]);
    self.category = [sender title];
    NSLog(@"category = %@",self.category);
    
    NSString *cate = self.category;
    if ([cate isEqualToString:@"Art Game CG"]) {
        [self.list removeAllObjects];
        NSString *urlString =  NYAA_SUKEBEI_GAME_CG_URL;
        [self configureTableViewDataSourceWithURLString:urlString];
        return ;
    }
    if ([cate isEqualToString:@"Art Pic"]) {
        [self.list removeAllObjects];
        self.pageOffset = 1;
        NSString *urlString = [NSString stringWithFormat:NYAA_SUKEBEI_ART_PIC,self.pageOffset];
        [self configureTableViewDataSourceWithURLString:urlString];
        return ;
    }
    if ([cate isEqualToString:@"Normal Music"]) {
        [self.list removeAllObjects];
        self.pageOffset = 1;
        NSString *urlString = [NSString stringWithFormat:NYAA_NORMAL_AUDIO_OFFSET,self.pageOffset];
        [self configureTableViewDataSourceWithURLString:urlString];
        return ;
    }
    if ([cate isEqualToString:@"Normal Live"]) {
        [self.list removeAllObjects];
        self.pageOffset = 1;
        NSString *urlString = [NSString stringWithFormat:NYAA_NORMAL_LIVE_OFFSET,self.pageOffset];
        [self configureTableViewDataSourceWithURLString:urlString];
        return ;
    }
    
    
}
- (void)loadNextPage:(id)sender {
    [self.list removeAllObjects];
    self.pageOffset ++;
    NSLog(@"Load %@ Cate %d Page",self.category,self.pageOffset);
    if ([self.category isEqualToString:@"Normal Pic"]) {
        NSString *nextPageURLString = [NSString stringWithFormat:NYAA_SEARCH_NORMAL_PIC,self.pageOffset];
        NSLog(@"Next page url string %@",nextPageURLString);
        [self configureTableViewDataSourceWithURLString:nextPageURLString];
        return ;
    }
    if ([self.category isEqualToString:@"Art Pic"]) {
        NSString *nextPageURLString = [NSString stringWithFormat:NYAA_SUKEBEI_ART_PIC,self.pageOffset];
        NSLog(@"Next page url string %@",nextPageURLString);
        [self configureTableViewDataSourceWithURLString:nextPageURLString];
        return ;
    }
    if ([self.category isEqualToString:@"Normal Music"]) {
        NSString *nextPageURLString = [NSString stringWithFormat:NYAA_NORMAL_AUDIO_OFFSET,self.pageOffset];
        NSLog(@"Next page url string %@",nextPageURLString);
        [self configureTableViewDataSourceWithURLString:nextPageURLString];
        return ;
    }
    if ([self.category isEqualToString:@"Normal Live"]) {
        NSString *nextPageURLString = [NSString stringWithFormat:NYAA_NORMAL_LIVE_OFFSET,self.pageOffset];
        NSLog(@"Next page url string %@",nextPageURLString);
        [self configureTableViewDataSourceWithURLString:nextPageURLString];
        return ;
    }
}

- (void)loadPreviousPage:(id)sender {
    [self.list removeAllObjects];
    if (self.pageOffset > 1) {
        self.pageOffset --;
    } else {
        self.pageOffset = 1;
    }
    
    NSLog(@"Load %@ Cate %d Page",self.category,self.pageOffset);
    if ([self.category isEqualToString:@"Normal Pic"]) {
        NSString *previousPageURLString = [NSString stringWithFormat:NYAA_SEARCH_NORMAL_PIC,self.pageOffset];
        NSLog(@"Previous page url string %@",previousPageURLString);
        [self configureTableViewDataSourceWithURLString:previousPageURLString];
        return ;
    }
    if ([self.category isEqualToString:@"Art Pic"]) {
        NSString *previousPageURLString = [NSString stringWithFormat:NYAA_SEARCH_NORMAL_PIC,self.pageOffset];
        NSLog(@"Previous page url string %@",previousPageURLString);
        [self configureTableViewDataSourceWithURLString:previousPageURLString];
        return ;
    }
    if ([self.category isEqualToString:@"Normal Music"]) {
        NSString *previousPageURLString = [NSString stringWithFormat:NYAA_NORMAL_AUDIO_OFFSET,self.pageOffset];
        NSLog(@"Previous page url string %@",previousPageURLString);
        [self configureTableViewDataSourceWithURLString:previousPageURLString];
        return ;
    }
    if ([self.category isEqualToString:@"Normal Live"]) {
        NSString *previousPageURLString = [NSString stringWithFormat:NYAA_NORMAL_LIVE_OFFSET,self.pageOffset];
        NSLog(@"Previous page url string %@",previousPageURLString);
        [self configureTableViewDataSourceWithURLString:previousPageURLString];
        return ;
    }
}

- (void)searchNormal:(id)sender {
    
}

- (void)searchSukebei:(id)sender {
    
}


@end


#pragma mark - Other Document
/*
 Some Other Document
 //Extract Torrent Download URL
 //Download URL 暫時不管 進入詳細頁之後再提取 自己篩選內容還是有必要的,於是我發覺：把 page 字符串換成 download 就可以了 >_<
 
 for (ONOXMLElement *element in [responseDocument CSS:CSS_TORRENT_DOWNLOAD]) {
 //                 NSLog(@"CSS .tlistname --> %@\n---------------------------------------------------------------------------\n",element);
 
 NSString *str = [element description];
 //                 NSLog(@"str --> %@\n------------------------",str);
 
 //Extract url from string Regular Expression ->  http?://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?
 NSError *error = nil;
 
 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_EXTRACT_URL
 options:NSRegularExpressionCaseInsensitive
 error:&error];
 
 NSArray *arrayOfAllMatches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
 
 for (NSTextCheckingResult *match in arrayOfAllMatches) {
 NSString* substringForMatch = [str substringWithRange:match.range];
 
 if ([substringForMatch containsString:@"download"]) {
 __unused NSString *subURLString = [substringForMatch stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
 //                NSLog(@"Extracted Download URL: %@",subURLString);
 
 }
 }
 }
 */

/* Test to get menu item
 NSMenu *mainMenu = [NSApp mainMenu];
 NSMenuItem *item1 = [mainMenu itemAtIndex:1];
 NSMenuItem *item2 = [mainMenu itemAtIndex:2];
 NSMenuItem *item3 = [mainMenu itemAtIndex:3];
 NSMenuItem *item4 = [mainMenu itemAtIndex:4];
 NSMenuItem *item5 = [mainMenu itemAtIndex:5];
 NSLog(@"[Just menu item]%@",[item1 title]);
 NSLog(@"[Just menu item]%@",[item2 title]);
 NSLog(@"[Just menu item]%@",[item3 title]);
 NSLog(@"[Just menu item]%@",[item4 title]);
 NSLog(@"[Just menu item]%@",[item5 title]);
 NSMenuItem *subItem1 = [[item1 submenu] itemAtIndex:1];
 NSLog(@"[Sub menu item]%@",[subItem1 title]);
 [subItem1 setTarget:self];
 [subItem1 setAction:@selector(loadCategoryPage:)];
 */
