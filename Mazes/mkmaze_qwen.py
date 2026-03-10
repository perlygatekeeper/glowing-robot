import random
from PIL import Image, ImageDraw
import svgwrite
import math

class MazeGenerator:
    def __init__(self, width, height, shape="rectangular", radius=None):
        self.width = width
        self.height = height
        self.shape = shape
        self.radius = radius if radius else min(width, height) // 2
        self.grid = {}
        self.visited = set()

    def generate(self):
        if self.shape == "rectangular":
            self._generate_rectangular()
        elif self.shape == "hexagonal":
            self._generate_hexagonal()
        elif self.shape == "circular":
            self._generate_circular()
        else:
            raise ValueError("Unsupported shape. Choose 'rectangular', 'hexagonal', or 'circular'.")

    def _generate_rectangular(self):
        # Initialize grid
        for x in range(self.width):
            for y in range(self.height):
                self.grid[(x, y)] = {"N": True, "S": True, "E": True, "W": True}

        # Recursive backtracking
        def backtrack(x, y):
            self.visited.add((x, y))
            directions = [(0, -1, "N", "S"), (0, 1, "S", "N"), (1, 0, "E", "W"), (-1, 0, "W", "E")]
            random.shuffle(directions)
            for dx, dy, dir1, dir2 in directions:
                nx, ny = x + dx, y + dy
                if 0 <= nx < self.width and 0 <= ny < self.height and (nx, ny) not in self.visited:
                    self.grid[(x, y)][dir1] = False
                    self.grid[(nx, ny)][dir2] = False
                    backtrack(nx, ny)

        backtrack(0, 0)

    def _generate_hexagonal(self):
        # Initialize hexagonal grid
        for q in range(self.width):
            for r in range(self.height):
                self.grid[(q, r)] = {"N": True, "S": True, "NE": True, "NW": True, "SE": True, "SW": True}

        # Recursive backtracking
        def backtrack(q, r):
            self.visited.add((q, r))
            directions = [
                (0, -1, "N", "S"), (0, 1, "S", "N"),
                (1, 0, "SE", "NW"), (-1, 0, "NW", "SE"),
                (1, -1, "NE", "SW"), (-1, 1, "SW", "NE")
            ]
            random.shuffle(directions)
            for dq, dr, dir1, dir2 in directions:
                nq, nr = q + dq, r + dr
                if 0 <= nq < self.width and 0 <= nr < self.height and (nq, nr) not in self.visited:
                    self.grid[(q, r)][dir1] = False
                    self.grid[(nq, nr)][dir2] = False
                    backtrack(nq, nr)

        backtrack(0, 0)

    def _generate_circular(self):
        # Initialize circular grid
        for r in range(self.radius):
            for theta in range(360):
                self.grid[(r, theta)] = {"IN": True, "OUT": True, "CW": True, "CCW": True}

        # Recursive backtracking
        def backtrack(r, theta):
            self.visited.add((r, theta))
            directions = [
                (1, 0, "OUT", "IN"), (-1, 0, "IN", "OUT"),
                (0, 1, "CW", "CCW"), (0, -1, "CCW", "CW")
            ]
            random.shuffle(directions)
            for dr, dtheta, dir1, dir2 in directions:
                nr, ntheta = r + dr, (theta + dtheta) % 360
                if 0 <= nr < self.radius and (nr, ntheta) not in self.visited:
                    self.grid[(r, theta)][dir1] = False
                    self.grid[(nr, ntheta)][dir2] = False
                    backtrack(nr, ntheta)

        backtrack(0, 0)

    def save_png(self, filename):
        if self.shape == "rectangular":
            self._save_rectangular_png(filename)
        elif self.shape == "hexagonal":
            self._save_hexagonal_png(filename)
        elif self.shape == "circular":
            self._save_circular_png(filename)

    def save_svg(self, filename):
        if self.shape == "rectangular":
            self._save_rectangular_svg(filename)
        elif self.shape == "hexagonal":
            self._save_hexagonal_svg(filename)
        elif self.shape == "circular":
            self._save_circular_svg(filename)

    def _save_rectangular_png(self, filename):
        cell_size = 20
        img_width = self.width * cell_size + 1
        img_height = self.height * cell_size + 1
        img = Image.new("RGB", (img_width, img_height), "white")
        draw = ImageDraw.Draw(img)

        for x in range(self.width):
            for y in range(self.height):
                cell = self.grid[(x, y)]
                x1, y1 = x * cell_size, y * cell_size
                x2, y2 = x1 + cell_size, y1 + cell_size
                if cell["N"]:
                    draw.line([(x1, y1), (x2, y1)], fill="black", width=1)
                if cell["S"]:
                    draw.line([(x1, y2), (x2, y2)], fill="black", width=1)
                if cell["E"]:
                    draw.line([(x2, y1), (x2, y2)], fill="black", width=1)
                if cell["W"]:
                    draw.line([(x1, y1), (x1, y2)], fill="black", width=1)

        img.save(filename)

    def _save_hexagonal_png(self, filename):
        cell_size = 20
        img_width = self.width * cell_size * 1.5 + 1
        img_height = self.height * cell_size * math.sqrt(3) + 1
        img = Image.new("RGB", (int(img_width), int(img_height)), "white")
        draw = ImageDraw.Draw(img)

        for q in range(self.width):
            for r in range(self.height):
                x = q * cell_size * 1.5
                y = r * cell_size * math.sqrt(3) + (q % 2) * cell_size * math.sqrt(3) / 2
                points = [
                    (x + cell_size * dx, y + cell_size * dy)
                    for dx, dy in [
                        (0.5, -math.sqrt(3) / 2),
                        (1, 0),
                        (0.5, math.sqrt(3) / 2),
                        (-0.5, math.sqrt(3) / 2),
                        (-1, 0),
                        (-0.5, -math.sqrt(3) / 2),
                    ]
                ]
                cell = self.grid[(q, r)]
                if cell["N"]:
                    draw.line([points[0], points[1]], fill="black", width=1)
                if cell["S"]:
                    draw.line([points[3], points[4]], fill="black", width=1)
                if cell["NE"]:
                    draw.line([points[1], points[2]], fill="black", width=1)
                if cell["NW"]:
                    draw.line([points[5], points[0]], fill="black", width=1)
                if cell["SE"]:
                    draw.line([points[2], points[3]], fill="black", width=1)
                if cell["SW"]:
                    draw.line([points[4], points[5]], fill="black", width=1)

        img.save(filename)

    def _save_circular_png(self, filename):
        cell_size = 5
        img_width = img_height = self.radius * cell_size * 2 + 1
        img = Image.new("RGB", (img_width, img_height), "white")
        draw = ImageDraw.Draw(img)

        for r in range(self.radius):
            for theta in range(360):
                angle = math.radians(theta)
                x = img_width // 2 + r * cell_size * math.cos(angle)
                y = img_height // 2 + r * cell_size * math.sin(angle)
                cell = self.grid[(r, theta)]
                if cell["IN"] and r > 0:
                    prev_x = img_width // 2 + (r - 1) * cell_size * math.cos(angle)
                    prev_y = img_height // 2 + (r - 1) * cell_size * math.sin(angle)
                    draw.line([(prev_x, prev_y), (x, y)], fill="black", width=1)
                if cell["CW"]:
                    next_theta = (theta + 1) % 360
                    next_angle = math.radians(next_theta)
                    next_x = img_width // 2 + r * cell_size * math.cos(next_angle)
                    next_y = img_height // 2 + r * cell_size * math.sin(next_angle)
                    draw.line([(x, y), (next_x, next_y)], fill="black", width=1)

        img.save(filename)

    def _save_rectangular_svg(self, filename):
        dwg = svgwrite.Drawing(filename, size=(self.width * 20, self.height * 20))
        for x in range(self.width):
            for y in range(self.height):
                cell = self.grid[(x, y)]
                x1, y1 = x * 20, y * 20
                x2, y2 = x1 + 20, y1 + 20
                if cell["N"]:
                    dwg.add(dwg.line((x1, y1), (x2, y1), stroke="black"))
                if cell["S"]:
                    dwg.add(dwg.line((x1, y2), (x2, y2), stroke="black"))
                if cell["E"]:
                    dwg.add(dwg.line((x2, y1), (x2, y2), stroke="black"))
                if cell["W"]:
                    dwg.add(dwg.line((x1, y1), (x1, y2), stroke="black"))
        dwg.save()

    def _save_hexagonal_svg(self, filename):
        cell_size = 20
        dwg = svgwrite.Drawing(filename, size=(self.width * cell_size * 1.5, self.height * cell_size * math.sqrt(3)))
        for q in range(self.width):
            for r in range(self.height):
                x = q * cell_size * 1.5
                y = r * cell_size * math.sqrt(3) + (q % 2) * cell_size * math.sqrt(3) / 2
                points = [
                    (x + cell_size * dx, y + cell_size * dy)
                    for dx, dy in [
                        (0.5, -math.sqrt(3) / 2),
                        (1, 0),
                        (0.5, math.sqrt(3) / 2),
                        (-0.5, math.sqrt(3) / 2),
                        (-1, 0),
                        (-0.5, -math.sqrt(3) / 2),
                    ]
                ]
                cell = self.grid[(q, r)]
                if cell["N"]:
                    dwg.add(dwg.line(points[0], points[1], stroke="black"))
                if cell["S"]:
                    dwg.add(dwg.line(points[3], points[4], stroke="black"))
                if cell["NE"]:
                    dwg.add(dwg.line(points[1], points[2], stroke="black"))
                if cell["NW"]:
                    dwg.add(dwg.line(points[5], points[0], stroke="black"))
                if cell["SE"]:
                    dwg.add(dwg.line(points[2], points[3], stroke="black"))
                if cell["SW"]:
                    dwg.add(dwg.line(points[4], points[5], stroke="black"))
        dwg.save()

    def _save_circular_svg(self, filename):
        cell_size = 5
        dwg = svgwrite.Drawing(filename, size=(self.radius * cell_size * 2, self.radius * cell_size * 2))
        for r in range(self.radius):
            for theta in range(360):
                angle = math.radians(theta)
                x = self.radius * cell_size + r * cell_size * math.cos(angle)
                y = self.radius * cell_size + r * cell_size * math.sin(angle)
                cell = self.grid[(r, theta)]
                if cell["IN"] and r > 0:
                    prev_x = self.radius * cell_size + (r - 1) * cell_size * math.cos(angle)
                    prev_y = self.radius * cell_size + (r - 1) * cell_size * math.sin(angle)
                    dwg.add(dwg.line((prev_x, prev_y), (x, y), stroke="black"))
                if cell["CW"]:
                    next_theta = (theta + 1) % 360
                    next_angle = math.radians(next_theta)
                    next_x = self.radius * cell_size + r * cell_size * math.cos(next_angle)
                    next_y = self.radius * cell_size + r * cell_size * math.sin(next_angle)
                    dwg.add(dwg.line((x, y), (next_x, next_y), stroke="black"))
        dwg.save()


# Example Usage
if __name__ == "__main__":
    # Generate a rectangular maze and save as PNG and SVG
    # maze = MazeGenerator(10, 10, shape="rectangular")
    # maze.generate()
    # maze.save_png("rectangular_maze.png")
    # maze.save_svg("rectangular_maze.svg")

    # Generate a hexagonal maze and save as PNG and SVG
    maze = MazeGenerator(50, 50, shape="hexagonal")
    maze.generate()
    maze.save_png("hexagonal_maze_50x50_.png")
    maze.save_svg("hexagonal_maze_50x50.svg")

    # Generate a circular maze and save as PNG and SVG
    # maze = MazeGenerator(10, 10, shape="circular", radius=5)
    # maze.generate()
    # maze.save_png("circular_maze.png")
    # maze.save_svg("circular_maze.svg")
