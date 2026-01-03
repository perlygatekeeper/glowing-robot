from printable_papers import *

# Monthly calendars for entire year
for month in range(1, 13):
    cal = CalendarPaper(year=2026, month=month, show_week_numbers=True)
    cal.save(f'2026_monthly_{month:02d}.svg')

# Weekly planners for all 52 weeks
for week in range(1, 53):
    weekly = WeeklyPlannerPaper(year=2026, week=week, 
                               start_hour=8, end_hour=18)
    weekly.save(f'2026_week_{week:02d}.svg')

# Yearly overview
yearly = YearlyCalendarPaper(year=2026)
yearly.save('2026_overview.svg')

# Habit trackers for each month
for month in range(1, 13):
    habits = HabitTrackerPaper(year=2026, month=month, num_habits=15)
    habits.save(f'2026_habits_{month:02d}.svg')
