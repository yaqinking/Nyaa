//
//  NyaaAPI.h
//  nyaa.se & sukebei.nyaa.se
//
//  Created by yaqinking on 15/4/30.
//  Copyright (c) 2015年 yaqinking. All rights reserved.
//

//Main page Normal mode
#define NYAA_URL_NORMAL  @"http://www.nyaa.se"
#define NYAA_URL_SUKEBEI @"http://sukebei.nyaa.se"
//Main page Sukebei mode
//Next page or set a page number
#define NYAA_URL_NORMAL_PAGE_OFFSET  @"http://www.nyaa.se/?offset=%@"
#define NYAA_URL_SUKEBEI_PAGE_OFFSET @"http://sukebei.nyaa.se/?offset=%@"

//---------------
//|  Search     |
//|  Normal     |
//|-------------|
#define NYAA_NORMAL_TERM_OFFSET @"http://www.nyaa.se/?page=search&term=%@&offset=%d"
#define NYAA_SEARCH_NORMAL_PIC @"http://www.nyaa.se/?page=search&cats=4_0&offset=%d"
#define NYAA_NORMAL_AUDIO_OFFSET @"http://www.nyaa.se/?cats=3_0&offset=%d"
#define NYAA_NORMAL_LIVE_OFFSET @"http://www.nyaa.se/?cats=5_0&offset=%d"
//----Sukebei----
//Non filter                etc. http://sukebei.nyaa.se/?page=search&cats=0_0&filter=0&term=nisekoi
//Next searched page or set a page number       http://sukebei.nyaa.se/?page=search&cats=7_0&term=soft&offset=3
//Cat Art     7_0           etc. http://sukebei.nyaa.se/?page=search&cats=7_0&filter=0&term=nisekoi
//Cat Art Pic 7_28          etc.http://sukebei.nyaa.se/?page=search&cats=7_28&filter=0&term=nisekoi
//Other   Anime 7_25  Dojinshi 7_33   Games 7_27  Manga 7_26
#define NYAA_SEARCH_SUKEBEI_BY_KEYWORD                         @"http://sukebei.nyaa.se/?page=search&cats=0_0&filter=0&term=%@"
#define NYAA_SEARCH_SUKEBEI_BY_CAT_ART_KEYWORD_SET_PAGE_OFFSET @"http://sukebei.nyaa.se/?page=search&cats=7_0&term=%@&offset=%@"
#define NYAA_SEARCH_SUKEBEI_BY_CAT_ART_AND_KEYWORD             @"http://sukebei.nyaa.se/?page=search&cats=7_0&filter=0&term=%@"
#define NYAA_SEARCH_SUKEBEI_BY_CAT_ART_PIC_AND_KEYWORD         @"http://sukebei.nyaa.se/?page=search&cats=7_28&filter=0&term=%@"
#define NYAA_SUKEBEI_GAME_CG_URL                               @"http://sukebei.nyaa.se/?page=search&cats=0_0&filter=0&term=%E3%82%B2%E3%83%BC%E3%83%A0CG"
#define NYAA_SUKEBEI_ART_PIC @"http://sukebei.nyaa.se/?cats=7_28&offset=%d"
/*
 ---------------------------------------------------------------------------
 Main Page Info CSS Selector Explain
 ---------------------------------------------------------------------------
 .tlistname         Torrent Name has Torrent Name and Torrent Detail Page Link
                    [element stringValue] can get Torrent Name
 .tlistdownload     Torrent Download Link ---> Replace view to download (?page=view&tid=??? to ?page=download&tid=??? OK tid is equal)
                    [element description] then use regex extract download url
 .tlistsize         File Size
 .tlistsn           Seed count
 .tlistln           ???? Curent user count?
 .tlistdn           Download count
 
 ---------------------------------------------------------------------------
 Enter Detail Torrent Page Info CSS Selector Explain
 ---------------------------------------------------------------------------
 .viewdescription   Torrent Description has preview images
                    then use regex extract preview image download url
                    after that download to local temp document path , then load to NSImageView
 */
//  CSS Selector
#define CSS_TORRENT_NAME        @".tlistname"
#define CSS_TORRENT_DOWNLOAD    @".tlistdownload"
#define CSS_TORRENT_SIZE        @".tlistsize"
#define CSS_TORRENT_DESCRIPTION @".viewdescription"
//Regular Expression to extract URL
//Objc can't use \w \. \; so it become to \\w \\. \\; and so on
//Regular Expression to extract viewdescription contain's image url
#define REGEX_EXTRACT_URL      @"https?://\\w.[(\\w+)\\./?=&\\w\\;\\w]+"
#define REGEX_EXTACT_IMAGE_URL @"https?://\\w.[(\\w+)\\./?=&\\w\\;\\w]+\\.(jpg)"
