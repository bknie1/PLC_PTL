# PLC Pick to Light Solution in Unity Pro
By Brandon Knieriem, Ian Schnepf, Connor Myatt, Juan Azaldagui, and Hongchi Liu

## Process Overview

### In Brief
This solution will use a PLC interface to inform station assembly employees what parts they need, per chassis, to complete the expected chassis at that station. The system uses timers and lights to guide the employee through the assembly process. The solution should mitigate nearly $500,000 in scrap loss.

- 30 Configurations

#### Use Case
1.	Employee receives chassis.
2.	Employee scans barcode printed on chassis.
3.	Barcode is compared to Database entries. Is there a match?
    - True - Lights are triggered for the relevant entry. Proceed to Step 5.
    - False- Alternative Case: Error indicated. No lights, flashing lights, etc. Return to Step 1.
5. Employee retrieves relevant picks from buckets.
    - Adding each piece, in order, one at a time.
6. Employee completes transaction and passes the chassis to the next station.
    - By hand.
    - By conveyer.

### In Detail

Event # - Format: File - Code Block (if applicable) - Action

1. FBD: barcode_scan - N/A - Reads serial input from scanner. Stores it in read buffer. Make one FB for each station.
	- ADDM and INPUT_CHAR instructions to translate barcode string. Reading from NOM module.
2. FBD: main - N/A - Create Workstation DFB. Create a DFB for each workstation and change parameters to reflect position.
	- Input Parameters
		- Workstation specific ID -> Workstation ID.
		- Station specific sensors -> sensors.
		- Station specific configuration array -> configuration array.
			- This is a double dimensioned array. The first array is the list of lock part numbers. The second array is a list of parts that are in each lock. So if the Current_Lock is at position 3 then Configuration[3][list of parts in position 3].
		- Station specific bin array - > bin array.
		- Station specific lock time arrary -> Time to Asssemble.
		- Station specific current lock -> current lock.
		- Station specific incorrect -> incorrect indicator.
	- Output Parameters: Specific lights as output.
		- Station specific lights -> lights.
		- Shared Horn/Alarm -> Horn/Alarm.
3. DFB: WorkStation - Overall - Code is reading for processing.
	1. If code exists (> 0), proceed.
		- Otherwise, reset everything:
			- Current_Lock := '';
			- Lock_is_Found := FALSE;
			- Bin_Is_Found:= FALSE;
			- Correct_Bin_Located := FALSE;
			- Lock_Completed := FALSE;
	2. Time stamp when assembly starts. Time to assemble lock variable.
	3. Find lock offset. Iterate through until a match is found. Logic: While match not found. Syntax: IF NOT ... THEN
		- Match == FALSE? Error.
	4. Match == TRUE? Assign match index to current lock offset. Part offset is set to 0.
		- We use the lock offset to iterate through and, using the part offset, find participating parts.
	5. While a bin hasn't been found and the lock hasn't been finished:
		- Check to see if finished. If finished:
			- Set lock completed variable.
			- Set assemble log time variable.
			- Set time to assemble lock on variable.
			- Reset current lock ('').
			- Log_Time_Assemble_Lock_Elapsed := Time_to_Assemble_Lock_Elapsed.
			- Code Block:
				- IF (LEN_INT(IN := Whats_In_Lock[Current_Lock_Offset][Current_Part_Offset]) < 1) then
					- Lock_Completed := TRUE;
					- Log_Time_Assemble_Lock := TRUE;
					- Time_To_Assemble_Lock_ON := FALSE;
					- Current_Lock := '';
					- Log_Time_Assemble_Lock_Elapsed := Time_to_Assemble_Lock_Elapsed;
				- END_IF;
		- If not finished:
			- Iterate through and find matching part bins.
			- If What's In Bin variable == Whats In Configuration[Lock_Offset][Part_Offset] :
				- Match!Set Bin is Found variable.
				- Assign index to the bin offset variable.
			- Repeat until a match is found. Check found variable, or we've exceeded the max index, or the lock is finished.
	6. If a configuration has been found and a part bin has been found turn on the light.
		- Use current bin offset variable to enter a switch case and turn on the appropriate light.
		- If no matching case: Error/Horn/Alarm.
	7. Check when the right sensor has been activated or energize signal/alarm/horn.
		- IF Sensor_To_Int = Current_Bin_Offset THEN
			- Correct_Bin_Located := TRUE;
			- Start_Bin_Delay := TRUE;
			- Horn := FALSE;
			- Elsif Sensor_To_Int <> 0 then
			- Horn := TRUE;
		- END_IF;
	8. Time delay between bin selections is completed.
		- IF Between_Bins_delay_done THEN
			- Correct_Bin_Located := FALSE;
			- Bin_Is_Found := FALSE;
			- Current_Part_Offset := Current_Part_Offset+1;
			- Start_Bin_Delay := FALSE;
			- Clear_Lights := TRUE;
		- END_IF;

## Hardware
- BMX XBP 0800
	- 8 Channel Master Board
- BMX P34 2020
	- Modbus Ethernet Processor
- DDI 6402K
	- 64 Channel Discrete Input
- DDO 6402K
	- 64 Channel Discrete Output
- NOM 0200.2
	- Serial Scanner Input
	- Use .2, not .1. .2 is the newer model.

- BARCODE SCANNING SECTION

Assumes comm through Rack 0, NOM in Slot 3, out channel 0, to slave address 1.
This is reading form %MW1 in the bar code scanner and reading 4 total %MW. The result is being placed
in L1-W1_READ_BUFF array.

- Instructions
	- ADDM
		- IN
			- Scanner address via NOM card.
		- OUT
			- Outputs serial data. (RS-232)
	- READ_VAR
		- EN (Enable) - Start_READ_VAR
			- Seems to just start automatically?
			- You can set actions to occur before this.
			- Ex. If x hasn't happened yet, READ_VAR can't happen yet.
		- OBJ (Object)
			- '%MW'
				- The type of object we're creating using this data.
		- NUM (First Number)
			- Starting register.
			- Address.
		- NB (Object Number)
			- Number of objects to read.
			Ex. 1 - 4. 4 objects total. So NB = 4.
		- GEST
			- Management parameter. What kind of data to expect. Limits.
			- L1_W#_READVAR_GEST
				- Int array of 4 values. Limit and expected data type.
		- RECP (Receiving Array)
			- L1_W#_READ_BUFF
				- FB output. What we send into the DFB.

- WORKSTATION DFB

	- Bin_1 through Bin_n

	- Overall
	- Sensor_To_INT
	- Timedelay_between_bins
	- Clear_Lights
