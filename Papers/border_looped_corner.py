    def _draw_looped_corner(self):
        """Page with looped corner effect"""
        svg = ''
        
        # Main page border
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        # step size
        step = 10

        # Draw page outline
        svg += f'  <rect x="{x}" y="{y}"' fill="none" stroke="#000000" stroke-width="{1.5*self.thickness}"/>\n'

        # Start at top-left, go clockwise, complete loop at each corner
        svg += f'  <path d="'
        svg += f'M {x + 0 * step} {y + 1 * step} '
        svg += f'L {x + 2 * step} {y + 1 * step} '
        svg += f'L {x + 2 * step} {y + 2 * step} '
        svg += f'L {x + 1 * step} {y + 2 * step} '
        svg += f'L {x + 1 * step} {y + 0 * step} '

        # On to top-right, continue clockwise, complete loop at each corner
        svg += f'L {x + w - 1 * step} {y + 0 * step} '
        svg += f'L {x + w - 1 * step} {y + 2 * step} '
        svg += f'L {x + w - 2 * step} {y + 2 * step} '
        svg += f'L {x + w - 2 * step} {y + 1 * step} '
        svg += f'L {x + w - 0 * step} {y + 1 * step} '

        # On to bottom-right, continue clockwise, complete loop at each corner
        svg += f'L {x + w - 0 * step} {y + h - 1 * step} '
        svg += f'L {x + w - 2 * step} {y + h - 1 * step} '
        svg += f'L {x + w - 2 * step} {y + h - 2 * step} '
        svg += f'L {x + w - 1 * step} {y + h - 2 * step} '
        svg += f'L {x + w - 1 * step} {y + h - 0 * step} '

        # On to bottom-left, go clockwise, complete loop at each corner
        svg += f'L {x + 1 * step} {y + h - 0 * step} '
        svg += f'L {x + 1 * step} {y + h - 2 * step} '
        svg += f'L {x + 2 * step} {y + h - 2 * step} '
        svg += f'L {x + 2 * step} {y + h - 1 * step} '
        svg += f'L {x + 0 * step} {y + h - 1 * step} '
        svg += f'L {x + 0 * step} {y + 1 * step} '
        svg += f'Z" '  # Close path
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'

        # Draw the inner-most almost-square
        svg += f'  <path d="'
        svg += f'M {x + 2 * step} {y + 4 * step} '
        svg += f'L {x + 4 * step} {y + 4 * step} '
        svg += f'L {x + 4 * step} {y + 2 * step} '

        svg += f'L {x + w - 2 * step} {y + 4 * step} '
        svg += f'L {x + w - 4 * step} {y + 4 * step} '
        svg += f'L {x + w - 4 * step} {y + 2 * step} '

        svg += f'L {x + w - 2 * step} {y + h - 4 * step} '
        svg += f'L {x + w - 4 * step} {y + h - 4 * step} '
        svg += f'L {x + w - 4 * step} {y + h - 2 * step} '

        svg += f'L {x + 2 * step} {y + h - 4 * step} '
        svg += f'L {x + 4 * step} {y + h - 4 * step} '
        svg += f'L {x + 4 * step} {y + h - 2 * step} '

        svg += f'L {x + 2 * step} {y + 4 * step} '
        svg += f'Z" '
        svg += f'fill="#e0e0e0" stroke="#000000" stroke-width="{self.thickness * 0.5}"/>\n'

        return svg
