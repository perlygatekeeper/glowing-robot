"""
Calendar paper templates (monthly, weekly, yearly, habit tracker)
"""

import calendar
from datetime import datetime, timedelta

from .base import PaperTemplate


class CalendarPaper(PaperTemplate):
    """Generate monthly calendar pages"""
    
    def __init__(self, size='letter', width=None, height=None,
                 year=None, month=None, margin=36, 
                 show_week_numbers=False, start_monday=False):
        """
        Args:
            year: Year for calendar (default: current year)
            month: Month number 1-12 (default: current month)
            margin: Margin around edges
            show_week_numbers: Show week numbers in left column
            start_monday: Start week on Monday (False = Sunday)
        """
        super().__init__(size, width, height)
        self.year = year if year else datetime.now().year
        self.month = month if month else datetime.now().month
        self.margin = margin
        self.show_week_numbers = show_week_numbers
        self.start_monday = start_monday
    
    def generate(self):
        """Generate monthly calendar SVG"""
        svg = self.svg_header()
        
        # Get calendar data
        cal = calendar.monthcalendar(self.year, self.month)
        month_name = calendar.month_name[self.month]
        
        # Calculate dimensions
        content_width = self.width - 2 * self.margin
        content_height = self.height - 2 * self.margin
        
        # Title area
        title_height = 60
        
        # Calendar grid
        grid_top = self.margin + title_height + 20
        grid_height = content_height - title_height - 20
        
        # Number of columns (7 days + optional week number column)
        num_cols = 8 if self.show_week_numbers else 7
        col_width = content_width / num_cols
        
        # Number of rows (header + weeks)
        num_rows = len(cal) + 1  # +1 for day names header
        row_height = grid_height / num_rows
        
        # Draw title
        title_y = self.margin + 40
        svg += f'  <text x="{self.width / 2}" y="{title_y}" '
        svg += f'font-family="serif" font-size="36" font-weight="bold" '
        svg += f'text-anchor="middle" fill="#000000">'
        svg += f'{month_name} {self.year}</text>\n'
        
        # Draw grid border
        svg += f'  <rect x="{self.margin}" y="{grid_top}" '
        svg += f'width="{content_width}" height="{grid_height}" '
        svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        # Draw column lines
        for i in range(num_cols + 1):
            x = self.margin + i * col_width
            weight = "2" if i == 0 or i == num_cols else "1"
            svg += f'  <line x1="{x}" y1="{grid_top}" x2="{x}" y2="{grid_top + grid_height}" '
            svg += f'stroke="#000000" stroke-width="{weight}"/>\n'
        
        # Draw row lines
        for i in range(num_rows + 1):
            y = grid_top + i * row_height
            weight = "2" if i == 0 or i == 1 or i == num_rows else "1"
            svg += f'  <line x1="{self.margin}" y1="{y}" x2="{self.margin + content_width}" y2="{y}" '
            svg += f'stroke="#000000" stroke-width="{weight}"/>\n'
        
        # Day names header
        day_names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] if self.start_monday else \
                   ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        
        col_offset = 1 if self.show_week_numbers else 0
        
        # Week number header
        if self.show_week_numbers:
            x = self.margin + col_width / 2
            y = grid_top + row_height * 0.6
            svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
            svg += f'font-size="12" font-weight="bold" text-anchor="middle" fill="#666666">'
            svg += f'Wk</text>\n'
        
        # Draw day names
        for i, day_name in enumerate(day_names):
            x = self.margin + (i + col_offset + 0.5) * col_width
            y = grid_top + row_height * 0.6
            svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
            svg += f'font-size="14" font-weight="bold" text-anchor="middle" fill="#000000">'
            svg += f'{day_name}</text>\n'
        
        # Draw calendar dates
        for week_num, week in enumerate(cal):
            row_y = grid_top + (week_num + 1) * row_height
            
            # Week number
            if self.show_week_numbers:
                # Calculate ISO week number
                first_day = next((d for d in week if d != 0), 1)
                date_obj = datetime(self.year, self.month, first_day)
                iso_week = date_obj.isocalendar()[1]
                
                x = self.margin + col_width / 2
                y = row_y + row_height * 0.25
                svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
                svg += f'font-size="10" text-anchor="middle" fill="#999999">'
                svg += f'{iso_week}</text>\n'
            
            # Days
            for day_num, day in enumerate(week):
                if day != 0:  # 0 means no day in this cell
                    x = self.margin + (day_num + col_offset) * col_width + 8
                    y = row_y + 20
                    
                    # Check if weekend
                    is_weekend = False
                    if self.start_monday:
                        is_weekend = day_num >= 5
                    else:
                        is_weekend = day_num == 0 or day_num == 6
                    
                    # Check if today
                    is_today = (day == datetime.now().day and 
                               self.month == datetime.now().month and 
                               self.year == datetime.now().year)
                    
                    # Highlight today
                    if is_today:
                        cell_x = self.margin + (day_num + col_offset) * col_width
                        svg += f'  <rect x="{cell_x + 2}" y="{row_y + 2}" '
                        svg += f'width="{col_width - 4}" height="{row_height - 4}" '
                        svg += f'fill="#ffffcc" stroke="none"/>\n'
                    
                    # Day number
                    color = "#cc0000" if is_weekend else "#000000"
                    weight = "bold" if is_today else "normal"
                    
                    svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
                    svg += f'font-size="16" font-weight="{weight}" fill="{color}">'
                    svg += f'{day}</text>\n'
        
        svg += self.svg_footer()
        return svg


class WeeklyPlannerPaper(PaperTemplate):
    """Generate weekly planner with time slots"""
    
    def __init__(self, size='letter', width=None, height=None,
                 year=None, week=None, margin=36,
                 start_hour=7, end_hour=22, hour_interval=1,
                 start_monday=True):
        """
        Args:
            year: Year for planner (default: current year)
            week: ISO week number 1-53 (default: current week)
            margin: Margin around edges
            start_hour: First hour to show (0-23)
            end_hour: Last hour to show (0-23)
            hour_interval: Hours between time slots (0.5, 1, 2, etc.)
            start_monday: Start week on Monday (False = Sunday)
        """
        super().__init__(size, width, height)
        now = datetime.now()
        self.year = year if year else now.year
        self.week = week if week else now.isocalendar()[1]
        self.margin = margin
        self.start_hour = start_hour
        self.end_hour = end_hour
        self.hour_interval = hour_interval
        self.start_monday = start_monday
    
    def generate(self):
        """Generate weekly planner SVG"""
        svg = self.svg_header()
        
        # Get dates for the week
        dates = self._get_week_dates()
        
        # Calculate dimensions
        content_width = self.width - 2 * self.margin
        content_height = self.height - 2 * self.margin
        
        title_height = 50
        grid_top = self.margin + title_height
        grid_height = content_height - title_height
        
        time_col_width = 60
        day_col_width = (content_width - time_col_width) / 7
        
        # Calculate number of time slots
        num_slots = int((self.end_hour - self.start_hour) / self.hour_interval)
        slot_height = grid_height / num_slots
        
        # Draw title
        first_date = dates[0]
        last_date = dates[-1]
        title = f"Week {self.week}, {self.year}: {first_date.strftime('%b %d')} - {last_date.strftime('%b %d')}"
        svg += f'  <text x="{self.width / 2}" y="{self.margin + 30}" '
        svg += f'font-family="sans-serif" font-size="20" font-weight="bold" '
        svg += f'text-anchor="middle">{title}</text>\n'
        
        # Draw grid border
        svg += f'  <rect x="{self.margin}" y="{grid_top}" '
        svg += f'width="{content_width}" height="{grid_height}" '
        svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        # Draw day headers
        day_names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] if self.start_monday else \
                   ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        
        for i, (day_name, date) in enumerate(zip(day_names, dates)):
            x = self.margin + time_col_width + (i + 0.5) * day_col_width
            
            # Day name
            svg += f'  <text x="{x}" y="{grid_top - 15}" '
            svg += f'font-family="sans-serif" font-size="12" font-weight="bold" '
            svg += f'text-anchor="middle">{day_name}</text>\n'
            
            # Date
            svg += f'  <text x="{x}" y="{grid_top - 2}" '
            svg += f'font-family="sans-serif" font-size="10" '
            svg += f'text-anchor="middle" fill="#666666">{date.strftime("%m/%d")}</text>\n'
        
        # Draw vertical lines (days)
        for i in range(8):
            x = self.margin + time_col_width + i * day_col_width
            svg += f'  <line x1="{x}" y1="{grid_top}" x2="{x}" y2="{grid_top + grid_height}" '
            svg += f'stroke="#000000" stroke-width="1"/>\n'
        
        # Draw time column separator
        svg += f'  <line x1="{self.margin + time_col_width}" y1="{grid_top}" '
        svg += f'x2="{self.margin + time_col_width}" y2="{grid_top + grid_height}" '
        svg += f'stroke="#000000" stroke-width="2"/>\n'
        
        # Draw horizontal lines (time slots) and time labels
        for i in range(num_slots + 1):
            y = grid_top + i * slot_height
            hour = self.start_hour + i * self.hour_interval
            
            # Heavier line every hour
            weight = "1.5" if hour % 1 == 0 else "0.5"
            opacity = "1" if hour % 1 == 0 else "0.3"
            
            svg += f'  <line x1="{self.margin + time_col_width}" y1="{y}" '
            svg += f'x2="{self.margin + content_width}" y2="{y}" '
            svg += f'stroke="#666666" stroke-width="{weight}" opacity="{opacity}"/>\n'
            
            # Time label
            if hour < self.end_hour:
                hour_int = int(hour)
                minute = int((hour - hour_int) * 60)
                time_str = f"{hour_int:02d}:{minute:02d}"
                
                svg += f'  <text x="{self.margin + time_col_width - 5}" y="{y + 15}" '
                svg += f'font-family="sans-serif" font-size="10" '
                svg += f'text-anchor="end" fill="#666666">{time_str}</text>\n'
        
        svg += self.svg_footer()
        return svg
    
    def _get_week_dates(self):
        """Get list of dates for the specified week"""
        # Get first day of the week
        jan1 = datetime(self.year, 1, 1)
        week_start = jan1 + timedelta(days=(self.week - 1) * 7)
        
        # Adjust to Monday if needed
        days_since_monday = week_start.weekday()
        week_start = week_start - timedelta(days=days_since_monday)
        
        # Generate 7 dates
        if self.start_monday:
            return [week_start + timedelta(days=i) for i in range(7)]
        else:
            # Start on Sunday
            sunday_start = week_start - timedelta(days=1)
            return [sunday_start + timedelta(days=i) for i in range(7)]


# Additional calendar classes would go here (YearlyCalendarPaper, HabitTrackerPaper)
# I can add them if you'd like, or you can tell me when you need them