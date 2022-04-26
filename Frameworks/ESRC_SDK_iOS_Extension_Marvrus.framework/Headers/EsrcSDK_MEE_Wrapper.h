//
//  EsrcSDK_MEE_Wrapper.h
//  ESRC-SDK-iOS
//
//  Created by Hyunwoo Lee on 11/03/2021.
//  Copyright © 2022 ESRC. All rights reserved.
//

#ifndef EsrcSDK_MEE_Wrapper_h
#define EsrcSDK_MEE_Wrapper_h

#import <Foundation/Foundation.h>

@interface EsrcSDK_MEE_Wrapper : NSObject

+ (void) EsrcSDK_MEE_SetProperty: (double) positiveProbWeight param2: (double) negativeProbWeight param3: (double) neutralProbWeight param4: (double) positiveTimeWeight param5: (double) negativeTimeWeight param6: (double) neutralTimeWeight param7: (double) emotionMean param8: (double) emotionStd param9: (double) emotionBias param10: (double) normalProbWeight param11: (double) focusingProbWeight param12: (double) engagementProbWeight param13: (double) normalTimeWeight param14: (double) focusingTimeWeight param15: (double) engagementTimeWeight param16: (double) concentrationMean param17: (double) concentrationStd param18: (double) concentrationBias param19: (double) arousalHighZCLFWeight param20: (double) arousalLowZCLFWeight param21: (double) dominanceHighZCLFWeight param22: (double) dominanceLowZCLFWeight param23: (double) arousalHighTimeWeight param24: (double) arousalLowTimeWeight param25: (double) dominanceHighTimeWeight param26: (double) dominanceLowTimeWeight param27: (double) impactEmotionMean param28: (double) impactEmotionStd param29: (double) impactConcentrationMean param30: (double) impactConcentrationStd param31: (double) impactHeartRateMean param32: (double) impactHeartRateStd param33: (double) impactMean param34: (double) impactStd param35: (double) impactBias param36: (double) studyMean param37: (double) studyStd param38: (double) studyBias param39: (double) emotionClassThreshold1 param40: (double) emotionClassThreshold2 param41: (double) concentrationClassThreshold1 param42: (double) concentrationClassThreshold2 param43: (double) impactClassThreshold1 param44: (double) impactClassThreshold2 param45: (double) studyClassThreshold1 param46: (double) studyClassThreshold2;
+ (double) EsrcSDK_MEE_CalcEmotionIndex: (double) positiveProb param2: (double) negativeProb param3: (double) neutralProb param4: (double) positiveTime param5: (double) negativeTime param6: (double) neutralTime;
+ (double) EsrcSDK_MEE_NormalizeEmotionIndex: (double) emotionIndex;
+ (double) EsrcSDK_MEE_CalcConcentrationIndex: (double) normalProb param2: (double) focusingProb param3: (double) engagementProb param4: (double) normalTime param5: (double) focusingTime param6: (double) engagementTime;
+ (double) EsrcSDK_MEE_NormalizeConcentrationIndex: (double) concentrationIndex;
+ (double) EsrcSDK_MEE_CalcImpactIndex: (double) arousalHighZCLF param2: (double) arousalLowZCLF param3: (double) dominanceHighZCLF param4: (double) dominanceLowZCLF param5: (double) arousalHighTime param6: (double) arousalLowTime param7: (double) dominanceHighTime param8: (double) dominanceLowTime;
+ (double) EsrcSDK_MEE_NormalizeEmotionIndexCalcImpactIndex: (double) emotionIndex;
+ (double) EsrcSDK_MEE_NormalizeConcentrationIndexCalcImpactIndex: (double) concentrationIndex;
+ (double) EsrcSDK_MEE_NormalizeHeartRateCalcImpactIndex: (double) hr;
+ (double) EsrcSDK_MEE_NormalizeImpactIndex: (double) impactIndex;
+ (double) EsrcSDK_MEE_NormalizeStudyIndex: (double) studyIndex;
+ (int) EsrcSDK_MEE_ClassifyEmotionClass: (int) emotionIndex;
+ (int) EsrcSDK_MEE_ClassifyConcentrationClass: (int) concentrationIndex;
+ (int) EsrcSDK_MEE_ClassifyImpactClass: (int) impactIndex;
+ (int) EsrcSDK_MEE_ClassifyStudyClass: (int) studyIndex;

@end

#endif /* EsrcSDK_MEE_Wrapper_h */
