from collections import deque

class MazeGenerator:
    def __init__(self, width, height, shape="rectangular", radius=None):
        self.width = width
        self.height = height
        self.shape = shape
        self.radius = radius if radius else min(width, height) // 2
        self.grid = {}
        self.visited = set()
        self.solution_path = []

    def generate(self):
        if self.shape == "rectangular":
            self._generate_rectangular()
        elif self.shape == "hexagonal":
            self._generate_hexagonal()
        elif self.shape == "circular":
            self._generate_circular()
        else:
            raise ValueError("Unsupported shape. Choose 'rectangular', 'hexagonal', or 'circular'.")

    def solve(self, start, end):
        """Find the shortest path from start to end using BFS."""
        queue = deque([(start, [start])])
        visited = set()

        while queue:
            current, path = queue.popleft()
            if current == end:
                self.solution_path = path
                return path
            if current in visited:
                continue
            visited.add(current)
            neighbors = self._get_neighbors(current)
            for neighbor in neighbors:
                if neighbor not in visited:
                    queue.append((neighbor, path + [neighbor]))

        return None

    def _get_neighbors(self, cell):
        """Get valid neighbors for a given cell."""
        neighbors = []
        x, y = cell
        directions = {
            "N": (0, -1),
            "S": (0, 1),
            "E": (1, 0),
            "W": (-1, 0),
        }
        for direction, (dx, dy) in directions.items():
            nx, ny = x + dx, y + dy
            if (nx, ny) in self.grid and not self.grid[(x, y)][direction]:
                neighbors.append((nx, ny))
        return neighbors

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

        # Draw borders
        draw.rectangle([0, 0, img_width - 1, img_height - 1], outline="black")

        # Draw maze walls
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

        # Draw solution path
        if self.solution_path:
            for i in range(len(self.solution_path) - 1):
                x1, y1 = self.solution_path[i]
                x2, y2 = self.solution_path[i + 1]
                x1, y1 = x1 * cell_size + cell_size // 2, y1 * cell_size + cell_size // 2
                x2, y2 = x2 * cell_size + cell_size // 2, y2 * cell_size + cell_size // 2
                draw.line([(x1, y1), (x2, y2)], fill="red", width=2)

        img.save(filename)

    # Similar updates for _save_hexagonal_png and _save_circular_png...

    def _save_rectangular_svg(self, filename):
        cell_size = 20
        dwg = svgwrite.Drawing(filename, size=(self.width * cell_size, self.height * cell_size))

        # Draw borders
        dwg.add(dwg.rect((0, 0), (self.width * cell_size, self.height * cell_size), stroke="black", fill="none"))

        # Draw maze walls
        for x in range(self.width):
            for y in range(self.height):
                cell = self.grid[(x, y)]
                x1, y1 = x * cell_size, y * cell_size
                x2, y2 = x1 + cell_size, y1 + cell_size
                if cell["N"]:
                    dwg.add(dwg.line((x1, y1), (x2, y1), stroke="black"))
                if cell["S"]:
                    dwg.add(dwg.line((x1, y2), (x2, y2), stroke="black"))
                if cell["E"]:
                    dwg.add(dwg.line((x2, y1), (x2, y2), stroke="black"))
                if cell["W"]:
                    dwg.add(dwg.line((x1, y1), (x1, y2), stroke="black"))

        # Draw solution path
        if self.solution_path:
            for i in range(len(self.solution_path) - 1):
                x1, y1 = self.solution_path[i]
                x2, y2 = self.solution_path[i + 1]
                x1, y1 = x1 * cell_size + cell_size // 2, y1 * cell_size + cell_size // 2
                x2, y2 = x2 * cell_size + cell_size // 2, y2 * cell_size + cell_size // 2
                dwg.add(dwg.line((x1, y1), (x2, y2), stroke="red", stroke_width=2))

        dwg.save()

    # Similar updates for _save_hexagonal_svg and _save_circular_svg...


# Example Usage
if __name__ == "__main__":
    # Generate a rectangular maze, solve it, and save as PNG and SVG
    maze = MazeGenerator(50, 50, shape="rectangular")
    maze.generate()
    maze.solve(start=(0, 0), end=(49, 49))  # Solve from top-left to bottom-right
    maze.save_png("rectangular_maze_with_solution.png")
    maze.save_svg("rectangular_maze_with_solution.svg")
