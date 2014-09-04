//
//  loInviteFriendsViewController.m
//  xp802Push
//
//  Created by Lova on 2014/3/12.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loInviteFriendsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "loInviteTableViewCell.h"
#import "loConnectPHP.h"
#import "loViewController.h"


@interface loInviteFriendsViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSArray* fbFriends;
    NSMutableArray* fbFriendsAfterSearch;
    NSMutableArray* selectedFriends;
}

@property (strong, nonatomic) IBOutlet UISearchBar *loSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *loTableViewFBFriends;

@end

@implementation loInviteFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    fbFriends = nil;
    fbFriends=[[NSArray alloc]init];
    
    fbFriendsAfterSearch=nil;
    
    selectedFriends=nil;
    selectedFriends=[[NSMutableArray alloc]init];
    
    FBRequest* friendRequest=[FBRequest requestForMyFriends];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                NSDictionary* result,
                                                NSError *error) {
        if (error == nil ) {
            fbFriends=result[@"data"];
            fbFriendsAfterSearch=[[NSMutableArray alloc]initWithArray:fbFriends];
            
            [_loTableViewFBFriends reloadData];
            
          //  [_loTableViewFBFriends setEditing:YES];
        }else{
            NSLog(@"fb request error : %@",error);
        }
        
    }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loBarItemButtonDone:(UIBarButtonItem *)sender
{
    NSString* sqlCommand=[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`users` SET  `isInvited` =  '%@' WHERE  `users`.`FB_ID` =",[loConnectPHP shareInstance].plistDict[@"fb_id"]];
    //'FB_ID=,'ccc',ddd','vvvv'
    for (NSString* FB_ID in selectedFriends) {
        sqlCommand=[sqlCommand stringByAppendingString:[NSString stringWithFormat:@",'%@'",FB_ID]];
    }

    sqlCommand=[sqlCommand stringByReplacingOccurrencesOfString:@"=," withString:@"="];
   // NSLog(@"sqlcommand = %@",sqlCommand);
    
    //執行 sqlCommand
    [[loConnectPHP shareInstance]loSQLCommand:sqlCommand afterSYNC:-1 Completion:^{
       
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fbFriendsAfterSearch count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //fb
    
    //        {
    //            "first_name" = Joly;
    //            id = 539372716;
    //            "last_name" = Huang;
    //            name = "Joly Huang";
    //            username = "joly.huang.7";
    //        }
    //        NSLog(@"result = %@",result[@"data"][1][@"first_name"]);
    //        NSLog(@"result = %@",result[@"data"][1]);
    
    //  NSLog(@"all of %lu friends",(unsigned long)[result[@"data"] count]);
    // NSLog(@"%@",_fbFriends);
    
    loInviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        cell.loFriendPhoto.profileID=nil;
        cell.loFriendPhoto.profileID=fbFriendsAfterSearch[indexPath.row][@"id"];
        
        cell.loFriendPhoto.layer.cornerRadius=cell.loFriendPhoto.frame.size.height/2;
        if ( [selectedFriends indexOfObject:cell.loFriendPhoto.profileID] == NSNotFound ) {
            cell.loImageViewIfInvited.image=[UIImage imageNamed:@"plus.png"];
        }else{
            cell.loImageViewIfInvited.image=[UIImage imageNamed:@"checkmark.png"];
        }
    });

    
    cell.loFriendNickName.text=fbFriendsAfterSearch[indexPath.row][@"name"];

    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                       action:@selector(selected:)];
    [cell addGestureRecognizer:tap];


    return cell;
}


-(void)selected:(UITapGestureRecognizer*)sender
{
    loInviteTableViewCell* cell=(loInviteTableViewCell*)sender.view;
    
    
    cell.loImageViewIfInvited.image =  cell.loImageViewIfInvited.image == [UIImage imageNamed:@"plus.png"] ?  [UIImage imageNamed:@"checkmark.png"]  :  [UIImage imageNamed:@"plus.png"] ;
    
    
    //打勾時加入 把 id加入 array   不然就刪掉
    cell.loImageViewIfInvited.image == [UIImage imageNamed:@"checkmark.png"] ? [selectedFriends addObject:cell.loFriendPhoto.profileID] : [selectedFriends removeObject:cell.loFriendPhoto.profileID];


    NSLog(@" selectedFriends %@",[selectedFriends description]);
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
#pragma mark - UISearchBarDelegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
     searchBar.text = nil;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    fbFriendsAfterSearch=nil;

    if ([searchText isEqualToString:@""]) {
        fbFriendsAfterSearch=[[NSMutableArray alloc]initWithArray:fbFriends];
        [_loTableViewFBFriends reloadData];
        return;
    }
    
    fbFriendsAfterSearch=[[NSMutableArray alloc]init];
    
    for (NSDictionary* dict in fbFriends) {
        NSString* name=  [dict[@"name"] lowercaseString];  //轉小寫存入
        
        if ([name rangeOfString:[searchText lowercaseString] ].location !=NSNotFound )
            [fbFriendsAfterSearch addObject:dict];
        
    }
    
    [_loTableViewFBFriends reloadData];
}


@end
