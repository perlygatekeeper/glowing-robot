"""
Paper Templates Library
Generate SVG files for various types of ruled/lined paper

Usage:
    from paper_templates import WritingPaper, CalendarPaper, OrnamentalBorder
    
    # Create paper
    paper = WritingPaper(ruling='college')
    paper.save('college_ruled.svg')
"""

# Base class
from .base import PaperTemplate

# Writing papers
from .writing import WritingPaper

# Calendars
from .calendars import (
    CalendarPaper,
    WeeklyPlannerPaper,
)

# Borders
from .borders import OrnamentalBorder

# Grids
from .grids import (
    MathPaper,
    EngineeringPaper,
    DotGridPaper,
    DotTrianglePaper,
    HexPaper,
    IsometricPaper,
    PolarPaper,
    LogarithmicPaper,
    TrianglePaper,
    OctagonSquarePaper,
    OctagonDiamondPaper,
    CairoPentagonalPaper,
    CubePaper,
)

# Music
from .music import (
    MusicPaper,
    TablaturePaper,
    ChordChartPaper,
)

# Specialty
from .specialty import (
    CalligraphyPaper,
    SciencePaper,
    PerspectivePaper,
)

__version__ = '1.0.0'

__all__ = [
    # Base
    'PaperTemplate',
    
    # Writing
    'WritingPaper',
    
    # Calendars
    'CalendarPaper',
    'WeeklyPlannerPaper',
    
    # Borders
    'OrnamentalBorder',
    
    # Grids
    'MathPaper',
    'EngineeringPaper',
    'DotGridPaper',
    'DotTrianglePaper',
    'HexPaper',
    'IsometricPaper',
    'PolarPaper',
    'LogarithmicPaper',
    'TrianglePaper',
    'OctagonSquarePaper',
    'OctagonDiamondPaper',
    'CairoPentagonalPaper',
    'CubePaper',
    
    # Music
    'MusicPaper',
    'TablaturePaper',
    'ChordChartPaper',
    
    # Specialty
    'CalligraphyPaper',
    'SciencePaper',
    'PerspectivePaper',
]
