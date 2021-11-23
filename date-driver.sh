#!/bin/bash

. ~/.profile

usage() {
        printf "Usage : $(basename "$0") yyyymmdd\n"
        printf "        $(basename "$0") yyyymmdd1 yyyymmdd2\n"
}

# --- Get command line input ---

startarg=""
endarg=""
if [ "$#" == 2 ] ; then
        startarg=$1
        endarg=$2
elif [ "$#" == 1 ] ; then
        startarg=$1
        endarg=$1
elif [ "$#" == 0 ] ; then
        startarg=$(date +%Y%m%d --date "today")
        endarg=$startarg
else
        usage >&2
        exit 1
fi

# --- Validate start and end dates ---

startdate=$(date +%Y%m%d --date $startarg)

if [ $? -ne 0 ] ; then
        echo "%s is an invalid date" $startarg >&2
        usage >&2
        exit 1
fi

enddate=$(date +%Y%m%d --date $endarg)

if [ $? -ne 0 ] ; then
        printf "%s is an invalid date" $endarg >&2
        usage >&2
        exit 1
fi

if [ $startdate -gt $enddate ] ; then
        printf "The end date predates the start date - switching the order\n"
        tempdate=$enddate
        enddate=$startdate
        startdate=$tempdate
fi

# --- Loop through the date range defined by startdate and enddate ---

printf "Updating from %s to %s\n" $startdate $enddate

cd $(dirname "$0")

failed=0
date=$startdate

until [ $date -gt $enddate ] ; do
        printf "\nUpdating %s now\n" $date

	jobfailed=0

	# --- Run your date dependent job(s) here ---

	printf "\nToday is a %s\n\n" $(date +%a --date $date)

	# --- Check for errors (add this after each job) ---

	if [ $? -ne 0 ] ; then
		printf "An error code of %d was returned\n" $? >&2
		((jobfailed++))
	fi

	# --- Note errors for this date ---

	if [ $jobfailed -ne 0 ] ; then
		printf "There were %d errors detected on %s\n" $jobfailed $date >&2
		((failed++))
	fi

	date=$(date +%Y%m%d --date "$date+1day")
done

# --- Exit script ---

if [ $failed -ne 0 ] ; then
        printf "There were errors detected on %d days\n" $failed >&2
        exit 1
fi

exit 0

