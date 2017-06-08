//
//  AppDelegate.m
//  MonitorBarHelper
//
//  Created by wing on 2017/3/30.
//  Copyright © 2017 Magic Install. All rights reserved.
//

#import "AppDelegate.h"
#import "smc.h"
#import "SMCValue.h"

#define SHOW_WELCOME_DEFAULT (@"PreferencesShowWelcome")

@interface AppDelegate ()

@property (unsafe_unretained) IBOutlet NSTextView *infoText;
@property (weak) IBOutlet NSButton *dontShowBtn;

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate {
    NSUserDefaults *userDefaults;
}

- (void)dumpSMC {
    // 建立底层SMC 连接
    io_connect_t smcConnection;
    if (kIOReturnSuccess == SMCOpen("AppleSMC", &smcConnection)) {
        NSLog(@"SMC 内核端口已连接");
        
        SMCValue *smcValue = [[SMCValue alloc] init];
        if (kIOReturnSuccess == SMCReadKey(smcConnection, "#KEY", [smcValue getReference])) {
            uint32 keysCount = [smcValue getUInt32Value];
            NSLog(@"#KEY %d", keysCount);
            [[_infoText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"#KEY %d \n", keysCount]]];
            
            // 枚举全部传感器
            SMCKeyData_t inputStructure, outputStructure;
            memset(&inputStructure, 0, sizeof(SMCKeyData_t));
            inputStructure.data8 = (UInt8)SMC_CMD_READ_INDEX;
            
            for (UInt32 i = 0; i < keysCount; i ++) {
                // 取得Key 名
                inputStructure.data32 = i;
                memset(&outputStructure, 0, sizeof(SMCKeyData_t));
                if (kIOReturnSuccess == SMCCall(smcConnection, KERNEL_INDEX_SMC, &inputStructure, &outputStructure)) {
                    
                    UInt32Char_t key;
                    key[0] = outputStructure.key >> 24;
                    key[1] = outputStructure.key >> 16;
                    key[2] = outputStructure.key >> 8;
                    key[3] = outputStructure.key;
                    [[_infoText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:
                                                                     [NSString stringWithFormat:@"%-4s ",
                                                                      key]]];
                    
                    // 取得key 数据
                    if (kIOReturnSuccess == SMCReadKey(smcConnection, key, [smcValue getReference])) {
                        [[_infoText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:
                                                                         [NSString stringWithFormat:@"%@ %2d %@\n",
                                                                          [smcValue dataType],
                                                                          (UInt32)[smcValue dataSize],
                                                                          [smcValue getData]]]];
                        
                    } else {
                        [[_infoText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:
                                                                         [NSString stringWithFormat:@"value lost \n"]]];
                        continue;
                    }

                    
                } else {
                    [[_infoText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:
                                                                     [NSString stringWithFormat:@"KEY(%d) lost \n", i]]];
                    continue;
                }
                
                
            }
            //NSLog(@"SMCReadKey(\(key)) 失败!");
            
        } else {
            [[_infoText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"#KEY lost \n"]]];
            NSLog(@"取得SMC Keys 总数失败!");
        }
        
        [_infoText setFont:[NSFont userFixedPitchFontOfSize:11.0]];
        
        // 断开底层SMC 连接
        if (kIOReturnSuccess == SMCClose(smcConnection)) {
            NSLog(@"SMC 内核端口已注销");
        } else {
            NSLog(@"SMC 内核端口注销出错!");
        }
        
    } else {
        NSLog(@"SMCOpen 失败!");
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"Helper application launching");
    
    // 运行主体
    NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
    pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
    NSString *path = [NSString pathWithComponents:pathComponents];
    Boolean canRun = [[NSWorkspace sharedWorkspace] launchApplication:path];
    NSLog(@"%@ %@", path, canRun ? @"run" : @"lost");
    
    // TODO: 读取不再显示开关预设...
    userDefaults = [NSUserDefaults standardUserDefaults];
    // lldb: p [userDefaults setInteger:0 forKey:@"PreferencesShowWelcome"]; // 测试用, 重新设置为初始状态
    switch ([userDefaults integerForKey:SHOW_WELCOME_DEFAULT]) {
        case -1:
            [NSApp terminate:nil];
            break;
            
        case 0: // 一般是第一次打开
            [_dontShowBtn setState:NSOnState];
        default: // 1
            [self dumpSMC];
            break;
    }
    
    

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"Helper application terminate");
    
    // TODO: 不再显示开关写入预设...
    NSInteger show = ([_dontShowBtn state] == NSOnState) ? -1 : 1;
    [userDefaults setInteger:show forKey:SHOW_WELCOME_DEFAULT];
}


- (IBAction)onCloseClick:(id)sender {
    [NSApp terminate:nil];
}

- (IBAction)onSendClick:(id)sender {
    // TODO: 发送Email...
}

@end
