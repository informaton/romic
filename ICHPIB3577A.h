//
//  ICHPIB3577A.h
//  gpib
//
//  Created by Hyatt Moore.
//  Copyright 2016 Informaton. All rights reserved.
//
#include <stdio.h>
#import <Cocoa/Cocoa.h>
#import <NI488/ni488.h>
#include "ni488.h"
static const int MAX_BUFFER = 40000;

typedef struct {
	float floatValue;
	NSNumber * numberValue;
	NSString *units;	
} markerStruct, *markerStructPtr;

typedef struct {		
	float freqArray[401];
	float amplitudeArray[401];
	int   count;
	markerStruct amplitudeLevelMarker;
	markerStruct referenceLevelMarker;
	markerStruct startFreqMarker;
	markerStruct stopFreqMarker;
	markerStruct markerAmplMarker;
	markerStruct markerFreqMarker;
	markerStruct sourceAmplMarker;
	NSString *	traceLabel;
} traceStruct, *traceStructPtr;

@interface ICHPIB3577A : NSObject {

	NSCharacterSet *HPIBdecimalCharacterSet;
	uint traceType; //0 = no trace data; 1 = trace 1 only; 2 = trace 2 only; 3 = both trace 1 and trace 2 
	
	int gpibPrimaryAddress;
	int gpibSecondaryAddress;
	int timeOutDelaySec;
	bool assertEOI;
	int eosTerminationMode;          
	int DeviceID;
	char *DeviceBuffer;
	uint gpibBoardIndex;
	traceStruct trace1Data;
	traceStruct trace2Data;
	NSNumberFormatter * charDumpNumFormatter;
//	[nf setNumberStyle:NSNumberFormatterScientificStyle];

	id  popupButtonOutlet;
    id	statusTextFieldOutlet;
	id	statusIndicator;
	
	id	buttonBoxOutlet;
	id  captureButtonOutlet;
	id  clearButtonOutlet;
	
	id  textFieldOutlet;
	
	
//	id  fileDisclosureButtonOutlet;
//@property (nonatomic, retain) IBOutlet id  fileDisclosureButtonOutlet;

	id	fileTextFieldOutlet;
	id  fileOutlet;
	


	NSString * saveFilename;
	FILE * saveFID;
}
@property (nonatomic, retain) NSCharacterSet * HPIBdecimalCharacterSet;
@property (nonatomic, retain) NSNumberFormatter * charDumpNumFormatter;

//@property (nonatomic, retain) NSNumberFormatter * charDumpNumberFormatter;


@property (nonatomic, retain) IBOutlet NSString * saveFilename;

@property (nonatomic, retain) IBOutlet id  popupButtonOutlet;
@property (nonatomic, retain) IBOutlet id  statusTextFieldOutlet; //to put NSLog output
@property (nonatomic, retain) IBOutlet id  statusIndicator;//should be set to 0 or 1 (1=okay/green; 0=bad/empty)

@property (nonatomic, retain) IBOutlet id  buttonBoxOutlet;
@property (nonatomic, retain) IBOutlet id  captureButtonOutlet;
@property (nonatomic, retain) IBOutlet id  clearButtonOutlet;

@property (nonatomic, retain) IBOutlet id  textFieldOutlet;

@property (nonatomic, retain) IBOutlet id  fileOutlet;
@property (nonatomic, retain) IBOutlet id  fileTextFieldOutlet;


- (IBAction)selectDevice:(id)sender;
- (IBAction)clearQuery:(id)sender;
- (IBAction)queryDevice:(id)sender;    
- (IBAction)doSelectSaveAsFile:(id)pId; 
- (IBAction)doSaveAs:(id)pId; 
- (IBAction)doSave:(id)pId; 
- (BOOL)initDevice;
- (char *)test_getDeviceResponse:(char *)deviceRegister;
- (void) instructDevice:(char*)instruction strlen:(uint)instructionStrlen;
- (char *)getDeviceResponse: (char *)deviceRegister;
- (void) GpibError:(NSString *)errorMsg;
- (void) setInitialized: (BOOL)initialized;
- (void) takeGpibOffline;
- (float) stepSize:(traceStruct)traceData;
- (markerStruct) parseMarker:(NSString*)markerString;
- (NSRange) getDecimalValuesRange:(NSString*)stringWithDecimalValues;
- (void) parseTraceFromCharDumpArray:(NSArray*)charDumpArray;
- (void) captureTrace;
- (void) outputTrace;

@end