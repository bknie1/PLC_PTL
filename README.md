# PLC Pick to Light Solution in Unity Pro
By Brandon Knieriem, Ian Schnepf, Hongchi Liu

## Process Overview

### In Brief
This solution will use a PLC interface to inform station assembly employees what parts they need, per chassis, to complete the expected chassis at that station. The system uses timers and lights to guide the employee through the assembly process. The solution should mitigate nearly $500,000 in scrap loss.

### Use Case
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

## Variables

- MAIN/GLOBAL
	- WorkStation 1 DFB
		- Input
			- L1_W1_Sensor_1 through L1_W1_Sensor_21 --> Bin_1 through Bin_21
				- Strip workstation designation for derived FB logic. EBOOL.
			- W1_Whats_In_Lock --> Whats_In_Lock
				- Strip workstation designation for derived FB logic. EBOOL.
			- W1_Whats_In_Bin --> Whats_In_Bin
				- Strip workstation designation for derived FB logic. EBOOL.
			- Current_Lock --> Current_Lock. DINT.

		-Output
			- SensorLight_1 through SensorLight_21 --> L1_W1_Sensor_Light through ... 21. EBOOL.
			- Red_Light, Green_Light
			- Line_Error_Light
			- Current_Lock. No need to return. Leave blank.
			- Lock_Not_Found. No need to return. Leave blank.

	- WorkStation 2 DFB
		- Same as 1 with 'W2' instead of 'W1'.

	- WorkStation 3 DFB
		- Same as 1 with 'W3' instead of 'W1'.

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
