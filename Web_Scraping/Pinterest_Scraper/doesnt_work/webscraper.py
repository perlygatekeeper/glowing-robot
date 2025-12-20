import time
import json
import osimport
from pathlib import Path
import requests
import yaml
from bs4 import BeautifulSoup

class WebScraper:
    def __init__(self, config_path="config.yaml"):
        with open(config_path, "r") as f:
            self.config = yaml.safe_load(f)

        self.base_url = self.config["base_url"].rstrip("/")
        self.session = requests.Session()
        self.data = []

        self.delay = self.config.get("scraping", {}).get("polite_delay", 1)
        self.checkpoint_file = self.config.get("checkpoint_file", "checkpoint.json")

    # ------------------ Networking ------------------

    def fetch_page(self, url):
        try:
            resp = self.session.get(url, timeout=10)
            resp.raise_for_status()
            return resp.text
        except requests.RequestException as e:
            print(f"[ERROR] Fetch failed: {e}")
            return None

    def parse_html(self, html):
        return BeautifulSoup(html, "html.parser")

    def polite_sleep(self):
        time.sleep(self.delay)

    # ------------------ Pagination ------------------

    def fetch_all_pages(self, start_url, next_page_selector):
        url = start_url
        while url:
            html = self.fetch_page(url)
            if not html:
                break

            soup = self.parse_html(html)
            yield soup

            next_link = soup.select_one(next_page_selector)
            if next_link and next_link.get("href"):
                url = self.base_url + next_link["href"]
            else:
                break

    # ------------------ Login ------------------

    def login(self):
        login_cfg = self.config.get("login", {})
        if not login_cfg.get("enabled"):
            return True

        username = os.getenv(login_cfg["username_env"])
        password = os.getenv(login_cfg["password_env"])

        if not username or not password:
            raise RuntimeError("Missing login environment variables")

        login_url = self.base_url + login_cfg["login_url"]
        resp = self.session.post(login_url, data={
            "username": username,
            "password": password
        })

        indicator = login_cfg.get("success_indicator")
        if indicator and indicator not in resp.text:
            raise RuntimeError("Login failed: success indicator not found")

        return True

    # ------------------ Pipeline ------------------

    def run(self):
        self.data.clear()
        self.scrape()
        return self.data

    def filter(self, predicate):
        self.data = [x for x in self.data if predicate(x)]
        return self

    def transform(self, func):
        self.data = [func(x) for x in self.data]
        return self

    # ------------------ Checkpointing ------------------

    def load_checkpoint(self):
        path = Path(self.checkpoint_file)
        if not path.exists():
            return set()

        with path.open("r", encoding="utf-8") as f:
            payload = json.load(f)

        self.data = payload.get("data", [])
        return set(payload.get("seen", []))

    def save_checkpoint(self, seen):
        with open(self.checkpoint_file, "w", encoding="utf-8") as f:
            json.dump({
                "data": self.data,
                "seen": list(seen)
            }, f, indent=2)
