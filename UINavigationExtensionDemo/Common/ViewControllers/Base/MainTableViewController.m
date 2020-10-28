//
//  MainTableViewController.m
//  UINavigationExtensionDemo
//
//  Created by Leo Lee on 2020/9/27.
//

#import "MainTableViewController.h"
#import "LightNavigationController.h"

#import "ViewController01_BackgroundColor.h"
#import "ViewController02_BackgroundImage.h"
#import "ViewController03_Transparent.h"
#import "ViewController04_Translucent.h"
#import "ViewController05_ShadowColor.h"
#import "ViewController06_ShadowImage.h"
#import "ViewController07_CustomBackButtonImage.h"
#import "ViewController08_CustomBackButton.h"
#import "ViewController09_Modal.h"
#import "ViewController10_FullScreen.h"
#import "ViewController12_ScrollViewWithFullScreen.h"
#import "ViewController11_ScrollView.h"

#import "ViewController01_DisablePopGesture.h"
#import "ViewController02_FullPopGesture.h"
#import "ViewController03_BackEventIntercept.h"
#import "ViewController04_JumpToViewController.h"
#import "ViewController05_Custom.h"
#import "ViewController06_ClickEventHitToBack.h"
#import "ViewController07_ScrollChangeNavigationBar.h"
#import "ViewController08_WebView.h"

#import "TableViewSection.h"

@interface MainTableViewController ()

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *allViewControllers;
@property (nonatomic, strong) NSArray<TableViewSection *> *sections;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (UIColor *)ue_navigationBarBackgroundColor {
    return [UIColor systemGrayColor];
}

#pragma mark - Getter

- (NSArray<TableViewSection *> *)sections {
    if (!_sections) {
        _sections = [TableViewSection makeAllSections];
    }
    return _sections;
}

- (__kindof UIViewController *)viewControllerForItemType:(TableViewSectionItemType)itemType {
    switch (itemType) {
            // Basic
        case TableViewSectionItemTypeNavigationBarBackgroundColor:
            return [[ViewController01_BackgroundColor alloc] init];
        case TableViewSectionItemTypeNavigationBarBackgroundImage:
            return [[ViewController02_BackgroundImage alloc] init];
        case TableViewSectionItemTypeNavigationBarTransparent:
            return [[ViewController03_Transparent alloc] init];
        case TableViewSectionItemTypeNavigationBarTranslucent:
            return [[ViewController04_Translucent alloc] init];
        case TableViewSectionItemTypeNavigationBarShadowColor:
            return [[ViewController05_ShadowColor alloc] init];
        case TableViewSectionItemTypeNavigationBarShadowImage:
            return [[ViewController06_ShadowImage alloc] init];
        case TableViewSectionItemTypeNavigationBarCustomBackButtonImage:
            return [[ViewController07_CustomBackButtonImage alloc] init];
        case TableViewSectionItemTypeNavigationBarCustomBackButton:
            return [[ViewController08_CustomBackButton alloc] init];
        case TableViewSectionItemTypeNavigationBarModal:
            return [[LightNavigationController alloc] initWithRootViewController:[[ViewController09_Modal alloc] init]];
        case TableViewSectionItemTypeNavigationBarFullScreen:
            return [[ViewController10_FullScreen alloc] init];
        case TableViewSectionItemTypeNavigationBarScrollView:
            return [[ViewController11_ScrollView alloc] init];
        case TableViewSectionItemTypeNavigationBarScrollViewWithFullScreen:
            return [[ViewController12_ScrollViewWithFullScreen alloc] init];
            // Advanced
        case TableViewSectionItemTypeNavigationBarDisablePopGesture:
            return [[ViewController01_DisablePopGesture alloc] init];
        case TableViewSectionItemTypeNavigationBarFullPopGesture:
            return [[ViewController02_FullPopGesture alloc] init];
        case TableViewSectionItemTypeNavigationBarBackEventIntercept:
            return [[ViewController03_BackEventIntercept alloc] init];
        case TableViewSectionItemTypeNavigationBarJumpToViewController:
            return [[ViewController04_JumpToViewController alloc] init];
        case TableViewSectionItemTypeNavigationBarCustom:
            return [[ViewController05_Custom alloc] init];
        case TableViewSectionItemTypeNavigationBarClickEventHitToBack:
            return [[ViewController06_ClickEventHitToBack alloc] init];
        case TableViewSectionItemTypeNavigationBarScrollChangeNavigationBar:
            return [[ViewController07_ScrollChangeNavigationBar alloc] init];
        case TableViewSectionItemTypeNavigationBarWebView:
            return [[ViewController08_WebView alloc] initWithURL:[NSURL URLWithString:@"https://cn.bing.com/"]];
        default:
            break;
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCellIdentifer"];
    TableViewSectionItem *item = self.sections[indexPath.section].items[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%02zd: %@", indexPath.row + 1, item.title];
    cell.accessoryType = item.showDisclosureIndicator ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    if (item.itemType == TableViewSectionItemTypeNavigationBarModal) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TableViewSectionItem *item = self.sections[indexPath.section].items[indexPath.row];
    TableViewSectionItemType itemType = item.itemType;
    __kindof UIViewController *viewController = [self viewControllerForItemType:itemType];
    
    if (!viewController) return;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)viewController topViewController].title = item.title;
        [self presentViewController:viewController animated:YES completion:NULL];
    } else {
        viewController.title = item.title;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].title;
}

@end