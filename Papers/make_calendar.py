from printable_papers import *

# Current month calendar
current = CalendarPaper(size='letter')
current.save('current_month.svg')

# Specific month
march = CalendarPaper(size='letter', year=2026, month=3)
march.save('march_2026.svg')

# With week numbers and Monday start
european = CalendarPaper(size='a4', year=2026, month=6,
                        show_week_numbers=True, 
                        start_monday=True)
european.save('june_2026_iso.svg')

# Generate entire year
for month in range(1, 13):
    cal = CalendarPaper(year=2026, month=month)
    cal.save(f'2026_{month:02d}.svg')

# Large format
poster = CalendarPaper(width=1000, height=1200, year=2026, month=12)
poster.save('december_poster.svg')

# Yearly overview
year_2026 = YearlyCalendarPaper(size='letter', year=2026, landscape=True)
year_2026.save('2026_year.svg')

# A3 poster size
poster = YearlyCalendarPaper(size='a4', year=2027, landscape=True)
poster.save('2027_poster.svg')
