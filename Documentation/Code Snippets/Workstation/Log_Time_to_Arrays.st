(*   This section will upon trigger put the current data into the arrays used to store the assembly times. *)

IF Log_Time_Assemble_Lock THEN
	Log_Time_Assemble_Lock := FALSE;	(* only do this one time *)

	Time_to_Assemble[Time_to_Assemble_Lock_Offset].Time_Stamp  := Current_Timestamp;  
	Time_to_Assemble[Time_to_Assemble_Lock_Offset].Lock_Part_Number := Log_Current_Lock;
	Time_to_Assemble[Time_to_Assemble_Lock_Offset].Elapsed_Time :=	Log_Time_Assemble_Lock_Elapsed;
	
	(* increment the offset of where to put the information in the array *)
	IF Time_to_Assemble_Lock_Offset >=99 THEN
		Time_to_Assemble_Lock_Offset :=0;
	ELSE
		Time_to_Assemble_Lock_Offset := Time_to_Assemble_Lock_Offset+1;
	END_IF;

END_IF;