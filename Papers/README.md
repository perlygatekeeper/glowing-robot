# Paper Templates Library - Modular Setup

## Directory Structure

Create this folder structure:

```
Papers/
  paper_templates/
    __init__.py
    base.py
    writing.py
    calendars.py
    borders.py
    grids.py
    specialty.py
  examples/
    test_all.py
```

## Installation Steps

1. **Create the directory structure**:
```bash
cd Papers
mkdir -p paper_templates examples
```

2. **Copy the files**:
   - Save each artifact I created into its corresponding file in `paper_templates/`
   - File names match the artifact titles (e.g., "paper_templates/base.py")

3. **Verify the structure**:
```bash
ls paper_templates/
# Should show: __init__.py base.py borders.py calendars.py grids.py specialty.py writing.py
```

## Usage Examples

### Basic Import
```python
from paper_templates import WritingPaper, CalendarPaper, OrnamentalBorder

# Writing paper
college = WritingPaper(ruling='college')
college.save('college_ruled.svg')

# Calendar
cal = CalendarPaper(year=2026, month=3)
cal.save('march_2026.svg')

# Border
border = OrnamentalBorder(style='art-deco')
border.save('art_deco_border.svg')
```

### Test Script (examples/test_all.py)
```python
import sys
sys.path.insert(0, '..')

from paper_templates import (
    WritingPaper, CalendarPaper, WeeklyPlannerPaper,
    OrnamentalBorder, MathPaper, DotGridPaper,
    MusicPaper, CalligraphyPaper
)

# Test each type
print("Generating test papers...")

WritingPaper(ruling='college').save('test_writing.svg')
CalendarPaper(year=2026, month=1).save('test_calendar.svg')
OrnamentalBorder(style='looped-corner').save('test_border.svg')
MathPaper(grid_size=18).save('test_math.svg')
DotGridPaper(dot_spacing=20).save('test_dots.svg')
MusicPaper(staves=12).save('test_music.svg')

print("Done! Check the generated SVG files.")
```

## Available Classes

### Writing
- **WritingPaper**: Lined paper (wide, college, narrow ruled)

### Calendars  
- **CalendarPaper**: Monthly calendar
- **WeeklyPlannerPaper**: Weekly planner with time slots

### Borders
- **OrnamentalBorder**: 10 border styles (simple, art-deco, celtic, floral, victorian, etc.)

### Grids
- **MathPaper**: Basic graph paper
- **EngineeringPaper**: Major/minor grid lines
- **DotGridPaper**: Bullet journal dots
- **HexPaper**: Hexagonal grid
- **IsometricPaper**: Isometric 3D grid
- **PolarPaper**: Polar coordinates
- **LogarithmicPaper**: Log scale graphs

### Specialty
- **MusicPaper**: Staff paper
- **CalligraphyPaper**: Practice lines with guides
- **SciencePaper**: Lab notebook with column
- **PerspectivePaper**: 1/2/3-point perspective grids

## Advantages of Modular Structure

✅ **Easier to update** - Modify one file without touching others  
✅ **Better organization** - Related classes grouped together  
✅ **Faster loading** - Only import what you need  
✅ **Simpler debugging** - Isolated issues to specific modules  
✅ **Team friendly** - Multiple people can work on different modules  

## Next Steps

1. Copy all the artifacts to their files
2. Run the test script to verify everything works
3. Start adding new paper types to the appropriate modules
4. Enjoy much easier development! 🎉