(* Executes when there is a configuration that is ready for processing.
It has been vetted by the scan section in MAST and is not empty.*)

(* If we're reading the bar code in as a string is this appropriate? *)

IF current_config <> '' THEN
	(* First, we need to find the offset of the configuration so that
	we can use it to find which parts are in the configuration.*)

	(* While we are still looking for a config match...*)
	IF NOT config_found THEN
		i := 0;
		(* Iterate through & compare scanned config to known configs *)
		REPEAT
			(* If we find a match, indicate so, and proceed. *)
			IF config_content[0][i] = current_config THEN
				config_found := TRUE;
			END_IF;
			i := i + 1;
		(* Do this until we find a match or exceed the number of possibilities.*)
		UNTIL config_found OR i > 22 (*Only 22 configs.*)
		END_REPEAT;

		(* Lock is not in list. Error. *)
		IF config_found = FALSE THEN
			error := TRUE;
		(* Match found! Assign config offset, iterate through bins. *)
		ELSE
			config_offset 	:= i;
			part_offset 	:= 0;
		END_IF;
	END_IF;

	(* If we haven't found all of the parts & the config isn't finished... *)
	IF NOT bin_found AND NOT config_completed THEN
		i := 0;
		(* Is the configuration finished? *)
		IF config_content[config_offset][part_offset] = '' THEN
			config_completed := TRUE;
		END_IF;
		(* No? Find the bins with each relevant part. *)
		REPEAT
			(* If the bin's part matches the expected part for that config...*)
			IF bin_content[i] = config_content[config_offset][part_offset] THEN
				(* Use this information to turn on a light. *)
				bin_found := TRUE;
				bin_offset := i;
			END_IF;
			i := i + 1;
		UNTIL bin_found = TRUE or i > 21 (* Only 21 bins max. *)
		END_REPEAT;
	END_IF;
	(* If the configuration is valid and the bin is relevant turn on the
	appropriate light. *)
	IF config_found AND bin_found THEN
		CASE bin_offset OF
			0: 	bin_light_0 := TRUE;
			1: 	bin_light_1 := TRUE;
			2: 	bin_light_2 := TRUE;
			3: 	bin_light_3 := TRUE;
			4: 	bin_light_4 := TRUE;
			5: 	bin_light_5 := TRUE;
			6: 	bin_light_6 := TRUE;
			7: 	bin_light_7 := TRUE;
			8: 	bin_light_8 := TRUE;
			9: 	bin_light_9 := TRUE;
			10: 	bin_light_10 := TRUE;
			11: 	bin_light_11 := TRUE;
			12: 	bin_light_12 := TRUE;
			13: 	bin_light_13 := TRUE;
			14: 	bin_light_14 := TRUE;
			15: 	bin_light_15 := TRUE;
			16: 	bin_light_16 := TRUE;
			17: 	bin_light_17 := TRUE;
			18: 	bin_light_18 := TRUE;
			19: 	bin_light_19 := TRUE;
			20: 	bin_light_20 := TRUE;
			21: 	bin_light_21 := TRUE;
		ELSE
			error := TRUE; (*If the bin isn't there: Error. *)
		END_CASE;
		
		IF sensor_to_int = bin_offset THEN
			valid_bin := TRUE;
			start_bin_delay := TRUE;
			error := FALSE;
		ELSIF sensor_to_int <> 0 THEN
			error := TRUE;
		END_IF;
	END_IF;

	(* Limits bin input. Time delay between picks. *)
	IF bin_delay_done THEN
		valid_bin := FALSE;
		bin_found := FALSE;
		part_offset := part_offset + 1;
		start_bin_delay := FALSE;
		clear_lights := TRUE;
	END_IF;
ELSE
	current_config := '';
	config_found := FALSE;
	bin_found := FALSE;
	valid_bin := FALSE;
	config_completed := FALSE;
END_IF;