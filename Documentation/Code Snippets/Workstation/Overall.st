(*   This code executes when there is a lock to process *)

IF (LEN_INT (IN := Current_Lock) > 0) THEN 
  
  	(* Time stamp when they start the lock assembly  *)
  
 	IF NOT Time_To_Assemble_Lock_ON then		
  		Time_To_Assemble_Lock_ON := TRUE;		(* this goes on right after they scan in a lock part number *)
		Get_Timestamp := TRUE;			(* this grabs the current_timestamp and then it is turned off immediately after *)
		IF LEN_INT(IN:=Current_Lock) > 0 THEN
			Log_Current_Lock := Current_Lock;
		END_IF;		
	END_IF;


	(* first find lock offset  *)
	IF NOT Lock_Is_Found then
		Temp_Index :=0;
		REPEAT
			IF Whats_In_Lock[0][Temp_Index] = Current_Lock THEN
				Lock_Is_Found  := TRUE;
			END_IF;
			Temp_Index := Temp_Index+1;

		UNTIL Lock_Is_Found or Temp_Index >= 9			(* If a lock is found or no lock is found parsing through first array  *)
		END_REPEAT;
	
		IF Temp_Index = 9 then
			Lock_Not_Found := TRUE;			(* lock is not in list   MAJOR ERROR*)
		Else
			Current_Lock_Offset := Temp_Index;    (* lock is found and established where in the double array to use *)
			Current_Part_Offset :=0;
		END_IF;
	END_IF;

	(* Now find which BIN and process *)
	IF NOT Bin_Is_Found AND NOT Lock_Completed THEN
		Temp_Index :=0;
		IF (LEN_INT(IN := Whats_In_Lock[Current_Lock_Offset][Current_Part_Offset]) < 1) then
			Lock_Completed := TRUE;
			Log_Time_Assemble_Lock := TRUE;
			Time_To_Assemble_Lock_ON := FALSE;
			Current_Lock := '';
			Log_Time_Assemble_Lock_Elapsed := Time_to_Assemble_Lock_Elapsed;
		END_IF;
		REPEAT
			IF  Whats_in_Bin[Temp_Index] = Whats_In_Lock[Current_Lock_Offset][Current_Part_Offset] THEN
				Bin_Is_Found  := TRUE;
				Current_Bin_Offset := Temp_Index;
			END_IF;
			Temp_Index := Temp_Index+1;

		UNTIL Bin_Is_Found or Temp_Index >= 23	or Lock_Completed		(* If a bin is found  *)
		END_REPEAT;
	END_IF;

	(*  if Lock is found and Bin is found then put light on sensor to prompt them to grab that bins part *)

	IF Lock_Is_Found AND Bin_Is_Found THEN

		(* First turn ON right light *)

		CASE Current_Bin_Offset OF
                
			1:	SensorLight_1 := TRUE;
			2:	SensorLight_2 := TRUE;
			3:	SensorLight_3 := TRUE;
			4:	SensorLight_4 := TRUE;
			5:	SensorLight_5 := TRUE;
			6:	SensorLight_6 := TRUE;
			7:	SensorLight_7 := TRUE;
			8:	SensorLight_8 := TRUE;
			9:	SensorLight_9 := TRUE;
			10:	SensorLight_10 := TRUE;
			11:	SensorLight_11 := TRUE;
			12:	SensorLight_12 := TRUE;
			13:	SensorLight_13 := TRUE;
			14:	SensorLight_14 := TRUE;
			15:	SensorLight_15 := TRUE;
			16:	SensorLight_16 := TRUE;
			17:	SensorLight_17 := TRUE;
			18:	SensorLight_18 := TRUE;
			19:	SensorLight_19 := TRUE;
			20:	SensorLight_20 := TRUE;
			21:	SensorLight_21 := TRUE;
			22:	SensorLight_22 := TRUE;
			23:	SensorLight_23 := TRUE;
			24:	SensorLight_24 := TRUE;

                  ELSE	(*  error *)
		  	Horn := TRUE;
                
                END_CASE;
	(* now check when right sensor is selected or signal horn *)

		IF Sensor_To_Int = Current_Bin_Offset THEN
			Correct_Bin_Located := TRUE;
			Start_Bin_Delay := TRUE;
			Horn := FALSE;
		Elsif Sensor_To_Int <> 0 then
			Horn := TRUE;
		END_IF;
	END_IF;
	IF Between_Bins_delay_done THEN		(* time delay between bin selections is completed *)
		Correct_Bin_Located := FALSE;
		Bin_Is_Found := FALSE;
		Current_Part_Offset := Current_Part_Offset+1;
		Start_Bin_Delay := FALSE;
		Clear_Lights := TRUE;
	END_IF;

ELSE
	Current_Lock := '';
	Lock_is_Found := FALSE;
	Bin_Is_Found:= FALSE;
	Correct_Bin_Located := FALSE;
	Lock_Completed := FALSE;

END_IF;