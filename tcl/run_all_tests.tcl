# --------------------------------------------------------------
# ----- Cкрипт для автоматического запуска всех тестов ---------
# --------------------------------------------------------------

# -----------------------------------------------------------
# процедура для проверки результатов
proc check_test_results {Log_Dir_Name Test_Name} {
	set Verification_Result 1
	# считываем весь файл
	set fileID [open $Log_Dir_Name/$Test_Name r]
	set file_data [read $fileID]
	close $fileID
	# разделяем файл на строки
	set data [split $file_data "\n"]
	foreach line $data {
		if {[string length $line] && [string first "FAIL" $line] != -1} {
			set Verification_Result 0	
			set message $Test_Name
			append message ": \"" $line "\""
			puts $message
		}
	}
	return $Verification_Result	
}

# -----------------------------------------------------------
# основной скрипт
set Verification_Result 1

# запуск тестов
source tcl/run_tests_x2.tcl
source tcl/run_tests_x4.tcl

# проверка результатов
puts ""

set Log_Dir_Name log_fifo_mig_based_tests

set Test_Name Test_Results_x2.txt
set Verification_Result [check_test_results $Log_Dir_Name $Test_Name]

set Test_Name Test_Results_x4.txt
set Verification_Result [check_test_results $Log_Dir_Name $Test_Name]

# вывод результатов
puts ""
if { $Verification_Result } {
	puts "-------------------------------------------"
	puts "--------- VERIFICATION SUCCESSED ----------"
	puts "-------------------------------------------"
} else {
	puts "-------------------------------------------"
	puts "---------- VERIFICATION FAILED ------------"
	puts "-------------------------------------------"
}



