//
//  ViewController07_CustomBackButtonImage.m
//  UINavigationExtensionDemo
//
//  Created by lidan on 2020/10/26.
//

#import "ViewController07_CustomBackButtonImage.h"

@interface ViewController07_CustomBackButtonImage ()

@end

@implementation ViewController07_CustomBackButtonImage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIImage *)ue_backImage {
    return [UIImage imageNamed:@"NavigationBarBack"];
}

@end