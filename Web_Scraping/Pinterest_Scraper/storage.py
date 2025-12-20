import csv
import json
import sqlite3


def save_csv(filename, rows):
    if not rows:
        return

    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


def save_json(filename, rows):
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(rows, f, indent=2)


def save_sqlite(filename, rows):
    if not rows:
        return

    conn = sqlite3.connect(filename)
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS items (
            url TEXT PRIMARY KEY,
            title TEXT,
            sections INTEGER
        )
    """)

    cur.executemany("""
        INSERT OR IGNORE INTO items (url, title, sections)
        VALUES (:url, :title, :sections)
    """, rows)

    conn.commit()
    conn.close()

