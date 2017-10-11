
# File name: exam.awk
# Purpose: Final Part II
# Author: Teresa Henderson
# Course: IFT 383 Online
# Term: Summer 2017
# Date: 8/8/2017

BEGIN {

FS=","
OFS=" : "

# the assignment said to print this header in the output - wasn't sure what it meant
# so generated a separate header that matches iclassroster output that is the first line
# in iclassroster
print "Student ID, Posting ID, First Name, Last Name, Units, Grade Basis, Program and Plan, Academic Level, ASURITE, Residency, E-Mail"

# set counter variables for report
f = 0
s = 0
j = 0
t = 0
b = 0
n = 0

}

{ # input loop

# counts lines read the cheesy way.  mmm, cheese.
if($0)
++r

# looks for just IT students in $7
if($7 ~ "Information Technology" )
 ++i

# all lookups for $8
if($8 ~ "Freshman")
 ++f
  else if($8 ~ "Sophomore")
 ++s
  else if($8 ~ "Junior")
 ++j
  else if($8 ~ "Senior")
 ++t
  else if($8 ~ "Bacc")
 ++b
  else
 ++n # no category

# modify output of original and add e-mail

print "Last Name : First Name : Student ID : Program and Plan : Academic Level : ASURITE : E-mail" > "iclassroster"
print $4, $3, $1, $7, $8, $9, $9"@asu.edu" >> "iclassroster"

} # end input loop

END {

print "Total Number of Records: "r
print "Number of IT Students: " i
print "Number of Freshman: " f
print "Number of Sophomores: " s
print "Number of Juniors: " j
print "Number of Seniors: " t
print "Number of Post-Bacc: " b
print "Number of Uncategorized: " n
}
