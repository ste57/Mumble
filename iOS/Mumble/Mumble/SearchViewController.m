//
//  SearchViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 09/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "SearchViewController.h"
#import "Config.h"
#import "TagPressedViewController.h"

@implementation SearchViewController {
    
    UISearchBar *searchBar;
    UISearchDisplayController *searchBarController;
    
    NSArray *searchResults;
}

@synthesize userGeoPoint;

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self createSearchBar];
    
    [self showSearchBar];
}

- (void) createSearchBar {
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,20,0,0)];
    searchBar.delegate = self;
    
    searchBar.placeholder = SEARCH_BAR_PLACEHOLDER;
    searchBar.showsCancelButton = YES;
    
    searchBarController = [[UISearchDisplayController alloc]
                           initWithSearchBar:searchBar
                           contentsController:self];
    
    searchBarController.delegate = self;
    searchBarController.searchResultsDataSource = self;
    searchBarController.searchResultsDelegate = self;
    
    searchBar.translucent = NO;
    
    [searchBarController searchResultsTableView].separatorColor = [UIColor colorWithRed:0.875 green:0.875 blue:0.875 alpha:0.7];
}

- (void) showSearchBar {

    [self.view addSubview:searchBar];
    
    //[searchBarController searchResultsTableView] add
    
    //self.navigationController.navigationBarHidden = YES;
    
    searchResults = [[NSArray alloc] init];
    
    [searchBarController setActive:YES animated:YES];
    [searchBar becomeFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
    [self searchForTag];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBarItem {
    
    if (searchBar.text.length < 1) {
        
        searchBar.text = TAG_IDENTIFIER;
        
        [self getPopularTags];
    }
}

- (void) getPopularTags {
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query setLimit:POPULAR_TAG_LIMIT];
    
    [query whereKey:MUMBLE_DATA_LOCATION nearGeoPoint:userGeoPoint];
    
    [query orderByDescending:[NSString stringWithFormat:@"createdAt"]];
    
    [query selectKeys:@[MUMBLE_DATA_TAGS]];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    searchResults = [[NSArray alloc] init];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (PFObject *object in objects) {
            
            [array addObjectsFromArray:object[MUMBLE_DATA_TAGS]];
        }
        
        for (NSString *string in array) {
            
            if ([dictionary objectForKey:string]) {
                
                NSInteger number = [[dictionary objectForKey:string] integerValue];
                number++;
                [dictionary setObject:[NSNumber numberWithInteger:number] forKey:string];
                
            } else {
                
                [dictionary setValue:[NSNumber numberWithInteger:0] forKey:string];
            }
        }
        
        searchResults = [dictionary keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                
                return (NSComparisonResult)NSOrderedAscending;
            }
            if ([obj1 integerValue] < [obj2 integerValue]) {
                
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [[searchBarController searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void) searchBar:(UISearchBar *)searchBarItem textDidChange:(NSString *)searchText {
    
    if (searchBar.text.length == 1) {
        
        [self getPopularTags];
    }
    
    if (searchBar.text.length < 1) {
        
        searchBar.text = TAG_IDENTIFIER;
        
    } else {
        
        [self searchForTag];
    }
}

- (void) searchForTag {
    
    if (searchBar.text.length > 1) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        searchResults = [[NSArray alloc] init];
        
        PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
        
        [query setLimit:20];
        
        [query selectKeys:@[MUMBLE_DATA_TAGS]];
        
        [query whereKey:MUMBLE_DATA_TAGS equalTo:searchBar.text];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            for (PFObject *object in objects) {
                
                NSArray *arr = object[MUMBLE_DATA_TAGS];
                
                for (NSString *string in arr) {
                    
                    if ([string isEqual:searchBar.text]) {
                        
                        [array addObject:string];
                    }
                }
            }
            
            NSMutableArray * unique = [NSMutableArray array];
            NSMutableSet * processed = [NSMutableSet set];
            
            for (NSString * string in array) {
                
                if ([processed containsObject:string] == NO) {
                    [unique addObject:string];
                    [processed addObject:string];
                }
            }
            
            searchResults = unique;
            
            [[searchBarController searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {

    return searchResults.count;
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table dequeueReusableCellWithIdentifier:@"Cell"];
        
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        
    cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = NAV_BAR_COLOUR;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    return 50.0;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAG_PRESSED object:[searchResults objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [table deselectRowAtIndexPath:sourceIndexPath animated:NO];
}

- (void) removeBackButtonText {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
