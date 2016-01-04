//
//  ICHPIB3577A.m
//  gpib
//
//  Created by Hyatt Moore
//  Copyright 2016 Informaton. All rights reserved.
//

#import "ICHPIB3577A.h"

@implementation ICHPIB3577A

//@synthesize charDumpNumFormatter;
//@synthesize charDumpNumFormatter;

@synthesize saveFilename;
@synthesize popupButtonOutlet;
@synthesize statusTextFieldOutlet;
@synthesize statusIndicator;

@synthesize buttonBoxOutlet;
@synthesize captureButtonOutlet;
@synthesize clearButtonOutlet;

@synthesize textFieldOutlet;

@synthesize	fileTextFieldOutlet;
@synthesize fileOutlet;

@synthesize HPIBdecimalCharacterSet;
@synthesize charDumpNumFormatter;

/*char *DeviceBuffer;
uint gpibBoardIndex;
uint gpibPrimaryAddress;
int gpibSecondaryAddress;
int timeOutDelaySec;
const bool assertEOI;
const int eosTerminationMode;  */

//implment this to initialize class variables (e.g. gui properties)
- (void)awakeFromNib {
	
	[popupButtonOutlet removeAllItems];
	NSArray * equipmentTitles = [NSArray arrayWithObjects:@"HP 3577A",@"Agilent 4395A",@"Krutchfield",@"Debug",nil];
	[popupButtonOutlet addItemsWithTitles:equipmentTitles];
	[statusIndicator setNumberOfTickMarks:0];
	[textFieldOutlet setEditable:FALSE];
	[statusTextFieldOutlet setEditable:FALSE];
	
//	[charDumpNumFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[charDumpNumFormatter setHasThousandSeparators:YES];
	[charDumpNumFormatter setThousandSeparator:@" "];
//	[charDumpNumFormatter setGroupingSeparator:@" "];
//	[charDumpNumFormatter setGroupingSize:3];
//	[charDumpNumFormatter setUsesGroupingSeparator:YES];
//	[textFieldOutlet insertText:@"200 000 000.000\n" ];

	//		[charDumpNumFormatter setThousandSeparator:@"\ "];
//			[textFieldOutlet insertText:[[charDumpNumFormatter numberFromString:@"200 000 000.000"] stringValue]];
	
	DeviceBuffer = (char *)malloc(MAX_BUFFER);
	
	DeviceID = -1;
	//	gpibBoardIndex = 0;
	//	gpibSecondaryAddress = 0;
	timeOutDelaySec = T10s;
	//	assertEOI = TRUE;
	//	eosTerminationMode = 0;
	[self selectDevice:self];
	HPIBdecimalCharacterSet  = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 ."];
	
}


- (float) stepSize:(traceStruct)traceData{
	return (traceData.count<=1)? 0 : (traceData.stopFreqMarker.floatValue - traceData.startFreqMarker.floatValue)/((float)traceData.count-1);
}


- (IBAction)selectDevice:(id)sender{
	if([self initDevice]){
		[self setInitialized:TRUE];
	}
	else {
		[self setInitialized:FALSE];
	}		
}


- (BOOL) initDevice{
	[statusTextFieldOutlet setStringValue:@"Initializing ..."];
	NSLog(@"Initializing ...");

	//get the device type
	if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"HP 3577A"]){
		gpibPrimaryAddress = 11; //replace with the value found or given by the user
	}
	else if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"Agilent 4395A"]){
		gpibPrimaryAddress = 5; //replace with the value found or given by the user
	}
	else if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"Krutchfield"]){
		gpibPrimaryAddress = -1;
	}
	else if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"Debug"]){
		gpibPrimaryAddress = 0;
		return TRUE;
	}
	
	if(gpibPrimaryAddress == -1){
		return FALSE;
	}
	else{

		DeviceID = ibdev(  /* Create a unit descriptor handle         */
						 gpibBoardIndex,              /* Board Index (GPIB0 = 0, GPIB1 = 1, ...) */
						 gpibPrimaryAddress,          /* Device primary address                  */
						 gpibSecondaryAddress,        /* Device secondary address                */
						 timeOutDelaySec,                    /* Timeout setting (T10s = 10 seconds)     */
						 assertEOI,                       /* Assert EOI line at end of write         */
						 eosTerminationMode);                      /* EOS termination mode                    */
	
//		NSString * initializationString = [NSString stringWithUTF8String:[self getDeviceResponse:"ID?"]];
//		NSArray * IDresponseArray = [initializationString componentsSeparatedByString:@","];
//		[statusTextFieldOutlet setStringValue: [NSString stringWithFormat:@"%@: Initialized successfully.",[IDresponseArray firstObject]]];	
		
		if (ibsta & ERR) {             /* Check for GPIB Error                    */
			[self GpibError:@"ibdev Error"]; 
			DeviceID = -1;
			return FALSE;
		}
		else {
			[self clearQuery:self];
			if (ibsta & ERR) {
				DeviceID = -1;
				[self GpibError:@"ibclr Error"];
				return FALSE;
			}
			
			return TRUE;
		}

	}
}

- (char *) test_getDeviceResponse: (char *)deviceRegister{
	DeviceID = 1;
	char * response = (char *)malloc(100);
	sprintf(response,"This just in from %s",deviceRegister);
	return response;
}

- (IBAction)queryDevice:(id)sender	
{	
	//prep the output textbox
	[textFieldOutlet setEditable:TRUE];

	NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterScientificStyle];

	//get the device type
	if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"HP 3577A"]){

		[self clearQuery:self];		
		
		//TKM = take measurement
		NSString * charDumpString = [NSString stringWithUTF8String:[self getDeviceResponse:"DCH"]];		   
		NSArray * charResponseArray = [charDumpString componentsSeparatedByString:@","];
		[textFieldOutlet insertText:charDumpString];
		//NSRange rangeOfHPIBCharacters = [[charResponseArray objectAtIndex:0] rangeOfCharacterFromSet:HPIBdecimalCharacterSet];
		//NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b(a|b)(c|d)\\b"
		//																	   options:NSRegularExpressionCaseInsensitive
		//																		 error:&error];
		
		[textFieldOutlet insertText:[NSString stringWithFormat:@"\n\nTRACE 1:\n%@\n",[charResponseArray objectAtIndex:0]]];			
		[textFieldOutlet insertText:[NSString stringWithFormat:@"Frequency range (%@ : %@)\n",[charResponseArray objectAtIndex:8],[charResponseArray objectAtIndex:9]]];			
		[textFieldOutlet insertText:[NSString stringWithFormat:@"Marker (Frequency, Magnitude):\n(%@, %@)\n",[charResponseArray objectAtIndex:4],[charResponseArray objectAtIndex:5]]];			
		[textFieldOutlet insertText:[NSString stringWithFormat:@"Source Amplitude: %@\n",[charResponseArray objectAtIndex:12]]];
		
		//Figure out which traces we need to collect...		
		//1. Reference level for Trace 1 REF LEVEL 0.000dBm
		//2. Amplitude level for Trace 1 /DIV 10.000dB
		//3. Ref level 2
		//4. Amp level 2
		//5.  MARKER 76 500 000.000Hz
		//6.  MAG(R)     -95.296dBm
		//7. Marker 2 freq
		//8. Marker 2 magnitude
		//9.  Trace 1 start freq START 0.000Hz
		//10. Trace 1 stop freq STOP 200 000 000.000Hz
		//11. Trace 2 start freq START 0.000Hz
		//12. Trace 2 stop freq STOP 200 000 000.000Hz
		//13. Source amplitude: AMPTD -10.0dBm
		//14. 
		//15. Entry block information (if bus diagnostics enabled)
		
		//Frequency range (START 0.000Hz : STOP 200 000 000.000Hz)
		//Marker (Frequency, Magnitude):
		//(, )
		//Source Amplitude: AMPTD -10.0dBm

		//It really depends on the provenance of the input. The safest thing to do is configure an NSNumberFormatter for the way your input is formatted and use -[NSFormatter numberFromString:] t
		//-107.549835E+00
		//-109.727753E+00
		//-112.270996E+00
		//-117.279251E+00
		//-106.807861E+00
		//-112.433929E+00
		//-126.610535E+00
		
		//		Trace 2 only
		//last entry says "Trace 2 INPUT ..."
		//	REF LEVEL 0.000dBm,/DIV 10.000dB,,,MARKER 123 500 000.000Hz,MAG(R)     -95.076dBm,,,START 0.000Hz,STOP 200 000 000.000Hz,START 0.000Hz,STOP 200 000 000.000Hz,AMPTD -10.0dBm,,Trace 2 INPUT "R"

		//	Trace 1 only 
		//last entry says "Trace 1 INPUT ..."
		// REF LEVEL 0.000dBm,/DIV 10.000dB,,,MARKER 123 500 000.000Hz,MAG(R)     -102.590dBm,,,START 0.000Hz,STOP 200 000 000.000Hz,START 0.000Hz,STOP 200 000 000.000Hz,AMPTD -10.0dBm,,Trace 1 INPUT "R" 
		
		
		//			Trace 1 and Trace 2
		//	last entry says ""
		// REF LEVEL 0.000dBm,/DIV 10.000dB,REF LEVEL 0.0deg,/DIV 45.000deg,MARKER 113 000 000.000Hz,MAG(R)     -97.018dBm,MARKER 113 000 000.000Hz,PHASE(R)   -57.771deg,START 0.000Hz,STOP 200 000 000.000Hz,START 0.000Hz,STOP 200 000 000.000Hz,AMPTD -10.0dBm,,
		
		//for(NSUInteger i=0; i<[charResponseArray count];i++){
		//	[textFieldOutlet insertText:[NSString stringWithFormat:@"%@\n",[charResponseArray objectAtIndex:i]]];
		//}

		if(sender == captureButtonOutlet){
			
			[self parseTraceFromCharDumpArray:charResponseArray];
			[self captureTrace];
			[self outputTrace];			

			//if capture1
			/*NSString * trace1DumpString = [NSString stringWithUTF8String:[self getDeviceResponse:"DT1"]];		   
			NSArray * trace1ResponseArray = [trace1DumpString componentsSeparatedByString:@","];
			trace1Data.count = [trace1ResponseArray count];
			for(NSUInteger i=0; i<[trace1ResponseArray count];i++){
				//NSNumber * myNumber = [nf numberFromString:[traceResponseArray objectAtIndex:i]];	
				trace1Data.amplitudeArray[i] = [[trace1ResponseArray objectAtIndex:i] floatValue];
				[textFieldOutlet insertText:[NSString stringWithFormat:@"%@\n",[trace1ResponseArray objectAtIndex:i]]];
			}	
            */
			//if capture2
/*
			NSString * trace2DumpString = [NSString stringWithUTF8String:[self getDeviceResponse:"DT1"]];		   
			NSArray * trace2ResponseArray = [trace2DumpString componentsSeparatedByString:@","];
			trace1Data.count = [trace2ResponseArray count];
			for(NSUInteger i=0; i<[trace2ResponseArray count];i++){
				//NSNumber * myNumber = [nf numberFromString:[traceResponseArray objectAtIndex:i]];	
				trace2Data.amplitudeArray[i] = [[trace2ResponseArray objectAtIndex:i] floatValue];
				[textFieldOutlet insertText:[NSString stringWithFormat:@"%@\n",[trace2ResponseArray objectAtIndex:i]]];
			}
 */
		}
	}

	else if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"Agilent 4395A"]){
		gpibPrimaryAddress = 5; //replace with the value found or given by the user
	}
	
	else if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"Krutchfield"]){
		[textFieldOutlet insertText:[NSString stringWithFormat:@"(%@)]\t not implemented",[sender title]]];
	}
	
	else if([[popupButtonOutlet titleOfSelectedItem] isEqualToString:@"Debug"]){
		HPIBdecimalCharacterSet  = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 ."];

		NSArray * charResponseArray = [NSArray arrayWithObjects:@"REF LEVEL 0.000dBm",@"/DIV 10.000dB",@"",@"",@"MARKER 76 500 000.000Hz",@"MAG(R)	-95.296dBm",@"",@"",@"START 0.000Hz",@"STOP 200 000 000.000Hz",@"",@"",@"AMPTD -10.0dBm",nil];		
	//	NSRange rangeOfHPIBCharacters = [[charResponseArray objectAtIndex:0] rangeOfCharacterFromSet:HPIBdecimalCharacterSet];
//		NSRange rangeOfHPIBCharacters = [@"STOP 200 000 000.000Hz" rangeOfCharacterFromSet:HPIBdecimalCharacterSet options:NSBackwardsSearch];
//		NSRange rangeOfHPIBCharacters2 = [@"200 000 000.000MHz" rangeOfCharacterFromSet:HPIBdecimalCharacterSet options:NSBackwardsSearch];
//		NSRange rangeOfHPIBCharacters3 = [@"200 000 000.000" rangeOfCharacterFromSet:HPIBdecimalCharacterSet];
		
		[self parseTraceFromCharDumpArray:charResponseArray];
		traceType = 4; //debugging
		[self captureTrace];
		traceType = 1; //debuggin again
		[self outputTrace];
			
//		markerStruct responseMarker = [self parseMarker:@"STOP 200 000 000.000Hz"];
		
		
		NSArray * dummyAmplitudesArray = [NSArray arrayWithObjects:@"-107.549835E+00", @"-109.727753E+00",
									 @"-112.270996E+00",
									 @"-117.279251E+00",
									 @"-106.807861E+00",
									 @"-112.433929E+00",
									 @"-126.610535E+00",nil];
		
		for(NSUInteger i=0; i<[dummyAmplitudesArray count];i++){
			NSNumber * myNumber = [nf numberFromString:[dummyAmplitudesArray objectAtIndex:i]];
			trace1Data.amplitudeArray[i] = [myNumber floatValue];
			[textFieldOutlet insertText:[NSString stringWithFormat:@"%@\n",[myNumber stringValue]]];			
		}
		
		//[textFieldOutlet insertText:@"200 000 000.000\n" ];
		[textFieldOutlet insertText:@"200 000 000.000\n" ];
		
		//		[charDumpNumFormatter setThousandSeparator:@"\ "];
		[nf setNumberStyle:NSNumberFormatterDecimalStyle];
		[nf setDecimalSeparator:@"."];
		[nf setHasThousandSeparators:YES];
		[nf setThousandSeparator:@" "];

		NSNumber * myNumber = [nf numberFromString:@"200 000 000.000"];
		[textFieldOutlet insertText:[NSString stringWithFormat:@"%0.3f\n",[myNumber floatValue]]];
				
//		[charDumpNumFormatter setThousandSeparator:@"\ "];
//		[textFieldOutlet insertText:[[charDumpNumFormatter numberFromString:@"200 000 000.000"] stringValue]];
//[textFieldOutlet insertText:[NSString stringWithFormat:@"(%@)]\t not implemented",[sender title]]];
		
	}
	
	[textFieldOutlet setEditable:FALSE];	
	[nf release];
}

- (void) outputTrace{
	
	float freq, freqDelta;
	
	[textFieldOutlet setEditable:TRUE];
	[textFieldOutlet setString:@""];
	if(traceType==1){
		[textFieldOutlet insertText:[NSString stringWithFormat:@"\n\n# %@\n",trace1Data.traceLabel]];		
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Amplitude Level: %f %@\n",trace1Data.amplitudeLevelMarker.floatValue, trace1Data.amplitudeLevelMarker.units]];		
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Frequency range (%@ : %@) %@\n",[trace1Data.startFreqMarker.numberValue stringValue], [trace1Data.stopFreqMarker.numberValue stringValue],trace1Data.startFreqMarker.units]];
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Marker: (%@%@, %0.3f%@)\n",[trace1Data.markerFreqMarker.numberValue stringValue], trace1Data.markerFreqMarker.units,[trace1Data.markerAmplMarker.numberValue floatValue], trace1Data.markerAmplMarker.units]];		
			
		[textFieldOutlet insertText: [NSString stringWithFormat:@"Frequency\t%@\n",[trace1Data.traceLabel substringToIndex:7]]];

		freq = trace1Data.startFreqMarker.floatValue;
		freqDelta = [self stepSize:trace1Data];
		for(NSUInteger i=0; i<trace1Data.count;i++){
			[textFieldOutlet insertText:[NSString stringWithFormat:@"%0.3f\t%0.3f\n",freq,trace1Data.amplitudeArray[i]]];			
			freq+=freqDelta;
		}	
	}

	else if(traceType==2){
		[textFieldOutlet insertText:[NSString stringWithFormat:@"\n\n# %@\n#  Amplitude Level: %@ %@\n",trace1Data.traceLabel,[trace2Data.amplitudeLevelMarker.numberValue stringValue], trace2Data.amplitudeLevelMarker.units]];		
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Frequency range (%@ : %@) %@\n",[trace2Data.startFreqMarker.numberValue stringValue], [trace2Data.stopFreqMarker.numberValue stringValue],trace2Data.startFreqMarker.units]];
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Marker: (%@%@, %@%@)\n",[trace2Data.markerFreqMarker.numberValue stringValue], trace2Data.markerFreqMarker.units,[trace1Data.markerAmplMarker.numberValue stringValue], trace2Data.markerAmplMarker.units]];		

		[textFieldOutlet insertText: [NSString stringWithFormat:@"Frequency\t%@\n",[trace1Data.traceLabel substringToIndex:7]]];

		freq = trace1Data.startFreqMarker.floatValue;
		freqDelta = [self stepSize:trace1Data];
		for(NSUInteger i=0; i<trace1Data.count;i++){
			[textFieldOutlet insertText:[NSString stringWithFormat:@"%0.3f\t%0.3f\n",freq,trace1Data.amplitudeArray[i]]];			
			freq+=freqDelta;
		}	
	}

	else if(traceType==3)
	{	
		[textFieldOutlet insertText:[NSString stringWithFormat:@"\n\n# TRACE 1\n#  Amplitude Level: %@ %@\n",[trace1Data.amplitudeLevelMarker.numberValue stringValue], trace1Data.amplitudeLevelMarker.units]];		
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Frequency range (%@ : %@) %@\n",[trace1Data.startFreqMarker.numberValue stringValue], [trace1Data.stopFreqMarker.numberValue stringValue],trace1Data.startFreqMarker.units]];
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Marker 1: (%@%@, %0.3f%@)\n",[trace1Data.markerFreqMarker.numberValue stringValue], trace1Data.markerFreqMarker.units,[trace1Data.markerAmplMarker.numberValue floatValue], trace1Data.markerAmplMarker.units]];		
			
		[textFieldOutlet insertText:[NSString stringWithFormat:@"\n\n# TRACE 2\n#  Amplitude Level: %@ %@\n",[trace2Data.amplitudeLevelMarker.numberValue stringValue], trace2Data.amplitudeLevelMarker.units]];		
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Frequency range (%@ : %@) %@\n",[trace2Data.startFreqMarker.numberValue stringValue], [trace2Data.stopFreqMarker.numberValue stringValue],trace2Data.startFreqMarker.units]];
		[textFieldOutlet insertText:[NSString stringWithFormat:@"#  Marker 2: (%@%@, %0.3f%@)\n",[trace2Data.markerFreqMarker.numberValue stringValue], trace2Data.markerFreqMarker.units,[trace2Data.markerAmplMarker.numberValue floatValue], trace2Data.markerAmplMarker.units]];		
			
		[textFieldOutlet insertText: @"Frequency\tTrace 1\tTrace 2\n"];

		freq = trace1Data.startFreqMarker.floatValue;
		freqDelta = [self stepSize:trace1Data];
		for(NSUInteger i=0; i<trace1Data.count;i++){
			[textFieldOutlet insertText:[NSString stringWithFormat:@"%0.3f\t%0.3f\t%0.3f\n",freq,trace1Data.amplitudeArray[i],trace2Data.amplitudeArray[i]]];			
			freq+=freqDelta;
		}
	}
	[textFieldOutlet setEditable:FALSE];
	
}

- (void) captureTrace{
	NSString * traceDumpString;
	NSArray * traceResponseArray;
	switch (traceType) {
		case 0: //nothing 
			
		break;


		case 1: 
			traceDumpString = [NSString stringWithUTF8String:[self getDeviceResponse:"DT1"]];		   
			traceResponseArray = [traceDumpString componentsSeparatedByString:@","];
			trace1Data.count = [traceResponseArray count];
			trace2Data.count = 0;
			for(NSUInteger i=0; i<[traceResponseArray count];i++){
				trace1Data.amplitudeArray[i] = [[traceResponseArray objectAtIndex:i] floatValue];
			}						
			break;
		case 2:
			traceDumpString = [NSString stringWithUTF8String:[self getDeviceResponse:"DT2"]];		   
			traceResponseArray = [traceDumpString componentsSeparatedByString:@","];
			
			//use trace1Data struct still b/c that is how it gets returned by the device when only using
			//trace 2 values (i.e. the device only stores trace 2 data as Trace 2 when it is displaying
			//both trace 1 and trace 2 values on the screen.
			trace2Data.count = [traceResponseArray count];
			trace1Data.count = 0;
			for(NSUInteger i=0; i<[traceResponseArray count];i++){
				trace2Data.amplitudeArray[i] = [[traceResponseArray objectAtIndex:i] floatValue];
			}			
			break;
		case 3:
			traceDumpString = [NSString stringWithUTF8String:[self getDeviceResponse:"DT1"]];		   
			traceResponseArray = [traceDumpString componentsSeparatedByString:@","];
			trace1Data.count = [traceResponseArray count];
			for(NSUInteger i=0; i<[traceResponseArray count];i++)
			{
				trace1Data.amplitudeArray[i] = [[traceResponseArray objectAtIndex:i] floatValue];
			}						

			traceDumpString = [NSString stringWithUTF8String:[self getDeviceResponse:"DT2"]];		   
			traceResponseArray = [traceDumpString componentsSeparatedByString:@","];
			trace2Data.count = [traceResponseArray count];
			for(NSUInteger i=0; i<[traceResponseArray count];i++)
			{
				trace2Data.amplitudeArray[i] = [[traceResponseArray objectAtIndex:i] floatValue];
			}						
			
			
			break;	
			
		case 4: //debugging
			traceResponseArray = [NSArray arrayWithObjects:@"-107.549835E+00", @"-109.727753E+00",
											@"-112.270996E+00",
											@"-117.279251E+00",
											@"-106.807861E+00",
											@"-112.433929E+00",
											@"-126.610535E+00",nil];
			trace1Data.count = [traceResponseArray count];
			for(NSUInteger i=0; i<[traceResponseArray count];i++){
				trace1Data.amplitudeArray[i] = [[traceResponseArray objectAtIndex:i] floatValue];
			}
			
			
			break;
			
		default:
			break;
	}
}

- (void) parseTraceFromCharDumpArray:(NSArray *)charDumpArray{

	traceType = 0;

	trace1Data.referenceLevelMarker = [self parseMarker:[charDumpArray objectAtIndex:0]];
	trace1Data.amplitudeLevelMarker = [self parseMarker:[charDumpArray objectAtIndex:1]];
	trace1Data.markerFreqMarker = [self parseMarker:[charDumpArray objectAtIndex:4]];
	trace1Data.markerAmplMarker = [self parseMarker:[charDumpArray objectAtIndex:5]];		
	trace1Data.startFreqMarker = [self parseMarker:[charDumpArray objectAtIndex:8]];
	trace1Data.stopFreqMarker = [self parseMarker:[charDumpArray objectAtIndex:9]];
	trace1Data.sourceAmplMarker = [self parseMarker:[charDumpArray objectAtIndex:12]];
	trace1Data.traceLabel = [charDumpArray objectAtIndex:14];

	trace2Data.referenceLevelMarker = [self parseMarker:[charDumpArray objectAtIndex:2]];
	trace2Data.amplitudeLevelMarker = [self parseMarker:[charDumpArray objectAtIndex:3]];
	trace2Data.markerFreqMarker = [self parseMarker:[charDumpArray objectAtIndex:6]];
	trace2Data.markerAmplMarker = [self parseMarker:[charDumpArray objectAtIndex:7]];		
	trace2Data.startFreqMarker = [self parseMarker:[charDumpArray objectAtIndex:10]];
	trace2Data.stopFreqMarker = [self parseMarker:[charDumpArray objectAtIndex:11]];
	trace2Data.sourceAmplMarker = [self parseMarker:[charDumpArray objectAtIndex:12]];
	

	if(([[trace1Data.traceLabel substringToIndex:7] isEqualToString:@"Trace 1"]==YES) || ([[trace1Data.traceLabel substringToIndex:7] isEqualToString:@"Trace 2"]==YES && [[charDumpArray objectAtIndex:10] length]==0)){
		traceType = 1;
	}
	else if([[trace1Data.traceLabel substringToIndex:7] isEqualToString:@"Trace 2"]==YES  && [[charDumpArray objectAtIndex:10] length]>0){
		traceType = 2;
	}
	else {
		traceType = 3;
	}

}

- (markerStruct) parseMarker:(NSString*)markerString{
	markerStruct marker;
	NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
	
	if(markerString!=nil && [markerString length]>0){		

		[nf setNumberStyle:NSNumberFormatterDecimalStyle];
		[nf setDecimalSeparator:@"."];
		[nf setHasThousandSeparators:YES];
		[nf setThousandSeparator:@" "];
	
		NSRange decimalRange = [self getDecimalValuesRange:markerString];

		NSNumber * myNumber = [nf numberFromString:[markerString substringWithRange:decimalRange]];
		[textFieldOutlet insertText:[NSString stringWithFormat:@"%0.3f\n",[myNumber floatValue]]];
		marker.floatValue = [myNumber floatValue];
		marker.numberValue = myNumber;
		marker.units = [markerString substringFromIndex:(decimalRange.location+decimalRange.length)];
	}
	return marker;
	
}

- (NSRange) getDecimalValuesRange:(NSString*)stringWithDecimalValues{
	HPIBdecimalCharacterSet  = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 ."];
	NSRange startRange = [stringWithDecimalValues rangeOfCharacterFromSet:HPIBdecimalCharacterSet];
	NSRange stopRange = [stringWithDecimalValues rangeOfCharacterFromSet:HPIBdecimalCharacterSet options:NSBackwardsSearch];
	NSRange decimalValuesRange= {.location = startRange.location, .length = stopRange.location-startRange.location+1};	
	return decimalValuesRange;
}

- (IBAction)clearQuery:(id)sender	
{	
	[textFieldOutlet setString:@""];
	ibclr(DeviceID);
}

- (IBAction)doSave:(id)pId{
	if(saveFilename==nil){
		[self doSaveAs: pId];
	}
	else{
		saveFID = fopen([saveFilename UTF8String], "a");
		if(saveFID){
			fprintf(saveFID,"%s",[[textFieldOutlet string ]UTF8String]);			
			fclose(saveFID);
			[statusTextFieldOutlet setStringValue:[NSString stringWithFormat:@"Saved to %@",saveFilename]];	
		}
		else {
			NSLog(@"Unable to open the selected file (%@) for saving.  Sorry.\n",saveFilename);
			[statusTextFieldOutlet setStringValue:[NSString stringWithFormat:@"Could not save to  %@",saveFilename]];	
		}

	}
}

//user selects a save file
- (IBAction)doSelectSaveAsFile:(id)pId;{
	NSSavePanel *tvarNSSavePanelObj	= [NSSavePanel savePanel];
	int tvarInt	= [tvarNSSavePanelObj runModal];	
	if(tvarInt == NSOKButton){
     	NSLog(@"doSaveAs we have an OK button");	
        NSString * tvarDirectory = [[tvarNSSavePanelObj directoryURL] absoluteString]; // directory is no longer allowed as of 10.6
		
		NSURL * absfilename = [tvarNSSavePanelObj URL];
		NSLog(@"doSaveAs directory = %@",tvarDirectory);
		
		saveFilename = [absfilename path];
		//save to file then..
		if(saveFilename!=nil)
			[fileTextFieldOutlet setStringValue:saveFilename];
			NSLog(@"The savefilename is %@\n",saveFilename);
		return;
	} else if(tvarInt == NSCancelButton) {
		saveFilename = nil;
     	NSLog(@"doSaveAs we have a Cancel button");
     	return;
	} else {
     	NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3d",tvarInt);
     	return;
	} 	
}

- (IBAction)doSaveAs:(id)pId{
	[self doSelectSaveAsFile:pId];
	if(saveFilename!=nil){
		[self doSave:pId];
	}
}

- (void) setInitialized: (BOOL)initialized{
	if(initialized){
		[clearButtonOutlet setEnabled:TRUE];
		[captureButtonOutlet setEnabled:TRUE];

		[statusIndicator setIntValue:1];		
		[statusTextFieldOutlet setStringValue: @"Initialized successfully."];	
		
		NSLog(@"Make the button green");
		NSLog(@"Initialized successfully.");
	}
	else{
		//[statusTextFieldOutlet setRichText:TRUE];
		[statusTextFieldOutlet setStringValue:@"Failed to initialize."];	
		NSLog(@"Failed to initialize");
		[self takeGpibOffline];
		
	}
}

- (void) instructDevice: (char *)instruction strlen:(uint)instructionStrlen{
	ibwrt(DeviceID, instruction, instructionStrlen);
}

- (NSString*) getDeviceText{
	NSString * deviceText = [NSString stringWithUTF8String:[self getDeviceResponse:"DCH"]];
    return deviceText;
}


- (char *) getDeviceResponse: (char *)Register{
	
	//	[self clearQuery:self];
	//	ibwrt(DeviceID,"SM2",3);
	//	ibwrt(DeviceID,"RST",3);
	
	ibwrt(DeviceID, Register, 3);     /* Send the identification query command   */
	if (ibsta & ERR) {
		[self GpibError:@"Device Write Error"];
	}
	else {
		NSLog(@"Write/Read from %c%c%c (%i).\n",Register[0],Register[1],Register[2],DeviceID);
		//		ibwait(DeviceID,END);  //wait for the I/O to finish
		ibrd(DeviceID, DeviceBuffer, MAX_BUFFER-1);     /* Read up to 100 bytes from the device    */	
		//		DeviceBuffer[ibcntl] = '\0';         /* Null terminate the ASCII string         */
		if (ibsta & ERR) {
			[self GpibError:@"Device Read Error" ];
		}			
	}

	//ibwrt(DeviceID,"SM1",3);
			  
	return DeviceBuffer;
}

- (void) takeGpibOffline {
	//[buttonBoxOutlet setEnabled:FALSE];
	[clearButtonOutlet setEnabled:FALSE];
	[captureButtonOutlet setEnabled:FALSE];

	/* Call ibonl to take the device and interface offline */
    ibonl (DeviceID,0);
    ibonl (gpibBoardIndex,0);	
	[statusIndicator setIntValue:0];
	NSLog(@"Make the button red");
}

/*****************************************************************************
 *                      Function GPIBERROR
 * This function will notify you that a NI-488 function failed by
 * printing an error message.  The status variable IBSTA will also be
 * printed in hexadecimal along with the mnemonic meaning of the bit
 * position. The status variable IBERR will be printed in decimal
 * along with the mnemonic meaning of the decimal value.  The status
 * variable IBCNTL will be printed in decimal.
 *
 * The NI-488 function IBONL is called to disable the hardware and
 * software.
 *
 * The EXIT function will terminate this program.
 *****************************************************************************/
- (void) GpibError:(NSString *)errorMsg {
 //   NSLog([errorMsg String]);
	NSLog(@"ibsta = 0x%x  <", ibsta);
	NSLog(@" >\n");
	NSString * errorCode;
	if (ibsta & ERR )  {errorCode = @" ERR";}
	if (ibsta & TIMO)  {errorCode = @" TIMO";}
	if (ibsta & END )  {errorCode = @" END";}
	if (ibsta & SRQI)  {errorCode = @" SRQI";}
	if (ibsta & RQS )  {errorCode = @" RQS";}
	if (ibsta & CMPL)  {errorCode = @" CMPL";}
	if (ibsta & LOK )  {errorCode = @" LOK";}
	if (ibsta & REM )  {errorCode = @" REM";}
	if (ibsta & CIC )  {errorCode = @" CIC";}
	if (ibsta & ATN )  {errorCode = @" ATN";}
	if (ibsta & TACS)  {errorCode = @" TACS";}
	if (ibsta & LACS)  {errorCode = @" LACS";}
	if (ibsta & DTAS)  {errorCode = @" DTAS";}
	if (ibsta & DCAS)  {errorCode = @" DCAS";}
	 
	NSLog(@"iberr = %d", iberr) ;
	if (iberr == EDVR) {errorCode = @" EDVR <System Error>";}
	if (iberr == ECIC) {errorCode = @" ECIC <Not Controller-In-Charge>";}
	if (iberr == ENOL) {errorCode = @" ENOL <No Listener>";}
	if (iberr == EADR) {errorCode = @" EADR <Address error>";}
	if (iberr == EARG) {errorCode = @" EARG <Invalid argument>";}
	if (iberr == ESAC) {errorCode = @" ESAC <Not System Controller>";}
	if (iberr == EABO) {errorCode = @" EABO <Operation aborted>";}
	if (iberr == ENEB) {errorCode = @" ENEB <No GPIB board>";}
	if (iberr == EOIP) {errorCode = @" EOIP <Async I/O in progress>";}
	if (iberr == ECAP) {errorCode = @" ECAP <No capability>";}
	if (iberr == EFSO) {errorCode = @" EFSO <File system error>";}
	if (iberr == EBUS) {errorCode = @" EBUS <GPIB bus error>";}
	if (iberr == ESTB) {errorCode = @" ESTB <Status byte lost>";}
	if (iberr == ESRQ) {errorCode = @" ESRQ <SRQ stuck on>";}
	if (iberr == ETAB) {errorCode = @" ETAB <Table Overflow>";}

	NSLog(@"\n");
	NSLog(@"ibcntl = %ld\n", ibcntl);
	NSLog(@"\n");
	
	[statusTextFieldOutlet setStringValue:[errorMsg stringByAppendingString:errorCode]];
	//[self takeGpibOffline];

	ibclr(DeviceID);

}
@end
