/*
    Schedule is a list of events.
	Each event is in the format:
	[CourseName, GroupName, EventName, Date].
	Date is in the format:
	[Week, Day, SlotNumber].
*/

% Used predefined predicates: member, setof, findall, between, length, reverse, select, nth0, fail.

event_in_course(csen403, labquiz1, assignment).
event_in_course(csen403, labquiz2, assignment).
event_in_course(csen403, project1, evaluation).
event_in_course(csen403, project2, evaluation).
event_in_course(csen403, quiz1, quiz).
event_in_course(csen403, quiz2, quiz).
event_in_course(csen403, quiz3, quiz).

event_in_course(csen401, quiz1, quiz).
event_in_course(csen401, quiz2, quiz).
event_in_course(csen401, quiz3, quiz).
event_in_course(csen401, milestone1, evaluation).
event_in_course(csen401, milestone2, evaluation).
event_in_course(csen401, milestone3, evaluation).

event_in_course(csen402, quiz1, quiz).
event_in_course(csen402, quiz2, quiz).
event_in_course(csen402, quiz3, quiz).

event_in_course(math401, quiz1, quiz).
event_in_course(math401, quiz2, quiz).
event_in_course(math401, quiz3, quiz).

event_in_course(elct401, quiz1, quiz).
event_in_course(elct401, quiz2, quiz).
event_in_course(elct401, quiz3, quiz).
event_in_course(elct401, assignment1, assignment).
event_in_course(elct401, assignment2, assignment).

event_in_course(csen601, quiz1, quiz).
event_in_course(csen601, quiz2, quiz).
event_in_course(csen601, quiz3, quiz).
event_in_course(csen601, project, evaluation).
event_in_course(csen603, quiz1, quiz).
event_in_course(csen603, quiz2, quiz).
event_in_course(csen603, quiz3, quiz).

event_in_course(csen602, quiz1, quiz). 
event_in_course(csen602, quiz2, quiz).
event_in_course(csen602, quiz3, quiz).

event_in_course(csen604, quiz1, quiz).
event_in_course(csen604, quiz2, quiz).
event_in_course(csen604, quiz3, quiz).
event_in_course(csen604, project1, evaluation).
event_in_course(csen604, project2, evaluation).


holiday(3,monday).
holiday(5,tuesday).
holiday(10,sunday).


studying(csen403, group4MET).
studying(csen401, group4MET).
studying(csen402, group4MET).
studying(csen402, group4MET).

studying(csen601, group6MET).
studying(csen602, group6MET).
studying(csen603, group6MET).
studying(csen604, group6MET).


should_precede(csen403,project1,project2).
should_precede(csen403,quiz1,quiz2).
should_precede(csen403,quiz2,quiz3).

quizslot(group4MET, tuesday, 1).
quizslot(group4MET, thursday, 1).
quizslot(group6MET, saturday, 5).

/*  precede_date(Date1, Date2)
	predicate true only if Date1 is preceding Date2.
*/

% Case 1: W1 is less then W2.
precede_date([W1, _, _], [W2, _, _]) :-
	W1 < W2, !.

% Case 2: Week is the same. D1 is less than D2.
precede_date([Week, D1, _], [Week, D2, _]) :-
	Days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday],
	nth0(Number1, Days, D1),
	nth0(Number2, Days, D2),
	Number1 < Number2, !.

% Case 3: Week and Day are the same. Slots are different.
precede_date([Week, Day, Slot1], [Week, Day, Slot2]) :-
	Days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday],
	member(Day, Days),
	Slot1 < Slot2.
	

/* precede(Group,Schedule)
   Predicate is true only if group Group has no precedence violations.
   Group - group name.
   Schedule - schedule list. 
   Steps: 
		Get one event from Schedule.
		Get another event from Schedule.
		Check if this events are connected with should_precede predicate.
		Check if precedence in not right.
		If all conditions are meeted, Schedule is not valid, Fail.
		Otherwise precede returns true.
*/

precede(Group, Schedule) :-
	member([Course, Group, Event1, Date1], Schedule),
	member([Course, Group, Event2, Date2], Schedule),
	should_precede(Course, Event1, Event2),
	precede_date(Date2, Date1),
	!, fail.

precede(_, _).

/* 	valid_slots_schedule(Group,Schedule) 
	Predicate is true only if the group Group does not have more than one event in any slot of Schedule.
	Group - group name.
	Schedule - schedule list.
	Steps:
          Get one event from Schedule.
		  Get another event from Schedule.
		  Events should be different. Otherwise they are they same event.
		  If all conditions are meeted, Schedule is not valid, Fail.
		  Otherwise valid_slots_schedule returns true.
*/

valid_slots_schedule(Group, Schedule) :-
	member([Course1, Group, Event1, Date], Schedule),
	member([Course2, Group, Event2, Date], Schedule),
	(Course1 \= Course2; Event1 \= Event2),
	!, fail.

valid_slots_schedule(_, _).

/* available_timings(Group,L) 
   Predicate is only be true if L is the list of timings in which the group Group could have an event scheduled.
   Group - group name.
   L - list of possible timings. Timings includes Day and Slot.
   Steps:
		 Generate list of possible timings.
*/

available_timings(Group, Timings) :-
	findall([Day, Slot], quizslot(Group, Day, Slot), Timings).

/*  group_events(Group,Events) 
	Predicate is true if Events is the list of events that should be scheduled for the group Group.
	Group - group name.
	Events - event list. Event in this list includes Course and EventName.
	Steps:
		  Get all courses for this Group.
		  Get all different events.
*/

group_events(Group, Events) :-
	setof(C, studying(C, Group), CL),
	findall([Course, Event], (member(Course, CL),event_in_course(Course, Event, _)), Events).

/*  no_consec_quizzes(Group,Schedule)
	Predicate succeed only if the group Group does not have two quizzes for the same course in two consecitive weeks.
	Group - group name.
	Schedule - schedule list.
	Steps:
		  Get one event from Schedule.
		  Get another event from Schedule.
		  Events should be different.
		  Events should be quizzes.
		  If Week1 is consequent to Week2, then Week1 is between Week2 - 1 and Week2 + 1.
		  If all conditions are meeted, Schedule is not valid, Fail.
		  Otherwise valid_slots_schedule returns true.

*/

no_consec_quizzes(Group, Schedule) :-
	member([Course, Group, Event1, [Week1, _, _]], Schedule),
	member([Course, Group, Event2, [Week2, _, _]], Schedule),
	Event1 \= Event2,
	event_in_course(Course, Event1, quiz),
	event_in_course(Course, Event2, quiz),
	W21 is Week2 - 1,
	W22 is Week2 + 1,
	between(W21, W22, Week1),
	!, fail.

no_consec_quizzes(_, _).

/*  no_same_day_quiz(Group,Schedule) 
	Predicate is only true if group Group does not have two quizzes scheduled on the same day in Schedule.
	Group - group name.
	Schedule - schedule list.
	Steps:
		  Get an event from Schedule in one day.
		  Get another event from Schedule.
		  Events should be different. Otherwise they are they same event.
		  Events should be quizzes.
		  If all conditions are meeted, Schedule is not valid, Fail.
		  Otherwise valid_slots_schedule returns true.
*/

no_same_day_quiz(Group, Schedule) :-
	member([Course1, Group, Event1, [Week, Day, _]], Schedule),
	member([Course2, Group, Event2, [Week, Day, _]], Schedule),
	(Course1 \= Course2; Event1 \= Event2),
	event_in_course(Course1, Event1, quiz),
	event_in_course(Course2, Event2, quiz),
	!, fail.

no_same_day_quiz(_, _).

/*  no_same_day_assignment(Group,Schedule) 
	Predicate is only true if group Group does not have two assignments scheduled on the same day in Schedule.
	Group - group name.
	Schedule - schedule list.
	Steps:
		  Get an event from Schedule in one day.
		  Get another event from Schedule.
		  Events should be different. Otherwise they are they same event.
		  Events should be assignments.
		  If all conditions are meeted, Schedule is not valid, Fail.
		  Otherwise valid_slots_schedule returns true.
*/

no_same_day_assignment(Group, Schedule) :-
	member([Course1, Group, Event1, [Week, Day, _]], Schedule),
	member([Course2, Group, Event2, [Week, Day, _]], Schedule),
	(Course1 \= Course2; Event1 \= Event2),
	event_in_course(Course1, Event1, assignment),
	event_in_course(Course2, Event2, assignment),
	!, fail.

no_same_day_assignment(_, _).

/*  no_holidays(Group,Schedule) 
	Predicate succeed only if Schedule has no events scheduled in any of the available holidays.
	Group - group name.
	Schedule - schedule list.
	Steps:
		  Get an event from Schedule in one day.
		  Check if this day is a holiday.
		  If all conditions are meeted, Schedule is not valid, Fail.
		  Otherwise valid_slots_schedule returns true.
*/

no_holidays(Group, Schedule) :-
	member([_, Group, _, [Week, Day, _]], Schedule),
	holiday(Week, Day),
	!, fail.

no_holidays(_, _).


/* 	schedule_events(CurrentGroup, Groups, WeekNumber, Events, Timings, CurrentSchedule, Schedule)
	Predicate schedule all events for Groups.
	CurrentGroup - current group name.
	Groups - list of groups for scheduling.
	WeekNumber - total amount of available weeks.
	Events - list of events for current group.
	Timings - list of timings for current group.
	CurrentSchedule - completed part of schedule.
	Schedule - result.
*/

% Case 1: There are less possible slots for events.
schedule_events(_, _, _, LEvents, LTimings, _, _) :-
	length(LEvents, NEvents),
	length(LTimings, NTimings),
	NEvents > NTimings, !, fail.

% Case 2: Then all events for all groups are scheduled process completed.
schedule_events(_, [], _, [], _, Schedule, Schedule).

% Case 3: Then all events for previous group are scheduled getting new Group and scheduling for it.
schedule_events(_, [Group | Groups], WeekNumber, [], _, CurrentSchedule, Schedule) :-
	% Getting available timings for Group.
	available_timings(Group, DaySlotList),
	
	% Getting timings with week numbers.
	findall([Week, Day, Slot],(member([Day, Slot], DaySlotList), between(1, WeekNumber, Week)), Timings),
	
	% Getting available events for Group.
	group_events(Group, Events),
	
	schedule_events(Group, Groups, WeekNumber, Events, Timings, CurrentSchedule, Schedule).

% Case 4: Have some not scheduled events for current group.
schedule_events(Group, Groups, WeekNumber, [[Course, Event]|Events], Timings, CurrentSchedule, Schedule) :-
	% Getting possible slot for next event.
	select(Date, Timings, NewTimings),
	
	% Constructing new schedule.
	append(CurrentSchedule, [[Course, Group, Event, Date]], NewSchedule),
	
	% Checking if new schedule is correct.
	precede(Group, NewSchedule),
	valid_slots_schedule(Group, NewSchedule),
	no_consec_quizzes(Group, NewSchedule),
	no_same_day_quiz(Group, NewSchedule),
	no_same_day_assignment(Group, NewSchedule),
	
	schedule_events(Group, Groups, WeekNumber, Events, NewTimings, NewSchedule, Schedule).

/* 	schedule(Week_Number, Schedule)
	Main predicate for scheduling.
	Week_Number - number of weeks for scheduling.
	Schedule - resulting schedule.
	Steps:
		  Get all groups.
		  We need only unique groups.
		  Construct schedule.
*/

schedule(WeekNumber, ReverseSchedule) :-
	findall(Group, studying(_, Group), Groups),
	setof(Group1, member(Group1, Groups), UniqueGroups),
	schedule_events([], UniqueGroups, WeekNumber, [], [], [], Schedule),
	 
	% To see the changes reverse the list only to test. Can be removed.
	reverse(Schedule, ReverseSchedule).