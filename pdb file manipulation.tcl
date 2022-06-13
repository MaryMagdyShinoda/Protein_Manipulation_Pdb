# function to display menu options and get option from user
proc menuoption {} {
	
	puts "Hello User, Choose your action with number from 1 to 6"
	puts " 1. Load File"
	puts " 2. Select a residue"
	puts " 3. Save Selection"
	puts " 4. Analyze"
	puts " 5. Process Residues"
	puts " 6. Align Molecules"
	
	set option [gets stdin]  
	
	switch $option {
	
		1 {loadfile}
		2 { global counter 
         	if {$counter == 1} {
			    Selectresidue
			} else {
			    puts "no file loaded"
			}     
		} 
		3 { global counter 
         	if {$counter == 2} {
			    saveselection
			} else {
			    puts "no atoms selected"
			}     
		} 
		4 {Analyze}
		5 {ProcessResidues}
		6 {Alignmolecules}
		default {puts "Invalid choice. choose from 1 to 6."} 
	 
	}
}

# function to load file 
proc loadfile {} {
    
	global counter 
	set counter 0
	
    puts "Enter the file name or path to load the file";
	set input [gets stdin] 
	
	if {[file isdirectory $input]} {
	    cd $input 
		
	    set contents [glob -nocomplain -type f *.pdb]
		foreach item $contents {
            puts $item
            # recurse - go into the sub directory
            if { [file isdirectory $item] } { printDir $item}
        }
		
		set length [llength $contents]
		if {$length == 0} { 
		     puts "directory not have any pdb files.....you can not load from it"
			 
		} else {		
		         puts "Enter the file name with extention to load the file"
		         set name [gets stdin]
		
		         if {[file exists $name]} {
		             puts "The file exists"
		             puts "Loading the file..."
		   
		             global id 
		             set id [mol new $name]
		             mol modstyle 0 top lines 1
		             mol modcolor 0 top name
					 
					 global counter 
					 set counter 1
					 
		        } else {puts "file not exist"}
		    }
		 
	} elseif {[file isfile $input]} {
		puts "The file exists"
		puts "Loading the file..."
		
		global id
		set id [mol new $input]
		mol modstyle 0 top lines 1
		mol modcolor 0 top name	
		
		global counter 
		set counter 1

	} else {puts "No such file or directory"}
}

# function to select residue
proc Selectresidue {} {

   puts "Enter the residue name or range ";
   set residuee [gets stdin]
   
   global residueselected 
   set residueselected [uplevel "#0" [list atomselect top $residuee]]

  set coords [lsort -real [$residueselected get x]]
  set minx [lindex $coords 0]
  set maxx [lindex [lsort -real -decreasing $coords] 0]

  set coords [lsort -real [$residueselected get y]]
  set miny [lindex $coords 0]
  set maxy [lindex [lsort -real -decreasing $coords] 0]

  set coords [lsort -real [$residueselected get z]]
  set minz [lindex $coords 0]
  set maxz [lindex [lsort -real -decreasing $coords] 0]

  # and draw the lines
  draw materials off
  draw color yellow
  draw line "$minx $miny $minz" "$maxx $miny $minz"
  draw line "$minx $miny $minz" "$minx $maxy $minz"
  draw line "$minx $miny $minz" "$minx $miny $maxz"

  draw line "$maxx $miny $minz" "$maxx $maxy $minz"
  draw line "$maxx $miny $minz" "$maxx $miny $maxz"

  draw line "$minx $maxy $minz" "$maxx $maxy $minz"
  draw line "$minx $maxy $minz" "$minx $maxy $maxz"

  draw line "$minx $miny $maxz" "$maxx $miny $maxz"
  draw line "$minx $miny $maxz" "$minx $maxy $maxz"

  draw line "$maxx $maxy $maxz" "$maxx $maxy $minz"
  draw line "$maxx $maxy $maxz" "$minx $maxy $maxz"
  draw line "$maxx $maxy $maxz" "$maxx $miny $maxz"
  
  puts "box is drawn"
  
  global counter 
  set counter 2
}

# function to save selection  
proc saveselection {} {
    	
	puts "Enter path to save the file in it ";
	set path [gets stdin] 
	set p [file executable $path]
	if {$p==1} {
	if {[file isdirectory $path]} {
	    cd $path
		
		puts "Enter the file name";
	    set filename [gets stdin] 
		
		
		global residueselected
		$residueselected writepdb $filename.pdb
		puts "file is created";
		
	} else { puts "wrong path" }
	
	} else {puts "can not save in the path"}
}

# function to analyze selection  
proc Analyze {} {
	
	 global residueselected	
	 set Selected $residueselected
	
	 set numatoms [$Selected num]
	
	 set formatStr {%15s%18s}
	 puts [format $formatStr "Number of atoms:" $numatoms]
	
     set selectlist1 [lsort -unique [$Selected get resid]]
	 set num1 [llength $selectlist1]
	 
	 set selectlist2 [lsort [$Selected get resname]]
     set i 0
	 set count 0
	 while {$i < [llength $selectlist2]} {
	     if {[lindex $selectlist2 $i] == "HOH"} {
		     set count [expr $count +1]
		 }
		 set i [expr $i +1]
	 }
	 
	
	 set result [expr $num1 + $count]
	
	 set formatStr1 {%15s%15s}
	 puts [format $formatStr1 "Number of residues:" $result]
}

#funcion to Process Residues
proc ProcessResidues {} {

     mol modstyle 0 top vdw 1.0 12
     mol modcolor 0 top beta
	
	set a [atomselect top all]
	set b [lsort -unique [$a get resname]]
	set i 0
	set j 0
	while {$i < [llength $b]} {
	     set m [lindex $b $i]
		 set gg [atomselect top "resname $m" ]
		 set n [$gg num]
		 set formatStr {%5s%5s}
		 puts [format $formatStr $m $n]
		 $gg set beta $j
		 set i [expr $i +1]
		 set j [expr $j +10]
	}	
}

#funcion to Align molecules
proc Alignmolecules {} {

     mol delete all
	 
	 set i 0
     while {$i<2} {

		loadfile
		mol modstyle 0 top newribbons 0.3 12
		
		set i [expr $i +1]
	}
	
	mol modcolor 0 top resid
	
	global id
	set sel1 [expr $id -1]
	set sel2 $id
	
	set select1 [atomselect $sel1 all]
    set select2 [atomselect $sel2 all]
    set distance [measure fit $select1 $select2]
    $select1 move $distance
	puts "Now the molecules aligned on top of each other"
}

# call funcions
menuoption
	