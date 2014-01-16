//
//  SendReport.h
//  DetectMe
//
//  Created by a on 16/01/14.
//  Copyright (c) 2014 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Detector.h"


@protocol SendReportHelperDelegate
- (void) didSendReport;
- (void) requestForReportFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message;

@end

@interface SendReportHelper : NSObject <NSURLConnectionDelegate>
@property (strong, nonatomic) id<SendReportHelperDelegate> delegate;


- (void) sendReport: (Detector *) detector;


@end
