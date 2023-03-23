#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <Graph Utility Procs>

//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Authors: Mitchell Alton (mitchell.alton@colorado.edu)
//Code for drawing polygon & selecting them by Harald Stark (Harald.Stark@Aerodyne.com)

	constant c1H = 1.007825
	constant c12C = 12
	constant c13C = 13.003355
	constant c14N = 14.003074
	constant c15N = 15.000109
	constant c16O = 15.994915
	constant cCH2 = 14.01565
	constant cIsoprene = 68.06260
	//add new R_IUPACs here. Also add them to case in the BaseSet and Baseset2 functions. 

menu "Kendrick Analysis Panel"
	"Kendrick Analysis Panel"
end

//First makes the panel
Function KendrickAnalysisPanel()

	//Makes folder if it doesn't exist
	if(datafolderexists("GKA") == 1)
		//the data folder already exists
	else
		newdataFolder/O root:GKA
	endif

	make/DF/n=2/O root:GKA:CurrDir
	wave/DF CurrDir = root:GKA:CurrDir
	CurrDir[0] = getdataFolderDFR()
	cd root:GKA:
	CurrDir[1] = getdatafolderDFR()

	//If the window already exists, kills panel
	//for some reason my igor started adding 0 to it, so the rest of the code broke
	//added this as a fix
	KillWindow/Z GKA
	KillWindow/Z GKA0
	KillWindow/Z GKA1

	if(exists("Base") == 0)
		Variable/g root:GKA:Base = cCH2
	else
		NVAR Base = root:GKA:Base
		Base = cCH2
	endif

	if(exists("colorcheck") == 0)
		Variable/g root:GKA:colorcheck =0
	else
		NVAR colorcheck = root:GKA:colorcheck
		colorcheck=0
	endif
	
	if(exists("logcheck") == 0)
		Variable/g root:GKA:logcheck =0
	else
		NVAR logcheck = root:GKA:logcheck
		logcheck=0
	endif


	if(exists("IntensMin") == 0)
		Variable/g root:GKA:IntensMin =0
	else
		NVAR IntensMin = root:GKA:IntensMin
		IntensMin=0
	endif

	if(exists("IntensMax") == 0)
		Variable/g root:GKA:IntensMax =0
	else
		NVAR IntensMax = root:GKA:IntensMax
		IntensMax=0
	endif
	
	if(exists("IonCharge") == 0)
		Variable/g root:GKA:IonCharge =1
	else
		NVAR IonCharge = root:GKA:IonCharge
		IonCharge=1
	endif

	if(exists("sizecheck") == 0)
		Variable/g root:GKA:sizecheck = 0
	else
		NVAR sizecheck = root:GKA:sizecheck
		sizecheck=0
	endif
	
	if(exists("signcheck") == 0)
		Variable/g root:GKA:signcheck = 0
	else
		NVAR signcheck = root:GKA:signcheck
		signcheck=0
	endif
	
	if(exists("maxcheck") == 0)
		Variable/g root:GKA:maxcheck = 0
	else
		NVAR maxcheck = root:GKA:maxcheck
		maxcheck=0
	endif
		
	if(exists("numlargepoints") == 0)
		Variable/g root:GKA:numlargepoints = 0
	else
		NVAR numlargepoints = root:GKA:numlargepoints
		numlargepoints=0
	endif
		

	if(exists("threshcheck") == 0)
		Variable/g root:GKA:threshcheck = 0
	else
		NVAR threshcheck = root:GKA:threshcheck
		threshcheck=0
	endif
	
	if(exists("threshvalue") == 0)
		Variable/g root:GKA:threshvalue = 0
	else
		NVAR threshvalue = root:GKA:threshvalue
		threshvalue=0
	endif
	
	if(exists("mz_Path") == 0)
		String/g root:GKA:mz_Path
	else
		SVAR mz_Path = root:GKA:mz_Path
	endif

	if(exists("color") == 0)
		String/g root:GKA:color = "BlackBody"
	else
		SVAR color = root:GKA:color
		color = "BlackBody"
	endif

	if(exists("size_Path") == 0)
		String/g root:GKA:size_Path
	else
		SVAR size_Path = root:GKA:size_Path
	endif

	if(exists("Divisor") == 0)
		Variable/g root:GKA:Divisor
	else
		NVAR Divisor = root:GKA:divisor
	Endif
	Divisor = 1

	if(exists("ChosenBase") == 0)
		String/g root:GKA:ChosenBase
	else
		SVAR FullDivList = root:GKA:ChosenBase
	Endif

	if(exists("ChosenBase2") == 0)
		String/g root:GKA:ChosenBase2
	else
		SVAR FullDivList = root:GKA:ChosenBase2
	Endif


	//For once you draw a marquee and press calc, does calc with these values on points in Marquee
	if(exists("SecondBase") == 0)
		Variable/G root:GKA:SecondBase
	else
		NVAR SecondBase = root:GKA:SecondBase
	Endif

	if(exists("SecondDivisor") == 0)
		Variable/G root:GKA:SecondDivisor
	else
		NVAR SecondDivisor = root:GKA:SecondDivisor
	Endif
	SecondDivisor = 1

	if(exists("pathlistwave") == 0)
		String/G root:GKA:pathlistwave
	else
		SVAR pathlistwave = root:GKA:pathlistwave
	Endif
	pathlistwave = ""
	
	if(exists("newGKA") == 0)
		String/G root:GKA:newGKA
	else
		SVAR newGKA = root:GKA:newGKA
	Endif

	if(exists("newMK") == 0) //(generalized) Kendrick mass
		String/G root:GKA:newMK
	else
		SVAR newMK = root:GKA:newMK
	Endif

	//moves to the original folder
	cd currdir[0]

	string listfunc, colorlistfunc
	listfunc = "MakePathList()"

	//need to redeclare for making the panel
	SVAR pathlistwave=root:GKA:pathlistwave

	//Creates the panel
	Newpanel/K=1/M/N=GKA/W=(1,1,24,7)
	PopupMenu ChooseBase, size={300,20}, Pos={10,5}, proc=Baseset, mode=1, title="Choose Base", Value="-;CH2;16O;14N;12C;Isoprene"
	PopupMenu ChooseSecondBase, size={300,20}, Pos={10,120}, proc=Baseset2, mode=1, title="Choose Second Base", Value="-;CH2;16O;14N;12C;Isoprene"
	Popupmenu SetMZPath title="\f02m/z\f00 path",size={280,18},pos={200,5}, value=#listfunc, proc=mz_set
	Popupmenu SetColorWave title="Color wave",size={280,18},pos={420,5},focusring=1, value= "*COLORTABLEPOP*",popvalue="Rainbow", proc=color_set
	Variable m = 1 + WhichListItem("BlackBody", CTabList())
	PopupMenu SetColorWave mode=m
	popUpMenu SetColorWave FocusRing=0
	Popupmenu SetSizeWave title="Intensity wave",size={280,18},pos={200,30}, value=#listfunc, proc=size_set
	SetVariable ChooseDivisors title="Integer Scaling Factor (\f02X\f00)",pos={10,30},size={180,20}, value=root:GKA:Divisor, proc=valuecheck1
	SetVariable SecondDivisors title="Second Integer Scaling Factor (\f02X\f00)",size={230,20},pos={10,144},value=root:GKA:SecondDivisor, proc=valuecheck2
	SetVariable ThreshValueSet title="Threshold Percentage (%)",size={200,20},pos={440,155},value=root:GKA:ThreshValue,disable=1
	SetVariable MaxValueSet title="# of top peaks to remove",size={200,20},pos={440,115},value=root:GKA:numlargepoints,disable=1
	SetVariable IntensMinSet title="Min. Value for Color/Size Scaling",size={300,20}, pos={570,40},value=root:GKA:IntensMin,disable=1
	SetVariable IntensMaxSet title="Max. Value for Color/Size Scaling",size={300,20}, pos={570,60},value=root:GKA:IntensMax,disable=1
	CheckBox ColorbyIntens title="Color by intensity?",proc=colorcheckbox,pos={420,55}
	CheckBox SizebyIntens title="Size by intensity?",proc=sizecheckbox,pos={420,70}
	CheckBox LogColorSize title="Log scale for color/size?",proc=logcheckbox,pos={570,80}, disable =1
	CheckBox SetSignofSubtraction title="Mass Diff=Nominal-Kendrick? [Unchecked:Kendrick-Nominal]",proc=SignCheckBox,pos={420,175}
	CheckBox MaxCheck title="Remove x# of largest points?",proc=maxcheckbox,pos={420,95}
	CheckBox ThreshCheck title="Show top x % of signals?",proc=threshcheckbox,pos={420,135}
	TitleBox RangeInstructions pos={745,25}, size={300,30}, Title="0 for Auto scaling", frame=0, disable=1
	Button CalcREMKD title="Calculate GKA",size={150,40},pos={10,65},proc=GKA_Calc
	Button StartDraw title="Start drawing polygon", size={150,40}, pos={10,178},proc=StartDrawing
	Button MarqueeCalc title="Calculate again from polygon",size={180,40},pos={210,178},proc=GKA_CalcMarq
End

//Function updates current directory whenever user changes it
Function UpdateDirectories()
	wave/df currDir = root:GKA:CurrDir
	currDir[0] = getdataFolderDFR()
end

Function/S MakePathList()
	wave/df currDir = root:GKA:currdir 
	SVAR Pathlistwave = root:GKA:Pathlistwave
	pathlistwave = "-;" + wavelist("*",";","DIMS:1,TEXT:0")
	return pathlistwave
End

Function Valuecheck1(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	NVAR FirstDiv = root:GKA:divisor

		FirstDiv = round(FirstDiv)
		if (FirstDiv < 1)
			FirstDiv = 1
		endif
	
	return 0
End


Function Valuecheck2(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	NVAR SecondDiv = root:GKA:seconddivisor
	

		SecondDiv = round(SecondDiv)
		if (SecondDiv < 1)
			SecondDiv = 1
		endif

	return 0
End


//Popup menu for choosing a base
Function BaseSet(PU_Struct) :PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	UpdateDirectories()
	NVAR Base=root:GKA:Base
	SVAR ChosenBase=root:GKA:chosenbase
	wave/df currdir = root:GKA:currdir 

	Switch(PU_Struct.eventCode)
		Case 2: //Clicked on something
			cd currdir[1]
			ChosenBase = PU_Struct.popstr
			if (PU_Struct.popnum == 2)
				Base = cCH2
			elseif (PU_Struct.popnum == 3)
				Base = c16O
			elseif (PU_Struct.PopNum == 4)
				Base = c14N
			elseif (PU_Struct.PopNum == 5)
				Base = c12C
			elseif (PU_Struct.PopNum == 6)
				Base = cIsoprene
			endif
			cd currdir[0]
			break
		Case -1: //window closed
			break
	Endswitch
End

//Popup menu for choosing second base for marquee
Function Baseset2(PU_Struct) :PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	UpdateDirectories()

	wave/df currdir = root:GKA:currdir 
	NVAR SecondBase=root:GKA:secondbase
	SVAR ChosenBase2=root:GKA:chosenbase2

	Switch(PU_Struct.eventCode)
		Case 2: //Clicked on something
			cd currdir[1]
			ChosenBase2 = PU_Struct.popstr
			if (PU_Struct.popnum == 2)
				SecondBase = cCH2
			elseif (PU_Struct.popnum == 3)
				SecondBase = c16O
			elseif (PU_Struct.PopNum == 4)
				SecondBase = c14N
			elseif (PU_Struct.PopNum == 5)
				SecondBase = c12C
			elseif (PU_Struct.PopNum == 6)
				SecondBase = cIsoprene
			endif
			cd currdir[0]
			break
		Case -1: //window closed
			break
	Endswitch
End

Function Mz_Set(PU_Struct) :PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	UpdateDirectories()
	SVAR MZ_path = root:GKA:mz_path
	SVAR pathlistwave = root:GKA:Pathlistwave

	Switch(PU_Struct.eventCode)
		Case 2: //Clicked on something
			pathlistwave = wavelist("*",";","DIMS:1,TEXT:0")
			String menustring
			string currfold = getdatafolder(1)
			menustring = PU_Struct.PopStr
			MZ_Path = currfold+menustring
			break
		Case -1: //window closed
			break
	Endswitch
End

Function color_Set(PU_Struct) :PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	UpdateDirectories()
	SVAR color = root:GKA:color
	
	Switch(PU_Struct.eventCode)
		Case -3:
			color = (PU_Struct.popStr)
			break
		Case -2:
			color = (PU_Struct.popStr)
			break
		Case 2: //Clicked on something
			color = (PU_Struct.popStr)
			break
		Case -1: //window closed
			break
	Endswitch
End

Function size_Set(PU_Struct) :PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	UpdateDirectories()

	SVAR size_path = root:GKA:size_path
	SVAR pathlistwave = root:GKA:pathlistwave

	Switch(PU_Struct.eventCode)
		Case 2: //Clicked on something
			pathlistwave = wavelist("*",";","DIMS:1,TEXT:0")
			String menustring
			string currfold = getdatafolder(1)
			menustring = PU_Struct.PopStr
			size_path = currfold+menustring
			break
		Case -1: //window closed
			break
	Endswitch
End

Function colorcheckbox(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	NVAR colorcheck = root:GKA:colorcheck
	NVAR sizecheck = root:GKA:sizecheck
	NVAR logcheck = root:GKA:logcheck

	switch( cba.eventCode )
		case 2: // mouse up
			colorcheck = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	if (sizecheck==1 || colorcheck==1)
		SetVariable IntensMinSet disable=0
		SetVariable IntensMaxSet disable=0
		checkbox LogColorSize disable = 0
		TitleBox RangeInstructions disable=0
	else
		SetVariable IntensMinSet disable=1
		SetVariable IntensMaxSet disable=1
		TitleBox RangeInstructions disable=1
		checkbox LogColorSize disable = 1
	endif

	return 0
End

Function sizecheckbox(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	NVAR sizecheck = root:GKA:sizecheck
	NVAR colorcheck = root:GKA:colorcheck
	NVAR logcheck = root:GKA:logcheck 
	
	switch( cba.eventCode )
		case 2: // mouse up
			sizecheck = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	if (sizecheck==1 || colorcheck==1)
		SetVariable IntensMinSet disable=0
		SetVariable IntensMaxSet disable=0
		checkbox LogColorSize disable = 0
		TitleBox RangeInstructions disable=0
	else
		SetVariable IntensMinSet disable=1
		SetVariable IntensMaxSet disable=1
		checkbox LogColorSize disable = 1
		TitleBox RangeInstructions disable=1
	endif
	return 0
End


Function logcheckbox(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	NVAR sizecheck = root:GKA:sizecheck
	NVAR colorcheck = root:GKA:colorcheck
	NVAR logcheck = root:GKA:logcheck 
	
	switch( cba.eventCode )
		case 2: // mouse up
			logcheck = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	if (sizecheck==1 || colorcheck==1)
		SetVariable IntensMinSet disable=0
		SetVariable IntensMaxSet disable=0
		checkbox LogColorSize disable = 0
		TitleBox RangeInstructions disable=0
	else
		SetVariable IntensMinSet disable=1
		SetVariable IntensMaxSet disable=1
		checkbox LogColorSize disable = 1
		TitleBox RangeInstructions disable=1
	endif
	return 0
End

Function signcheckbox(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	NVAR signcheck = root:GKA:signcheck

	switch( cba.eventCode )
		case 2: // mouse up
			signcheck = cba.checked
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function threshcheckbox(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	NVAR threshcheck = root:GKA:threshcheck

	switch( cba.eventCode )
		case 2: // mouse up
			threshcheck = cba.checked
			if (cba.checked ==1)
				setvariable threshvalueset disable=0
			else
				setvariable threshvalueset disable=1
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function maxcheckbox(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	NVAR maxcheck = root:GKA:maxcheck

	switch( cba.eventCode )
		case 2: // mouse up
			maxcheck = cba.checked
			if (cba.checked ==1)
				setvariable maxvalueset disable=0
			else
				setvariable maxvalueset disable=1
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*******************************************************************************
//creates 2 waves
//MK and GKA 
//MK is the generalized Kendrick Mass MK(m/z,R)=m/z*X/R
//GKA is the generalized Kendrick analysis value GKA(m/z,R,X)=m/z*X/R-round(m/z*X/R)
function GKA_Calc(ctrlname) : ButtonControl
	String Ctrlname
	UpdateDirectories()
	wave/df currdir = root:GKA:currdir 
	cd currdir[1]
	//all variables should exist in this directory

	SVAR mz_path
	SVAR size_path
	SVAR color
	NVAR base, sizecheck, colorcheck, logcheck, threshcheck, threshvalue, intensmin, intensmax, signcheck, maxcheck, numlargepoints
	NVAR Divisor
	SVAR size_path
	SVAR Chosenbase
	variable iDiv, iPnt, thresh
	String sDiv
	Variable vDiv
	Variable Ioncharge = 1

	duplicate/o $mz_path, mz_Values

	if (colorcheck == 1 || threshcheck==1 ||sizecheck==1||maxcheck==1)
		if(strlen(size_path) > 0)
			if(numpnts($size_path) != numpnts($mz_path))
				//moves to the original folder
				cd currdir[0]
				Abort "Dimensions of intensity wave are inconsistent with m/z path wave"
			else
				Duplicate/o $size_path zIntensity
			endif
		else
			//moves to the original folder
			cd currdir[0]
			Abort "Define intensity wave"
		endif
	else
		Make/o/n=1 zIntensity = 1
	endif

	Duplicate/o $mz_path zThreshMask
	zThreshMask=0


		vDiv = Divisor
		sDiv = num2str(Divisor)

		duplicate/o mz_values MK, RMK, GKA
		
		//note that round() is used in this function. This is not allowed in 
		//quantity calculus, but programatically there is not another way to get the 
		//nominal mass of unknown compounds without using round()
		MK = mz_values*(vDiv/base) 
		RMK = round(MK) //round value of the MK
		
		if (signcheck==1)
			GKA = RMK - MK
		elseif (signcheck==0)
			GKA = MK - RMK
		endif
		
		//removes # of largest points from user input
		if (maxcheck==1)
			//Needs to have an intensity wave defined
			if (strlen(size_path) > 0)
				Duplicate/o zIntensity zIntenseMaxRemoved, zMaxMask
				zMaxMask = 1
				for (ipnt=0;ipnt<(numlargepoints);ipnt++)
					//removes largest points iteratively
					wavestats/Q/Z zIntenseMaxRemoved
					zIntenseMaxRemoved[V_maxloc] = 0
					zMaxMask[V_maxLoc] = nan
				endfor
				GKA *= zMaxMask
				zIntensity *= zMaxMask
			else
				//moves to the original folder
				cd currdir[0]
				Abort "Define intensity wave"
			endif
		endif

		if (threshcheck==1)
			//does the threshold masking
			//Needs to have an intensity wave defined
			//sort to determine percentiles 
			if (strlen(size_path) > 0)
				duplicate/o zIntensity, tempIntensity
				sort tempIntensity, tempIntensity
				wavestats/Q tempIntensity
				thresh = tempIntensity[round((V_npnts)/100*(100-threshvalue))] //intensity of threshvalue percentile
				for (ipnt=0;ipnt<(numpnts($size_path));ipnt++)
					
					if (zIntensity[ipnt]>=( thresh))
						zThreshMask[ipnt] = 1
					else
						zThreshMask[ipnt] = NaN
					endif
				endfor
				GKA *= zThreshMask
				zIntensity *= zThreshMask
			else
				//moves to the original folder
				cd currdir[0]
				Abort "Define intensity wave"
			endif
			killwaves tempIntensity
		endif

		//renames the GKA and MK waves for the next iteration, the rest are just overwritten
		string newMK, newGKA, newGKA2
		newMK = "Mk_"+ChosenBase+"_"+sDiv
		newGKA = "GKA_"+ChosenBase+"_"+sDiv
		newGKA2 = "GKA_"+ChosenBase+"_"+sDiv+"0"

		duplicate/o GKA, $newGKA
		duplicate/o MK, $newMK

		//kill windows that already have this name
		killwindow/Z $NewGKA
		killwindow/Z $NewGKA2

		Display/k=1/N=$NewGKA $newGKA vs mz_Values
		ModifyGraph mode=3,marker=19,msize=3,useMrkStrokeRGB=1
		if (sizecheck==1)
			if(logcheck==1)
				duplicate/o zintensity, zintensitylog
				zintensitylog = log(zintensity)
			else
				killwaves/Z zintensitylog
			endif
			if (IntensMin==0 && IntensMax==0)
				if(logcheck==1)
					ModifyGraph zmrkSize($NewGKA)={zIntensitylog,*,*,1,10}
				else
					ModifyGraph zmrkSize($NewGKA)={zIntensity,*,*,1,10}
				endif
			else
				if(logcheck==1)
					ModifyGraph zmrkSize($NewGKA)={zIntensitylog,log(IntensMin),log(IntensMax),1,10}
				else
					ModifyGraph zmrkSize($NewGKA)={zIntensity,IntensMin,IntensMax,1,10}
				endif
			endif
		endif
		if (colorcheck==1)
			if (IntensMin==0 && IntensMax==0)
				ModifyGraph zColor($NewGKA)={zIntensity,*,*,$color,0}
			else
				ModifyGraph zColor($NewGKA)={zIntensity,IntensMin,IntensMax,$color,0}
			endif	
			if(logcheck==1)
				modifygraph logzcolor=1
				colorscale/A=RC log=1
			else
				modifygraph logzcolor=0
				colorscale/A=RC log=0
			endif
			
		endif
		label bottom "Mass"
		label left "GKA"
		textbox "Base= " +chosenbase+"\rX= "+sDiv
		//for displaying z values when selected
		if (colorcheck==1 || sizecheck==1)
			InstallDataPanelHook()
		endif
	cd currdir[0]
end
//***********************************************************************

function GKA_CalcMarq(ctrlname) : ButtonControl
	String Ctrlname
	UpdateDirectories()
	Wave/df currdir = root:GKA:currdir 
	Wave W_inPoly = root:GKA:w_inpoly 
	cd currdir[1]
	
	Wave/Z w_inpoly
	
	//variables need to be in this folder already
	SVAR mz_path
	NVAR secondbase
	NVAR SecondDivisor
	SVAR size_path
	SVAR color
	SVAR ChosenBase2
	NVAR sizecheck, colorcheck, threshcheck, logcheck, threshvalue, numlargepoints, maxcheck, intensmin, intensmax, signcheck
	variable iDiv, ipoint
	String sDiv
	Variable vDiv, nummasses, ipnt, thresh
	string tracenames, GKAname, MKname

	//calculate which points are in the marquee and create a mask for the
	//ones that are
	duplicate/o $mz_path marquee_mask, mz_values, Anti_Marquee_mask
	marquee_mask = 0
	Anti_Marquee_mask = 0

	if((sizecheck==1) || (threshcheck==1) || (colorcheck == 1) || (maxcheck==1))
		if(strlen(size_path) > 0)
			if(numpnts($size_path) != numpnts($mz_path))
				//moves to the original folder
				cd currdir[0]
				Abort "Dimensions of intensity wave are inconsistent with m/z path wave"
			else
				Duplicate/o $size_path zMarqIntensity
				Duplicate/o $size_path zAntiMarqIntensity
			endif
		else
			//moves to the original folder
			cd currdir[0]
			Abort "Define intensity wave"
		endif
	endif

	//get wavenames. only works if marquee is on an GKA plot
	String WindowName
	WindowName=Winname(0,1)
	GKAname = wavename(Windowname, 0, 1)

	MKName = replacestring("GKA", GKAname, "Mk", 1)
	nummasses = numpnts($GKAname)

	duplicate/o $GKAname Marquee_GKA
	duplicate/o $MKname Marquee_MK

	//checks each point and updates mask wave
	for (ipoint=0; ipoint<(nummasses); iPoint++)
		if ((W_inPoly[ipoint]==1))
			marquee_mask[ipoint] = 1
			Anti_Marquee_mask[ipoint]=nan
		else
			marquee_mask[ipoint] = nan
			Anti_marquee_mask[ipoint]=1
		endif
	endfor

		vDiv = SecondDivisor
		sDiv = num2str(SecondDivisor)

		duplicate/o mz_values secMK, secRMK, secGKA, zthreshmask
		zthreshmask=0

		//actual GKA calcs
		secMK = mz_values*(vDiv/secondbase)
		secRMK = round(secMK)
		
		if (signcheck==1)
			secGKA = secRMK - secMK
		else
			secGKA = secMK - secRMK
		endif

		//applies mask
		secMK *= marquee_mask
		secGKA *= marquee_mask
		if((sizecheck==1) || (threshcheck==1) || (colorcheck == 1) || (maxcheck==1))
			zMarqIntensity *= marquee_mask
			zAntiMarqIntensity *= Anti_marquee_mask
		endif

//removes # of largest points from user input
		if (maxcheck==1)
			//Needs to have an intensity wave defined
			if (strlen(size_path) > 0)
				Duplicate/o zMarqIntensity zIntenseMaxRemoved, zMaxMask
				zMaxMask = 1
				for (ipnt=0;ipnt<(numlargepoints);ipnt++)
					//removes largest points iteratively
					wavestats/Q/Z zIntenseMaxRemoved
					zIntenseMaxRemoved[V_maxloc] = 0
					zMaxMask[V_maxLoc] = nan
				endfor
				secGKA *= zMaxMask
				zMarqIntensity *= zMaxMask
			else
				//moves to the original folder
				cd currdir[0]
				Abort "Define intensity wave"
			endif
		endif

		if (threshcheck==1)
			//does the threshold masking
			duplicate/o zMarqIntensity, tempMarqIntensity
			sort tempMarqIntensity, tempMarqIntensity
			wavestats/Q tempMarqIntensity
			thresh = tempMarqIntensity[round((V_npnts)/100*(100-threshvalue))] //intensity of threshvalue percentile
				
			for (ipnt=0;ipnt<(numpnts($size_path));ipnt++)
				if (zMarqIntensity[ipnt]>= thresh) 
					zThreshMask[ipnt] = 1
				else
					zThreshMask[ipnt] = NaN
				endif
			endfor
			secGKA *= zThreshMask
			zMarqIntensity *= zThreshMask
			killwaves tempMarqIntensity
		endif

		//renames the GKA and MK waves for the next iteration, the rest are just overwritten
		SVAR newMK
		SVAR newGKA
		string newGKA2
		String textboxstring
		newMK = "Mk_Marquee_"+ChosenBase2+"_"+sDiv
		newGKA = "GKA_Marquee_"+ChosenBase2+"_"+sDiv
		newGKA2 = "GKA_Marquee_"+ChosenBase2+"_"+sDiv + num2str(0)
		duplicate/o secMK, $newMK
		duplicate/o secGKA, $newGKA
		print winlist("*",";","win:1")
		killwindow/Z $NewGKA
		killwindow/Z $NewGKA2
		Display/k=1/n=$(NewGKA) $newGKA vs mz_Values
		ModifyGraph mode=3,marker=19,msize=3,useMrkStrokeRGB=1
		if (sizecheck==1)
		
			if(logcheck==1)
				duplicate/o zMarqIntensity, zMarqIntensitylog
				zMarqIntensitylog = log(zMarqIntensity)
			else
				killwaves/Z zMarqIntensitylog
			endif
			if (IntensMin==0 && IntensMax==0)
				if(logcheck==1)
					ModifyGraph zmrkSize($NewGKA)={zMarqIntensitylog,*,*,1,10}
				else
					ModifyGraph zmrkSize($NewGKA)={zMarqIntensity,*,*,1,10}
				endif
			else
				if(logcheck==1)
					ModifyGraph zmrkSize($NewGKA)={zMarqIntensitylog,log(IntensMin),log(IntensMax),1,10}
				else
					ModifyGraph zmrkSize($NewGKA)={zMarqIntensity,IntensMin,IntensMax,1,10}
				endif
			endif
		endif
		if (colorcheck==1)
			if (IntensMin==0 && IntensMax==0)
				ModifyGraph zColor($NewGKA)={zMarqIntensity,*,*,$color,0}
			else
				ModifyGraph zColor($NewGKA)={zMarqIntensity,IntensMin,IntensMax,$color,0}
			endif	
			if(logcheck==1)
				modifygraph logzcolor=1
				colorscale/A=RC log=1
			else
				modifygraph logzcolor=0
				colorscale/A=RC log=0
			endif
		endif
		label bottom "Mass"
		label left "GKA"
		textboxstring = "Base= " +chosenbase2+"\rX= "+sDiv
		TextBox/C/N=MarqueeStats textboxstring
		if (colorcheck==1 || sizecheck==1)
			InstallDataPanelHook()
		endif
//	endfor
	cd currdir[0]
end

//**************************************************************************
//Makes panel that displays info from GKA plot
//from Igor exchange, so not commented
Function DataValueHookFunc(Data)
	STRUCT WMWinHookStruct &Data
	Switch (Data.EventCode)
		Case 7:
			NVar ValP=root:Packages:DataValue:$(data.WinName):$("Csr"+Data.CursorName+"_ValP")
			NVar ValX=root:Packages:DataValue:$(data.WinName):$("Csr"+Data.CursorName+"_ValX")
			NVar ValY=root:Packages:DataValue:$(data.WinName):$("Csr"+Data.CursorName+"_ValY")
			NVar ValD=root:Packages:DataValue:$(data.WinName):$("Csr"+Data.CursorName+"_ValData")
			NVar MC=root:Packages:DataValue:$(data.WinName):MaxCursor
			SVar N_X=root:Packages:DataValue:$(data.WinName):S_NameX
			SVar N_Y=root:Packages:DataValue:$(data.WinName):S_NameY
			SVar N_D=root:Packages:DataValue:$(data.WinName):S_NameData
			Wave W_X=$N_X, W_Y=$N_Y, W_D=$N_D
			ValP=Data.PointNumber
			ValX=W_X[Data.PointNumber]
			ValY=W_Y[Data.PointNumber]
			ValD=W_D[Data.PointNumber]
			StrSwitch (Data.CursorName)
				Case "A":
				Case "B":
					If (MC>0)
						NVar AP=root:Packages:DataValue:$(data.WinName):CsrA_ValP
						NVar AX=root:Packages:DataValue:$(data.WinName):CsrA_ValX
						NVar AY=root:Packages:DataValue:$(data.WinName):CsrA_ValY
						NVar AD=root:Packages:DataValue:$(data.WinName):CsrA_ValData
						NVar BP=root:Packages:DataValue:$(data.WinName):CsrB_ValP
						NVar BX=root:Packages:DataValue:$(data.WinName):CsrB_ValX
						NVar BY=root:Packages:DataValue:$(data.WinName):CsrB_ValY
						NVar BD=root:Packages:DataValue:$(data.WinName):CsrB_ValData
						NVar ABP=root:Packages:DataValue:$(data.WinName):DeltaAB_ValP
						NVar ABX=root:Packages:DataValue:$(data.WinName):DeltaAB_ValX
						NVar ABY=root:Packages:DataValue:$(data.WinName):DeltaAB_ValY
						NVar ABD=root:Packages:DataValue:$(data.WinName):DeltaAB_ValData
						ABP=AP-BP
						ABX=AX-BX
						ABY=AY-BY
						ABD=AD-BD
					EndIf
					Break
				Default:
					Break
			EndSwitch
			Break
		Default:
			Break
	EndSwitch
	Return 0
End

Function CreateDataValuePanel()
	SVAR newGKA = root:GKA:newGKA
	Variable MaxCursor = 2
	Variable i
	String WindowName
	WindowName=Winname(0,1)
	NewPanel /EXT=2 /HOST=$WindowName /W=(0,20,(MaxCursor+1)*80+60,110) as "Data values from x,y,d triplets"
	TitleBox T_C, Pos={10,10}, Frame=0, FStyle=1, FixedSize=1, Title="Cursor"
	TitleBox T_P, Pos={10,30}, Frame=0, FStyle=1, FixedSize=1, Title="Point"
	TitleBox T_X, Pos={10,50}, Frame=0, FStyle=1, FixedSize=1, Title="X-Value"
	TitleBox T_Y, Pos={10,70}, Frame=0, FStyle=1, FixedSize=1, Title="Y-Value"
	TitleBox T_D, Pos={10,90}, Frame=0, FStyle=1, FixedSize=1, Title="Data"
	For (i=0;i<MaxCursor;i+=1)
		TitleBox $"T_Csr"+num2char(i+65), Pos={i*80+80,10}, Frame=0, FStyle=1, FixedSize=1, Title=num2char(i+65)
		ValDisplay $"Csr"+num2char(i+65)+"_P", Pos={i*80+80,30}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValP")
		ValDisplay $"Csr"+num2char(i+65)+"_X", Pos={i*80+80,50}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValX")
		ValDisplay $"Csr"+num2char(i+65)+"_Y", Pos={i*80+80,70}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValY")
		ValDisplay $"Csr"+num2char(i+65)+"_D", Pos={i*80+80,90}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValData")
	EndFor
	If (MaxCursor>1)
		TitleBox T_DeltaAB, Pos={i*80+80,10}, Frame=0, FStyle=1, FixedSize=1, Title="Delta AB"
		ValDisplay DeltaAB_P, Pos={i*80+80,30}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":DeltaAB_ValP")
		ValDisplay DeltaAB_X, Pos={i*80+80,50}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":DeltaAB_ValX")
		ValDisplay DeltaAB_Y, Pos={i*80+80,70}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":DeltaAB_ValY")
		ValDisplay DeltaAB_D, Pos={i*80+80,90}, bodyWidth=70, Frame=0, Title=" ", Value=#("root:Packages:DataValue:"+WindowName+":DeltaAB_ValData")
	EndIf
	Return 0
End

Function InstallDataPanelHook()
	Variable MaxCursor = 2
	SVAR size_path = root:GKA:size_path

	ShowInfo

	String WindowName=WinName(0,1)
	ShowInfo/W=$WindowName

	wave W_x=WaveRefIndexed(WindowName,0,2)
	wave W_y=WaveRefIndexed(WindowName,0,1)
	string w_ystring=NameOfWave(w_y)
	String zcolorinfo = WMGetRECREATIONInfoByKey("zColor(x)", traceinfo(WindowName, w_ystring, 0))
	String wavepath = StringFromList(0, zcolorinfo, ",")
	Duplicate/o $size_path w_data

	Variable i
	If (!DataFolderExists("root:Packages"))
		NewDataFolder root:Packages
	EndIf
	If (!DataFolderExists("root:Packages:DataValue"))
		NewDataFolder root:Packages:DataValue
	EndIf
	If (!DataFolderExists("root:Packages:DataValue:"+WindowName))
		NewDataFolder root:Packages:DataValue:$WindowName
	EndIf
	Variable /G root:Packages:DataValue:$(WindowName):MaxCursor=MaxCursor
	If (CreateDataValuePanel()==0)
		For (i=0;i<MaxCursor;i+=1)
			Variable /G $"root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValP"=NaN
			Variable /G $"root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValX"=NaN
			Variable /G $"root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValY"=NaN
			Variable /G $"root:Packages:DataValue:"+WindowName+":Csr"+num2char(i+65)+"_ValData"=NaN
		EndFor
		Variable /G root:Packages:DataValue:$(WindowName):DeltaAB_ValP=NaN
		Variable /G root:Packages:DataValue:$(WindowName):DeltaAB_ValX=NaN
		Variable /G root:Packages:DataValue:$(WindowName):DeltaAB_ValY=NaN
		Variable /G root:Packages:DataValue:$(WindowName):DeltaAB_ValData=NaN
		String /G root:Packages:DataValue:$(WindowName):S_NameX=GetWavesDataFolder(W_X,2)
		String /G root:Packages:DataValue:$(WindowName):S_NameY=GetWavesDataFolder(W_Y,2)
		String /G root:Packages:DataValue:$(WindowName):S_NameData=GetWavesDataFolder(W_Data,2)
		SetWindow $WindowName hook(DataValueHook)=DataValueHookFunc
	Else
		Return -1
	EndIf
	Return 0
End

//Written by Harald Stark - allows for you to draw a polygon instead of a square 
//to select points for the second calcualtion 
Function PolySelectAndCreate()
setdatafolder root:GKA:
String grName = winname(0,1)
Variable printFlag = 1
	
	polyInput()
	Wave yPoly, xPoly
End Function

Function extractDataFromWin(win, printFlag)
String win
Variable printFlag

	Variable nTr, i, nPoly, nDat
	String trList, currTr, polyList, datList, xName, yName, trName
	// try to find data and poly waves
	trList = traceNameList(win,";",1)
	polyList = ListMatch(trList,"*Poly")
	nPoly=itemsinList(polyList)
	datList = ListMatch(trList,"*Dat")
	nDat = itemsinList(datList)
	if (nPoly==1)
		yName = StringFromList(0,polyList)
		Wave yPoly = TraceNameToWaveRef(win,yName)
		Wave xPoly = XWaveRefFromTrace(win,yName)
	endif
	if (nPoly!=1 || !WaveExists(xPoly) || !WaveExists(yPoly))
		Prompt yName, "polygon trace name", popup trList
		DoPrompt "Please select polygon trace", yName
		if (V_Flag) // user clicked "cancel"
			return 0
		endif
		Wave/Z yPoly = TraceNameToWaveRef(win,yName)
		Wave/Z xPoly = XWaveRefFromTrace(win,yName)
		
	endif
	
	if (!WaveExists(xPoly) || !WaveExists(yPoly))
		if (printFlag)
			print "aborting, invalid polygon wave(s)"
		endif
		return 11
	endif
	
	
	if (nDat==1)
		yName = StringFromList(0,DatList)
		Wave yDat = TraceNameToWaveRef(win,yName)
		Wave xDat = XWaveRefFromTrace(win,yName)
	endif
	if (nDat!=1 || !WaveExists(xDat) || !WaveExists(yDat))
		//removes the polygon you just drew from the options of traces
		trlist = removefromlist("yPoly", trList)		
		Prompt yName, "Data trace name", popup trList
		DoPrompt "Please select trace that has GKA date (not Poly data)", yName
		if (V_Flag) // user clicked "cancel"
			return 0
		endif
		Wave/Z yDat = TraceNameToWaveRef(win,yName)
		Wave/Z xDat = XWaveRefFromTrace(win,yName)
		
	endif
	
	if (!WaveExists(xDat) || !WaveExists(yDat))
		if (printFlag)
			print "aborting, invalid Data wave(s)"
		endif
		return 13
	endif
	
	if (printFlag)
		printf "Found polygon x(%s), y(%s), data x(%s), y(%s) waves\r",NameOfWave(xPoly), NameOfWave(yPoly), NameOfWave(xDat),NameOfWave(yDat)
	endif
	
	extractData(yPoly, xPoly, yDat, xDat, printFlag)
	xName = GetWavesDataFolder(xDat,2)+"_sel"
	yName = GetWavesDataFolder(yDat,2)+"_sel"
	Wave/Z xSel = $xName
	Wave/Z ySel = $yName
	if (!WaveExists(xSel) || !WaveExists(ySel))
		if (printFlag)
			print "aborting, invalid selection wave(s)"
		endif
		return 15
	endif
	
	trName = NameOfWave(ySel)
	RemoveFromGraph/W=$win/Z $trName
	AppendToGraph/W=$win ySel vs xSel
	
	ModifyGraph/W=$win mode($trName)=3,marker($trName)=19,rgb($trName)=(2,39321,1)
	
End Function

Function extractData(yPoly, xPoly, yDat, xDat, printFlag)
Wave yPoly, xPoly, yDat, xDat
Variable printFlag
	
	Variable nIn, nTot, i, nFound
	String xWName, yWName
	FindPointsinPoly xDat, yDat, xPoly, yPoly
	Wave W_inPoly
	nIn = sum(W_inPoly)
	nTot = numpnts(xDat)
	if (printFlag)
		printf "Found %d points (%.1f %%) in polygon\r",nIn, 100*nIn/nTot
	endif
	xWName = GetWavesDataFolder(xDat,2)+"_sel"
	Make/N=(nTot)/O $xWName/WAVE=xSub
	yWName = GetWavesDataFolder(yDat,2)+"_sel"
	Make/N=(nTot)/O $yWName/WAVE=ySub
	For (i=0;i<nTot;i+=1)
		if (W_inPoly[i])
			xSub[nFound] = xDat[i]
			ySub[nFound] = yDat[i]
			nFound += 1
		else
			xSub[nFound] = NaN
			ySub[nFound] = NaN
			nFound += 1
		endif
	EndFor
	if (printFlag)
		printf "Created selection waves %s and %s\r",yWName,xWName
	endif
	
End Function

Function polyInput()
setdatafolder root:GKA:
String grName = winname(0,1)
Variable printFlag = 1

	Make/N=0/O yPoly,xPoly
	DoWindow/F $grname
	Button stopDraw 
	Button stopDraw,win=$grname, pos={1,1},size={120,22},proc=butt_stopDraw,title="Done drawing"
	GraphWaveDraw/W=$grname/O yPoly,xPoly //this also switches the graph into drawing mode
	// need to find a command to wait until the user is done drawing
	
End Function

Function butt_stopDraw(ba) : ButtonControl
STRUCT WMButtonAction &ba
Wave yPoly, xPoly//, yDat, xDat


	Variable printFlag
	switch( ba.eventCode )
		case 2: // mouse up
			printFlag = (ba.eventMod&2)>1 //shift key
			GraphNormal/W=$ba.win
			extractDataFromWin(ba.win, printFlag)
			KillControl/W=$ba.win $ba.ctrlName // make button disappear, could also consider changing its title to "start drawing", and call the input procedure then
			// can call extraction and plotting function(s) here
			HideTools
			wave/df currdir = root:GKA:currdir 
			cd currdir[0]
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function StartDrawing(ctrlname) : ButtonControl
	String Ctrlname
	PolySelectAndCreate()
end
