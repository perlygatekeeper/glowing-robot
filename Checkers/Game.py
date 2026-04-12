#!/usr/bin/env python3
"""
Checkers - Pygame Edition
Features: PvP / PvAI, selectable difficulty, persistent player profiles
"""

import pygame
import json
import os
import sys
import random
import math
import copy

# ── Constants ────────────────────────────────────────────────────────────────
WIDTH, HEIGHT   = 720, 720
ROWS, COLS      = 8, 8
SQUARE          = WIDTH // COLS
SAVE_FILE       = os.path.join(os.path.dirname(__file__), "checkers_saves.json")

# Colours
C_LIGHT   = (240, 217, 181)
C_DARK    = ( 95,  66,  32)
C_BG      = ( 30,  30,  40)
C_RED     = (200,  50,  50)
C_RED_H   = (255, 100, 100)
C_BLACK   = ( 40,  40,  40)
C_BLACK_H = (100, 100, 120)
C_CROWN   = (255, 215,   0)
C_SEL     = (  0, 200, 100)
C_MOVE    = ( 80, 200, 120, 160)
C_TEXT    = (230, 230, 230)
C_BTN     = ( 60,  90, 140)
C_BTN_H   = ( 80, 120, 180)
C_WIN     = ( 20,  20,  30, 210)

RED   = "red"
BLACK = "black"


# ── Save / Load profiles ─────────────────────────────────────────────────────
def load_saves():
    if os.path.exists(SAVE_FILE):
        with open(SAVE_FILE) as f:
            return json.load(f)
    return {}

def save_saves(data):
    with open(SAVE_FILE, "w") as f:
        json.dump(data, f, indent=2)

def get_profile(saves, name):
    if name not in saves:
        saves[name] = {"wins": 0, "losses": 0, "draws": 0}
    return saves[name]

def record_result(saves, winner_name, loser_name):
    get_profile(saves, winner_name)["wins"]   += 1
    get_profile(saves, loser_name)["losses"]  += 1
    save_saves(saves)

def record_draw(saves, p1, p2):
    get_profile(saves, p1)["draws"] += 1
    get_profile(saves, p2)["draws"] += 1
    save_saves(saves)


# ── Board / Piece logic ───────────────────────────────────────────────────────
class Piece:
    def __init__(self, row, col, color):
        self.row   = row
        self.col   = col
        self.color = color
        self.king  = False

    def make_king(self):
        self.king = True

    def copy(self):
        p = Piece(self.row, self.col, self.color)
        p.king = self.king
        return p


class Board:
    def __init__(self):
        self.board  = [[None]*COLS for _ in range(ROWS)]
        self.red_left   = 12
        self.black_left = 12
        self._setup()

    def _setup(self):
        for row in range(ROWS):
            for col in range(COLS):
                if (row + col) % 2 == 1:
                    if row < 3:
                        self.board[row][col] = Piece(row, col, BLACK)
                    elif row > 4:
                        self.board[row][col] = Piece(row, col, RED)

    def get(self, row, col):
        return self.board[row][col]

    def move(self, piece, row, col):
        self.board[piece.row][piece.col] = None
        self.board[row][col] = piece
        piece.row, piece.col = row, col
        if (piece.color == RED and row == 0) or (piece.color == BLACK and row == ROWS - 1):
            piece.make_king()

    def remove(self, pieces):
        for p in pieces:
            self.board[p.row][p.col] = None
            if p.color == RED:
                self.red_left -= 1
            else:
                self.black_left -= 1

    def winner(self):
        if self.red_left   <= 0: return BLACK
        if self.black_left <= 0: return RED
        return None

    def get_all_pieces(self, color):
        return [self.board[r][c] for r in range(ROWS) for c in range(COLS)
                if self.board[r][c] and self.board[r][c].color == color]

    def get_valid_moves(self, piece):
        moves     = {}
        left, right = piece.col - 1, piece.col + 1
        row = piece.row
        if piece.color == RED or piece.king:
            moves.update(self._traverse_left (row-1, max(row-3,-1), -1, piece.color, left))
            moves.update(self._traverse_right(row-1, max(row-3,-1), -1, piece.color, right))
        if piece.color == BLACK or piece.king:
            moves.update(self._traverse_left (row+1, min(row+3,ROWS), 1, piece.color, left))
            moves.update(self._traverse_right(row+1, min(row+3,ROWS), 1, piece.color, right))
        return moves

    def _traverse_left(self, start, stop, step, color, col, skipped=[]):
        moves, last = {}, []
        for r in range(start, stop, step):
            if col < 0: break
            curr = self.board[r][col]
            if curr is None:
                if skipped and not last: break
                if skipped: moves[(r,col)] = last + skipped
                else:       moves[(r,col)] = last
                if last:
                    nr = r+step if step==-1 else r+step
                    nstep = step
                    moves.update(self._traverse_left (r+step, stop, step, color, col-1, skipped=last))
                    moves.update(self._traverse_right(r+step, stop, step, color, col+1, skipped=last))
                break
            elif curr.color == color:
                break
            else:
                last = [curr]
            col -= 1
        return moves

    def _traverse_right(self, start, stop, step, color, col, skipped=[]):
        moves, last = {}, []
        for r in range(start, stop, step):
            if col >= COLS: break
            curr = self.board[r][col]
            if curr is None:
                if skipped and not last: break
                if skipped: moves[(r,col)] = last + skipped
                else:       moves[(r,col)] = last
                if last:
                    moves.update(self._traverse_left (r+step, stop, step, color, col-1, skipped=last))
                    moves.update(self._traverse_right(r+step, stop, step, color, col+1, skipped=last))
                break
            elif curr.color == color:
                break
            else:
                last = [curr]
            col += 1
        return moves

    def copy(self):
        b = Board.__new__(Board)
        b.board      = [[p.copy() if p else None for p in row] for row in self.board]
        b.red_left   = self.red_left
        b.black_left = self.black_left
        return b

    def evaluate(self):
        score = 0
        for r in range(ROWS):
            for c in range(COLS):
                p = self.board[r][c]
                if p:
                    v = 1 + (0.5 if p.king else 0)
                    score += v if p.color == BLACK else -v
        return score


# ── AI (minimax + alpha-beta) ─────────────────────────────────────────────────
def get_all_moves(board, color):
    moves = []
    for piece in board.get_all_pieces(color):
        valid = board.get_valid_moves(piece)
        for move, skip in valid.items():
            tmp = board.copy()
            tmp_piece = tmp.get(piece.row, piece.col)
            tmp.move(tmp_piece, move[0], move[1])
            if skip:
                tmp.remove([tmp.get(s.row, s.col) for s in skip])
            moves.append(tmp)
    return moves

def minimax(board, depth, alpha, beta, maximizing):
    if depth == 0 or board.winner():
        return board.evaluate(), board

    if maximizing:
        best = (-math.inf, None)
        for b in get_all_moves(board, BLACK):
            val, _ = minimax(b, depth-1, alpha, beta, False)
            if val > best[0]: best = (val, b)
            alpha = max(alpha, val)
            if beta <= alpha: break
        return best
    else:
        best = (math.inf, None)
        for b in get_all_moves(board, RED):
            val, _ = minimax(b, depth-1, alpha, beta, True)
            if val < best[0]: best = (val, b)
            beta = min(beta, val)
            if beta <= alpha: break
        return best

def ai_move(board, depth):
    _, new_board = minimax(board, depth, -math.inf, math.inf, True)
    return new_board


# ── Drawing helpers ───────────────────────────────────────────────────────────
def draw_board(surface):
    surface.fill(C_DARK)
    for r in range(ROWS):
        for c in range(r % 2, COLS, 2):
            pygame.draw.rect(surface, C_LIGHT, (c*SQUARE, r*SQUARE, SQUARE, SQUARE))

def draw_pieces(surface, board):
    for r in range(ROWS):
        for c in range(COLS):
            p = board.get(r, c)
            if p:
                cx = c*SQUARE + SQUARE//2
                cy = r*SQUARE + SQUARE//2
                rad = SQUARE//2 - 8
                shadow_col = (10, 10, 10)
                pygame.draw.circle(surface, shadow_col, (cx+3, cy+3), rad)
                col = C_RED if p.color == RED else C_BLACK
                pygame.draw.circle(surface, col, (cx, cy), rad)
                # rim
                rim = C_RED_H if p.color == RED else C_BLACK_H
                pygame.draw.circle(surface, rim, (cx, cy), rad, 3)
                if p.king:
                    font = pygame.font.SysFont("segoeuisymbol", rad, bold=True)
                    crown = font.render("♛", True, C_CROWN)
                    surface.blit(crown, crown.get_rect(center=(cx, cy)))

def draw_highlights(surface, selected, valid_moves):
    if selected:
        c, r = selected.col*SQUARE, selected.row*SQUARE
        pygame.draw.rect(surface, C_SEL, (c, r, SQUARE, SQUARE), 4)
    for (mr, mc) in valid_moves:
        s = pygame.Surface((SQUARE, SQUARE), pygame.SRCALPHA)
        s.fill(C_MOVE)
        surface.blit(s, (mc*SQUARE, mr*SQUARE))

def draw_text_centered(surface, text, font, color, rect):
    rendered = font.render(text, True, color)
    surface.blit(rendered, rendered.get_rect(center=rect.center))

def draw_button(surface, rect, text, font, hover=False):
    col = C_BTN_H if hover else C_BTN
    pygame.draw.rect(surface, col, rect, border_radius=8)
    pygame.draw.rect(surface, C_TEXT, rect, 2, border_radius=8)
    draw_text_centered(surface, text, font, C_TEXT, rect)

def overlay(surface):
    s = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
    s.fill(C_WIN)
    surface.blit(s, (0,0))


# ── UI Screens ────────────────────────────────────────────────────────────────
def input_box(surface, clock, font, prompt, saves):
    """Simple text-input screen; returns the entered name."""
    name = ""
    box  = pygame.Rect(WIDTH//2-160, HEIGHT//2-28, 320, 56)
    while True:
        surface.fill(C_BG)
        title = font.render(prompt, True, C_TEXT)
        surface.blit(title, title.get_rect(center=(WIDTH//2, HEIGHT//2-90)))
        # Leaderboard snippet
        lf = pygame.font.SysFont("consolas", 18)
        y0 = HEIGHT//2 + 60
        surface.blit(lf.render("── Leaderboard ──", True, C_TEXT), (WIDTH//2-90, y0))
        sorted_p = sorted(saves.items(), key=lambda x: x[1]["wins"], reverse=True)[:5]
        for i, (pname, stats) in enumerate(sorted_p):
            line = f"{pname[:14]:<14}  W:{stats['wins']}  L:{stats['losses']}  D:{stats['draws']}"
            surface.blit(lf.render(line, True, C_TEXT), (WIDTH//2-160, y0+24+i*22))

        pygame.draw.rect(surface, C_BTN, box, border_radius=6)
        pygame.draw.rect(surface, C_SEL if len(name)>0 else C_TEXT, box, 2, border_radius=6)
        txt = font.render(name + "|", True, C_TEXT)
        surface.blit(txt, txt.get_rect(midleft=(box.x+10, box.centery)))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit(); sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_RETURN and name.strip():
                    return name.strip()
                elif event.key == pygame.K_BACKSPACE:
                    name = name[:-1]
                elif event.unicode.isprintable() and len(name) < 16:
                    name += event.unicode
        pygame.display.flip()
        clock.tick(60)

def mode_screen(surface, clock, font):
    """Returns ('pvp', None) or ('ai', depth)."""
    buttons = {
        "pvp":    pygame.Rect(WIDTH//2-160, 260, 320, 60),
        "easy":   pygame.Rect(WIDTH//2-160, 350, 320, 60),
        "medium": pygame.Rect(WIDTH//2-160, 430, 320, 60),
        "hard":   pygame.Rect(WIDTH//2-160, 510, 320, 60),
    }
    labels = {"pvp":"Player vs Player","easy":"AI – Easy","medium":"AI – Medium","hard":"AI – Hard"}
    depths = {"easy":1,"medium":3,"hard":6}
    while True:
        mx, my = pygame.mouse.get_pos()
        surface.fill(C_BG)
        title = pygame.font.SysFont("georgia", 44, bold=True).render("♟  Checkers", True, C_TEXT)
        surface.blit(title, title.get_rect(center=(WIDTH//2, 160)))
        sub = font.render("Choose game mode", True, (160,160,180))
        surface.blit(sub, sub.get_rect(center=(WIDTH//2, 215)))
        for key, rect in buttons.items():
            draw_button(surface, rect, labels[key], font, rect.collidepoint(mx,my))
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit(); sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                for key, rect in buttons.items():
                    if rect.collidepoint(event.pos):
                        if key == "pvp": return "pvp", None
                        return "ai", depths[key]
        pygame.display.flip()
        clock.tick(60)

def end_screen(surface, clock, font, message, saves, p1, p2):
    """Show winner overlay, then return 'again' or 'quit'."""
    btn_again = pygame.Rect(WIDTH//2-170, HEIGHT//2+60, 150, 54)
    btn_quit  = pygame.Rect(WIDTH//2+20,  HEIGHT//2+60, 150, 54)
    lf = pygame.font.SysFont("consolas", 18)
    while True:
        mx, my = pygame.mouse.get_pos()
        overlay(surface)
        msg = pygame.font.SysFont("georgia", 42, bold=True).render(message, True, C_CROWN)
        surface.blit(msg, msg.get_rect(center=(WIDTH//2, HEIGHT//2-60)))
        # stats
        for i, name in enumerate([p1, p2]):
            st = saves.get(name, {"wins":0,"losses":0,"draws":0})
            line = f"{name}: W{st['wins']} L{st['losses']} D{st['draws']}"
            surface.blit(lf.render(line, True, C_TEXT), (WIDTH//2-160, HEIGHT//2+10+i*24))
        draw_button(surface, btn_again, "Play Again", font, btn_again.collidepoint(mx,my))
        draw_button(surface, btn_quit,  "Quit",       font, btn_quit.collidepoint(mx,my))
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit(); sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if btn_again.collidepoint(event.pos): return "again"
                if btn_quit.collidepoint(event.pos):  return "quit"
        pygame.display.flip()
        clock.tick(60)


# ── Game loop ─────────────────────────────────────────────────────────────────
def get_all_valid_for_color(board, color):
    moves = {}
    for piece in board.get_all_pieces(color):
        for move, skip in board.get_valid_moves(piece).items():
            moves[(piece.row, piece.col, move[0], move[1])] = (piece, move, skip)
    return moves

def run_game(surface, clock, font, mode, ai_depth, p1_name, p2_name, saves):
    board    = Board()
    turn     = RED       # RED always starts
    selected = None
    valid    = {}
    ai_turn_delay = 0
    status_font = pygame.font.SysFont("consolas", 20)

    def current_name():
        return p1_name if turn == RED else p2_name

    while True:
        # ── Events ──
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit(); sys.exit()
            if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                return "quit"

            if event.type == pygame.MOUSEBUTTONDOWN:
                if mode == "pvp" or (mode == "ai" and turn == RED):
                    mx, my = event.pos
                    col, row = mx // SQUARE, my // SQUARE
                    if 0 <= row < ROWS and 0 <= col < COLS:
                        piece = board.get(row, col)
                        if selected:
                            if (row, col) in valid:
                                board.move(selected, row, col)
                                skip = valid[(row, col)]
                                if skip:
                                    board.remove([board.get(s.row, s.col) for s in skip])
                                selected = None
                                valid    = {}
                                turn     = BLACK if turn == RED else RED
                            else:
                                selected = None
                                valid    = {}
                                if piece and piece.color == turn:
                                    selected = piece
                                    valid    = board.get_valid_moves(piece)
                        else:
                            if piece and piece.color == turn:
                                selected = piece
                                valid    = board.get_valid_moves(piece)

        # ── AI turn ──
        if mode == "ai" and turn == BLACK:
            ai_turn_delay += clock.get_time()
            if ai_turn_delay > 400:
                new_board = ai_move(board, ai_depth)
                if new_board:
                    board = new_board
                turn  = RED
                ai_turn_delay = 0

        # ── Draw ──
        draw_board(surface)
        draw_highlights(surface, selected, valid)
        draw_pieces(surface, board)

        # Status bar
        bar = pygame.Surface((WIDTH, 36), pygame.SRCALPHA)
        bar.fill((0,0,0,140))
        surface.blit(bar, (0, HEIGHT-36))
        whose = current_name()
        col_dot = "🔴" if turn == RED else "⚫"
        info = status_font.render(f"{col_dot} {whose}'s turn   R:{board.red_left}  B:{board.black_left}   ESC=menu", True, C_TEXT)
        surface.blit(info, (10, HEIGHT-28))

        pygame.display.flip()
        clock.tick(60)

        # ── Check winner ──
        winner = board.winner()
        if winner is None:
            # Check if current player has no moves
            all_m = get_all_valid_for_color(board, turn)
            if not all_m:
                winner = BLACK if turn == RED else RED

        if winner:
            w_name = p1_name if winner == RED else p2_name
            l_name = p2_name if winner == RED else p1_name
            record_result(saves, w_name, l_name)
            return end_screen(surface, clock, font, f"🏆  {w_name} wins!", saves, p1_name, p2_name)


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    pygame.init()
    surface = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Checkers")
    clock = pygame.time.Clock()
    font  = pygame.font.SysFont("segoeui", 26, bold=True)
    saves = load_saves()

    while True:
        mode, depth = mode_screen(surface, clock, font)

        p1 = input_box(surface, clock, font, "Player 1 name (RED):", saves)
        if mode == "pvp":
            p2 = input_box(surface, clock, font, "Player 2 name (BLACK):", saves)
        else:
            diff = {1:"Easy",3:"Medium",6:"Hard"}[depth]
            p2 = f"AI ({diff})"
            get_profile(saves, p2)

        result = run_game(surface, clock, font, mode, depth, p1, p2, saves)
        if result == "quit":
            continue   # back to mode screen

if __name__ == "__main__":
    main()
